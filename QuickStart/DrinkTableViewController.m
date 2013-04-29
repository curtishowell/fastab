#import "DrinkTableViewController.h"
#import <WindowsAzureMobileServices/WindowsAzureMobileServices.h>
#import "AzureConnection.h"
#import "ItemInCart.h"


@interface DrinkTableViewController ()
@property (strong, nonatomic) AzureConnection *azureConnection;
@end

@implementation DrinkTableViewController
@synthesize azureConnection;


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Create the connection to Azure - this creates the Mobile Service client inside the wrapped service
    self.azureConnection = [[AzureConnection alloc] initWithTableName: @"Item"];
    
    //NSPredicate * predicate = [NSPredicate predicateWithFormat:@"itemType == 1"];
    //NSLog([NSString stringWithFormat:@"item type is %d", self.itemTypeID]);
    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"itemtype == %d", [self.itemTypeID intValue]];
    //NSPredicate * predicate = [NSPredicate predicateWithFormat:@"name == name"];
    
    [self.azureConnection refreshDataOnSuccess:^{
        [self.tableView reloadData];
    } withPredicate:predicate];
    
    //set title in the nav bar
    //self.navigationItem.title = @"best name ever";
    self.navigationItem.title = self.itemTypeName;

}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.azureConnection.items count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"drinkItem";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    NSDictionary *item = [self.azureConnection.items objectAtIndex:indexPath.row];
    cell.textLabel.textColor = [UIColor blackColor];
    //need to change the string we send in to objectForKey
    cell.textLabel.text = [item objectForKey:@"name"];
    
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
    if ([segue.identifier isEqualToString:@"DCheckout"]) {
        
        ItemInCart *item = [[ItemInCart alloc] init];
        
        
        //TODO
        //add details to item
        //send item to cart when segueing
        
        
        
        UIViewController *checkout = segue.destinationViewController;
        NSString *venuePlace = self.venue;
        [checkout performSelector:@selector(setVenue:) withObject:venuePlace];
    }
}

@end
