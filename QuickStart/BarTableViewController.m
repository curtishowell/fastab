//
//  BarTableViewController.m
//  QuickStart
//
//  Created by studentuser on 4/6/13.
//  Copyright (c) 2013 Windows Azure. All rights reserved.
//

#import "BarTableViewController.h"
#import <WindowsAzureMobileServices/WindowsAzureMobileServices.h>
#import "AzureConnection.h"
#import "DrinkTypeTVC.h"

@interface BarTableViewController ()
@property (strong, nonatomic) AzureConnection *azureConnection;
//@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableDictionary *drinkTypeMap; //of type NSString to NSNumber
@end

@implementation BarTableViewController
@synthesize azureConnection;
@synthesize tableView;


- (NSMutableDictionary *) drinkTypeMap {
    if(! _drinkTypeMap) {
        _drinkTypeMap = [[NSMutableDictionary alloc] init];
    }
    return _drinkTypeMap;
}



- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Create the connection to Azure - this creates the Mobile Service client inside the wrapped service
    self.azureConnection = [[AzureConnection alloc] initWithTableName: @"Venue"];
    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"name == name"];

    
    
    [self.azureConnection refreshDataOnSuccess:^{
        [self.tableView reloadData];
    } withPredicate:predicate];
    
    //hide back button
    self.navigationItem.hidesBackButton = YES;
}

#pragma mark - Table view data source

//Since we only have 1 Section, We do not implement the method below!
//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
//{
//#warning Potentially incomplete method implementation.
    // Return the number of sections.
//    return 0;
//}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{
    return [self.azureConnection.items count];
}


- (NSString *)titleForRow:(NSUInteger) row
{
    //put the code to get the titles of bars for the stuff
    //once this is implemented uncomment the following areas: (#1, #2)
}


- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"toDrinkList";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    //get the item from Azure
    NSDictionary *item = [self.azureConnection.items objectAtIndex:indexPath.row];
    
    //get the venue name and ID out of the azure item
    NSString *venueName = [item objectForKey:@"name"];
    int temp = [[item objectForKey:@"id"] intValue];
    NSNumber *venueID = [NSNumber numberWithInt:[[item objectForKey:@"id"] intValue]];
    
    //set cell label
    cell.textLabel.textColor = [UIColor blackColor];
    cell.textLabel.text = venueName;
    
    NSString *key = [NSString stringWithFormat:@"%d",indexPath.row];

    //add the cell info to the drinkTypeMap
    [self.drinkTypeMap setValue:venueID forKey:key];
    
    return cell;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
    
    
}

-(BOOL) textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"barsToTypes"]) {
        UITableViewController *drinkTypeTVC = segue.destinationViewController;
        
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        UITableViewCell *selectedCell = [self.tableView cellForRowAtIndexPath:indexPath];
        NSString *drinkType = selectedCell.textLabel.text;
        
        //key for getting the NSNumber out of the map
        NSString *key = [NSString stringWithFormat:@"%d",indexPath.row];
        
        //get the NSNumber out of the map using key
        NSNumber *venueID = [self.drinkTypeMap objectForKey:key];
        
        int temp = [venueID intValue];
        
        //set values in the drink type view controller
        [drinkTypeTVC performSelector:@selector(setVenueID:)
                           withObject:venueID];
        [drinkTypeTVC performSelector:@selector(setVenueName:)
                           withObject:drinkType];
        
    }
}



@end
