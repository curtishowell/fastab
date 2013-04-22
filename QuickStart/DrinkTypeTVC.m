#import "DrinkTypeTVC.h"
#import <WindowsAzureMobileServices/WindowsAzureMobileServices.h>
#import "AzureConnection.h"

@interface DrinkTypeTVC ()
@property (strong, nonatomic) AzureConnection *azureConnection;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableDictionary *drinkTypeMap; //of type NSString to NSNumber
@end

@implementation DrinkTypeTVC

@synthesize azureConnection;


- (NSNumber *)venueID {
    if(!_venueID){
        _venueID = [[NSNumber alloc] init];
    }
    return _venueID;
}

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
    self.azureConnection = [[AzureConnection alloc] initWithTableName: @"ItemType"];
    
    int venueIDint = [self.venueID intValue];
    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"venue == %d", [self.venueID intValue]];
    //NSPredicate * predicate = [NSPredicate predicateWithFormat:@"name == name"];
    
    [self.azureConnection refreshDataOnSuccess:^{
        [self.tableView reloadData];
    } withPredicate:predicate];
    
    //set title in the nav bar
    self.navigationItem.title = self.venueName;
    
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
    cell.textLabel.textColor = [UIColor blackColor];
    //need to change the string we send in to objectForKey
    cell.textLabel.text = [item objectForKey:@"name"];
    
    
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
    //NSLog(segue.identifier);
    //NSLog([NSString stringWithFormat:@"%@", segue.identifier]);
    if ([segue.identifier isEqualToString:@"typesToItems"]) {
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
        [drinkTypeTVC performSelector:@selector(setItemTypeID:)
                           withObject:venueID];
        [drinkTypeTVC performSelector:@selector(setItemTypeName:)
                           withObject:drinkType];
        
    }
}

@end
