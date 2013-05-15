#import "DrinkTypeTVC.h"
//#import <WindowsAzureMobileServices/WindowsAzureMobileServices.h>
#import "AzureConnection.h"

@interface DrinkTypeTVC ()
@property (strong, nonatomic) AzureConnection *azureConnection;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@end

@implementation DrinkTypeTVC

@synthesize azureConnection;
@synthesize venueName;

- (NSNumber *)venueID {
    if(!_venueID){
        _venueID = [[NSNumber alloc] init];
    }
    return _venueID;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Create the connection to Azure - this creates the Mobile Service client inside the wrapped service
    self.azureConnection = [[AzureConnection alloc] initWithTableName: @"ItemType"];
    
    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"venue == %d", [self.venueID intValue]];
    //NSPredicate * predicate = [NSPredicate predicateWithFormat:@"name == name"];
    
    [self.azureConnection refreshDataOnSuccess:^{
        [self.tableView reloadData];
    } withPredicate:predicate];
    
    //set title in the nav bar
    self.navigationItem.title = self.venueName;
    
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
    static NSString *CellIdentifier = @"drinkTypeCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    NSDictionary *item = [self.azureConnection.items objectAtIndex:indexPath.row];
    //cell.textLabel.textColor = [UIColor blackColor];
    //need to change the string we send in to objectForKey
    //cell.textLabel.text = [item objectForKey:@"name"];
    
    NSString *drinkTypeName = [item objectForKey:@"name"];
    
    UILabel *label;
    label = (UILabel *)[cell viewWithTag:1];
    label.text = [NSString stringWithFormat:@"%@", drinkTypeName];
    
    
    //get the venue name out of the azure item
//    NSString *drinkTypeName = [item objectForKey:@"name"];
    
    //set cell label
//    cell.textLabel.textColor = [UIColor blackColor];
//    cell.textLabel.text = drinkTypeName;
    
    
    //add the cell info to the drinkTypeMap    
    
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

-(BOOL) textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue
                 sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"typesToItems"]) {
        UITableViewController *drinkTypeTVC = segue.destinationViewController;
        
        //get the item item realating to the selected indexPath
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        NSDictionary *item = [self.azureConnection.items objectAtIndex:indexPath.row];
        
        //get the values out of the dictionary
        NSNumber *itemTypeID = [item objectForKey:@"id"];
        NSString *itemTypeName = [[item objectForKey:@"name"] description];
        
        //set values in the drink type view controller
        [drinkTypeTVC performSelector:@selector(setItemTypeID:)
                           withObject:itemTypeID];
        [drinkTypeTVC performSelector:@selector(setItemTypeName:)
                           withObject:itemTypeName];
        [drinkTypeTVC performSelector:@selector(setVenueName:)
                           withObject:self.venueName];
        [drinkTypeTVC performSelector:@selector(setVenueID:)
                           withObject:self.venueID];
        
    }
    if ([segue.identifier isEqualToString:@"DTypeCheckout"]) {
        UIViewController *checkout = segue.destinationViewController;
        [checkout performSelector:@selector(setVenueName:) withObject:self.venueName];
        [checkout performSelector:@selector(setVenueID:) withObject:self.venueID];
    }
}

@end
