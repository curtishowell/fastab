#import "DrinkTableViewController.h"
#import <WindowsAzureMobileServices/WindowsAzureMobileServices.h>
#import "AzureConnection.h"
#import "ItemInCart.h"
#import <QuartzCore/QuartzCore.h>


@interface DrinkTableViewController ()
@property (strong, nonatomic) AzureConnection *azureConnection;
@property (nonatomic) BOOL beganUpdates;
@property (strong, nonatomic) NSMutableDictionary *item;

//activity view properties
@property (nonatomic, retain) UIActivityIndicatorView * activityView;
@property (nonatomic, retain) UIView *loadingView;
@property (nonatomic, retain) UILabel *loadingLabel;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *barNameLabel;
@end

@implementation DrinkTableViewController
@synthesize azureConnection;
@synthesize activityView;
@synthesize loadingView;
@synthesize loadingLabel;


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:NO];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self showActivityIndicator];
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    // Create the connection to Azure - this creates the Mobile Service client inside the wrapped service
    self.azureConnection = [[AzureConnection alloc] initWithTableName: @"Item"];
    
    //NSPredicate * predicate = [NSPredicate predicateWithFormat:@"itemType == 1"];
    //NSLog([NSString stringWithFormat:@"item type is %d", self.itemTypeID]);
    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"itemtype == %d", [self.itemTypeID intValue]];
    //NSPredicate * predicate = [NSPredicate predicateWithFormat:@"name == name"];
    
    [self.azureConnection refreshDataOnSuccess:^{
        [self.tableView reloadData];
        [self.loadingView removeFromSuperview];
    } withPredicate:predicate];
    

    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] init];
    barButton.title = self.itemTypeName;
    self.navigationItem.backBarButtonItem = barButton;
    
    //set background color of the tableview to gray
    UIColor *bgColor = [[UIColor alloc] initWithRed:0.22 green:0.22 blue:0.22 alpha:1.0];
    self.tableView.backgroundColor = bgColor;
    
    //header bar name
    self.barNameLabel.text = self.venueName;

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
    static NSString *CellIdentifier = @"drinkItem";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    NSDictionary *item = [self.azureConnection.items objectAtIndex:indexPath.row];

    cell.textLabel.text = [item objectForKey:@"name"];
    
    NSString *itemPriceString = [[item objectForKey:@"price"] stringValue];
    
    NSDecimalNumber *itemPrice = [NSDecimalNumber decimalNumberWithString:itemPriceString];
    NSString* currencyString = [NSNumberFormatter
                                localizedStringFromNumber:itemPrice
                                numberStyle:NSNumberFormatterCurrencyStyle];
    cell.detailTextLabel.text = currencyString;
    
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
        
        UIViewController *checkout = segue.destinationViewController;
        NSString *venuePlace = self.venue;
        
        [checkout performSelector:@selector(setVenueID:)
                                 withObject:self.venueID];
        [checkout performSelector:@selector(setVenueName:)
                                 withObject:self.venueName];
        
    } else if ([segue.identifier isEqualToString:@"addDrinkToCart"]) {
        UITableViewController *cartViewController = segue.destinationViewController;
        
        //get the NSDictionary item realating to the selected indexPath
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        NSDictionary *item = [self.azureConnection.items objectAtIndex:indexPath.row];
        
        //get the values out of the dictionary
        NSNumber *itemID = [item objectForKey:@"id"];
        NSString *itemName = [[item objectForKey:@"name"] description];
        NSNumber *price = [NSDecimalNumber decimalNumberWithString:[[item objectForKey:@"price"] description]];
        
        NSMutableDictionary *itemDictionary = [[NSMutableDictionary alloc] init];
        [itemDictionary setObject:itemID forKey:@"itemID"];
        [itemDictionary setObject:self.itemTypeID forKey:@"itemTypeID"];
        [itemDictionary setObject:itemName forKey:@"itemName"];
        [itemDictionary setObject:price forKey:@"price"];
        [itemDictionary setObject:[NSNumber numberWithInt:1] forKey:@"qty"];
        [itemDictionary setObject:self.venueName forKey:@"venueName"];
        [itemDictionary setObject:self.venueID forKey:@"venueID"];
        
        item = itemDictionary;
        
        
        //set values in the drink type view controller
        [cartViewController performSelector:@selector(setTempItem:)
                           withObject:itemDictionary];
        [cartViewController performSelector:@selector(setVenueID:)
                           withObject:self.venueID];
        [cartViewController performSelector:@selector(setVenueName:)
                           withObject:self.venueName];
        
    }
    
    
}

// Stuff for testing

