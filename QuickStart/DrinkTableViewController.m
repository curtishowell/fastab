//
//  DrinkTableViewController.m
//  QuickStart
//
//  Created by studentuser on 4/9/13.
//  Copyright (c) 2013 Windows Azure. All rights reserved.
//

#import "DrinkTableViewController.h"
#import <WindowsAzureMobileServices/WindowsAzureMobileServices.h>
#import "AzureConnection.h"

@interface DrinkTableViewController ()

@end

@implementation DrinkTableViewController

- (void)setdrinkTypeListing:(NSArray *)drinkTypeListing
{
    _drinkTypeListing = drinkTypeListing;
    [self.tableView reloadData];
}

- (void)setspecificDrinks:(NSArray *)specificDrinks
{
    _specificDrinks = specificDrinks;
    [self.tableView reloadData];
}

#pragma mark - Table view data source

/*
 // We may or may not have multiple sections for drinks. If we decide we need more sections,
 // we can define this method. It will remain commented out until the final decision has been made
 // by the designer.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 0;
}
*/

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return 1;
    //(#2)return [self.BarListing count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"drinkItem";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    //(#1)cell.textLabel.text = [self titleForRow: indexPath.row];
    cell.textLabel.text = @"> BEEEEEEEEEERRRRR";
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

@end
