#import "DrinkTableViewController.h"
#import <WindowsAzureMobileServices/WindowsAzureMobileServices.h>
#import "AzureConnection.h"


@interface DrinkTableViewController ()
@property (strong, nonatomic) AzureConnection *azureConnection;
@property (nonatomic) BOOL *selected;
@end

@implementation DrinkTableViewController
@synthesize azureConnection;


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.selected = NO;
    
    // Create the connection to Azure - this creates the Mobile Service client inside the wrapped service
    self.azureConnection = [[AzureConnection alloc] initWithTableName: @"Item"];
    
    //NSPredicate * predicate = [NSPredicate predicateWithFormat:@"venue == %d", venueID];
    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"name == name"];
    
    [self.azureConnection refreshDataOnSuccess:^{
        [self.tableView reloadData];
    } withPredicate:predicate];
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


- (CGFloat) tableView:(UITableView *)tableView
heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.selected != NO) {
        NSLog(@"poke");
        return 44;
    }
    return 88;
}

- (void) tableView: (UITableView *) tableView didSelectRowAtIndexPath: (NSIndexPath *) indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    self.selected = YES;
    [self tableView: tableView heightForRowAtIndexPath: indexPath];
    //cell.frame = CGRectMake(0.0, 44, 320.0, 88);
    cell.textLabel.text = @"CHANGE DAMNIT!";
}


#pragma mark - Table view delegate

-(BOOL) textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

@end
