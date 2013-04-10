//
//  BarTableViewController.m
//  QuickStart
//
//  Created by studentuser on 4/6/13.
//  Copyright (c) 2013 Windows Azure. All rights reserved.
//

#import "BarTableViewController.h"

@interface BarTableViewController ()

@end

@implementation BarTableViewController

- (void)setBarListing:(NSArray *)BarListing
{
    _BarListing = BarListing;
    [self.tableView reloadData];
}


#pragma mark - Table view data source

//Since we only have 1 Section, We do not implement the method below!
//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
//{
//#warning Potentially incomplete method implementation.
    // Return the number of sections.
//    return 0;
//}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
    //(#2)return [self.BarListing count];
}

- (NSString *)titleForRow:(NSUInteger) row
{
    //put the code to get the titles of bars for the stuff
    //once this is implemented uncomment the following areas: (#1, #2)
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"toDrinkList";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    //(#1)cell.textLabel.text = [self titleForRow: indexPath.row];
    cell.textLabel.text = @"WOOHOOO GIRL";
    
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

//testing adding new shit to this file. YEAH BITCH

@end
