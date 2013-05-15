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
#import <QuartzCore/QuartzCore.h>

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
    
    //set background color of the tableview to gray
    UIColor *bgColor = [[UIColor alloc] initWithRed:0.22 green:0.22 blue:0.22 alpha:1.0];
    self.tableView.backgroundColor = bgColor;
    
    //self.navigationController.navigationBar.tintColor = [UIColor blackColor];
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


- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"toDrinkList";
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    //get the item from Azure
    NSDictionary *item = [self.azureConnection.items objectAtIndex:indexPath.row];
    
    //get the venue name and ID out of the azure item
    NSString *venueName = [item objectForKey:@"name"];
    NSNumber *venueID = [NSNumber numberWithInt:[[item objectForKey:@"id"] intValue]];
    
    //set cell label
    //cell.textLabel.textColor = [UIColor blackColor];
//    cell.textLabel.text = venueName;
    
    
    NSString *fileName = [NSString stringWithFormat: @"%d.jpg", indexPath.row + 1];
    
    //UIImage *image = [[UIImage alloc] initWithContentsOfFile:path];
    UIImage *image = [UIImage imageNamed:fileName];
    //self.imgView.image = [UIImage imageWithContentsOfFile:path];
    
    //set properties of uiimageview
    UIImageView *imageView = (UIImageView *)[cell viewWithTag:1];
    imageView.image = image;
    [imageView.layer setBorderColor: [[UIColor grayColor] CGColor]];
    [imageView.layer setBorderWidth: 1.5];
    [imageView.layer setShadowColor:[[UIColor whiteColor] CGColor]];
    //[imageView.layer setShadowOffset:5.0];
    
    UILabel *label;
    label = (UILabel *)[cell viewWithTag:2];
    label.text = [NSString stringWithFormat:@"%@", venueName];
    
    label = (UILabel *)[cell viewWithTag:3];
    label.text = [NSString stringWithFormat:@"%@", [item objectForKey:@"address"]];
    
    label = (UILabel *)[cell viewWithTag:4];
    label.text = [NSString stringWithFormat:@"%@, %@", [item objectForKey:@"city"], [item objectForKey:@"state"]];
    
    NSString *key = [NSString stringWithFormat:@"%d",indexPath.row];

    //add the cell info to the drinkTypeMap
    [self.drinkTypeMap setValue:venueID forKey:key];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}


-(BOOL) textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue
                 sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"barsToTypes"]) {
        UITableViewController *drinkTypeTVC = segue.destinationViewController;
        
        //get the NSDictionary item realating to the selected indexPath
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        NSDictionary *item = [self.azureConnection.items objectAtIndex:indexPath.row];
        
        //get the values out of the dictionary
        NSNumber *itemID = [item objectForKey:@"id"];
        NSString *itemName = [[item objectForKey:@"name"] description];
        
        //set values in the drink type view controller
        [drinkTypeTVC performSelector:@selector(setVenueID:)
                           withObject:itemID];
        [drinkTypeTVC performSelector:@selector(setVenueName:)
                           withObject:itemName];
        
    }
}



@end