- (void)setManagedObjectContext:(NSManagedObjectContext *)managedObjectContext {
    
    if(managedObjectContext && !_managedObjectContext) {
        _managedObjectContext = managedObjectContext;
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"ItemInCart"];
        request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"itemID" ascending:YES selector:@selector(compare:)]];
        request.predicate = nil; //TODO: filter to only items for the currently-viewed venue
        self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    } else if(!managedObjectContext && _managedObjectContext) {
        self.fetchedResultsController = nil;
    }
}

- (void)setupManagedDocumentContext {
    if(!self.managedObjectContext){
        NSURL *url = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
        url = [url URLByAppendingPathComponent:@"Cart"];
        UIManagedDocument *document = [[UIManagedDocument alloc] initWithFileURL:url];
        
        if(![[NSFileManager defaultManager] fileExistsAtPath:[url path]]) {
            [document saveToURL:url forSaveOperation:UIDocumentSaveForCreating completionHandler:^(BOOL success) {
                if(success) {
                    self.managedObjectContext = document.managedObjectContext;
                    NSLog(@"successfully set up managed object context");
                    [self addItemToCart];
                    //[self.cartItems reloadData];
                    
                }
            }];
        } else if(document.documentState == UIDocumentStateClosed) {
            [document openWithCompletionHandler:^(BOOL success) {
                self.managedObjectContext = document.managedObjectContext;
                NSLog(@"successfully set up managed object context");
                [self addItemToCart];
                //[self.cartItems reloadData];
                
            }];
        } else {//already open
            self.managedObjectContext = document.managedObjectContext;
            [self addItemToCart];
            //[self.cartItems reloadData];
        }
    }
}

- (void)addItemToCart
{
    NSManagedObjectContext *moc = self.managedObjectContext;
    
    //if there is an object stored in the temp item
    if(self.tempItem){
        
        
        //NSMutableDictionary *item = self.tempItem;
        self.tempItem = nil; //so the temp item is only added to the cart once
        
        //make sure managed document object context is open for writing
        
        //NSManagedObjectContext *moc = [self managedObjectContext];
        
        
        NSFetchRequest *request= [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"ItemInCart" inManagedObjectContext: self.managedObjectContext];
        [request setEntity:entity];
        
        
        //NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"ItemInCart"];
        //request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"itemID" ascending:YES]]; //remove is this is optional- test!
        
        //see if that item is already in the cart
        NSLog(@"itemID is %@", [_item objectForKey:@"itemID"]);
        int temp = [[_item objectForKey:@"itemID"] intValue];
        NSArray *idList = [NSArray arrayWithObjects:[NSNumber numberWithInt:temp], nil];
        //request.predicate = [NSPredicate predicateWithFormat:@"itemID = %@", [item objectForKey:@"itemID"]];
        //request.predicate = [NSPredicate predicateWithFormat:@"itemID == %d", [[item objectForKey:@"itemID"] intValue]];
        request.predicate = [NSPredicate predicateWithFormat:@"itemID IN %@", idList];
        
        NSError *error = nil;
        //self.managedObjectContext
        NSArray *matches = [self.managedObjectContext executeFetchRequest:request error:&error];
        
        
        //LOOOOOKKKK HEERRREEEEEEE!!!!!!!!!!
        
        if (!matches || [matches count] > 1) {
            //handle error?
        } else if (![matches count]){
            //Item doesn't yet exist - add the item to the cart
            
            //
            ItemInCart *cdItem = [NSEntityDescription insertNewObjectForEntityForName:@"ItemInCart"
                                                               inManagedObjectContext:self.managedObjectContext];
            
            cdItem.itemID = [_item objectForKey:@"itemID"];
            cdItem.itemType = [_item objectForKey:@"itemTypeID"];
            cdItem.name = [_item objectForKey:@"itemName"];
            cdItem.price = [_item objectForKey:@"price"];
            cdItem.qty = [_item objectForKey:@"qty"];
            cdItem.venueName = [_item objectForKey:@"venueName"];
            cdItem.venueID = [_item objectForKey:@"venueID"];                        
            
        } else {
            //add 1 to the existingItems's qty
            ItemInCart *existingItem = [matches lastObject];
            int existingQty = [existingItem.qty integerValue];
            int updatedValue = existingQty + 1;
            existingItem.qty = [NSNumber numberWithInt:updatedValue]; 
        }
    }
    NSError *error = nil;
    BOOL success = [self.managedObjectContext save:&error];
    if (!success) {
        // do error handling here.
        NSLog(@"Boo");
    }
    //self.managedObjectContext = moc;
}

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

@end
