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
@property (strong, nonatomic) IBOutlet UITableView *tableView;

//activity view properties
@property (nonatomic, retain) UIActivityIndicatorView * activityView;
@property (nonatomic, retain) UIView *loadingView;
@property (nonatomic, retain) UILabel *loadingLabel;
@end

@implementation BarTableViewController
@synthesize azureConnection;
@synthesize tableView;
@synthesize activityView;
@synthesize loadingView;
@synthesize loadingLabel;



- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self showActivityIndicator];
    
    // Create the connection to Azure - this creates the Mobile Service client inside the wrapped service
    self.azureConnection = [[AzureConnection alloc] initWithTableName: @"Venue"];
    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"name == name"];

    
    
    [self.azureConnection refreshDataOnSuccess:^{
        [self.tableView reloadData];
        [self.loadingView removeFromSuperview];
    } withPredicate:predicate];
    
    //hide back button
    self.navigationItem.hidesBackButton = YES;
    
    //set background color of the tableview to gray
    UIColor *bgColor = [[UIColor alloc] initWithRed:0.22 green:0.22 blue:0.22 alpha:1.0];
    self.tableView.backgroundColor = bgColor;
    
}

#pragma mark - Table view data source

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
    
    //get the item from Azure
    NSDictionary *item = [self.azureConnection.items objectAtIndex:indexPath.row];
    
    //get the venue name and ID out of the azure item
    NSString *venueName = [item objectForKey:@"name"];
    
    
    NSString *fileName = [NSString stringWithFormat: @"%d.jpg", indexPath.row + 1];
    
    UIImage *image = [UIImage imageNamed:fileName];
    
    //set properties of uiimageview
    UIImageView *imageView = (UIImageView *)[cell viewWithTag:1];
    imageView.image = image;
    [imageView.layer setBorderColor: [[UIColor grayColor] CGColor]];
    [imageView.layer setBorderWidth: 1.5];
    [imageView.layer setShadowColor:[[UIColor whiteColor] CGColor]];
    
    UILabel *label;
    label = (UILabel *)[cell viewWithTag:2];
    label.text = [NSString stringWithFormat:@"%@", venueName];
    
    label = (UILabel *)[cell viewWithTag:3];
    label.text = [NSString stringWithFormat:@"%@", [item objectForKey:@"address"]];
    
    label = (UILabel *)[cell viewWithTag:4];
    label.text = [NSString stringWithFormat:@"%@, %@", [item objectForKey:@"city"], [item objectForKey:@"state"]];
    
    return cell;
}

//- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    
//}

- (void)showActivityIndicator {
	
	loadingView = [[UIView alloc] initWithFrame:CGRectMake(75, 120, 170, 170)];
	loadingView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
	loadingView.clipsToBounds = YES;
	loadingView.layer.cornerRadius = 10.0;
	
	activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
	activityView.frame = CGRectMake(65, 40, activityView.bounds.size.width, activityView.bounds.size.height);
    [loadingView addSubview:activityView];
	
    loadingLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 115, 130, 22)];
    loadingLabel.backgroundColor = [UIColor clearColor];
    loadingLabel.textColor = [UIColor whiteColor];
    loadingLabel.adjustsFontSizeToFitWidth = YES;
    loadingLabel.textAlignment = UITextAlignmentCenter;
    loadingLabel.text = @"Loading...";
    [loadingView addSubview:loadingLabel];
	
    [self.view addSubview:loadingView];
    [activityView startAnimating];
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
