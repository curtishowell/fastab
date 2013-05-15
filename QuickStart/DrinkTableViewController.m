#import "DrinkTableViewController.h"
#import <WindowsAzureMobileServices/WindowsAzureMobileServices.h>
#import "AzureConnection.h"
#import "ItemInCart.h"


@interface DrinkTableViewController ()
@property (strong, nonatomic) AzureConnection *azureConnection;
@property (nonatomic) BOOL beganUpdates;
@property (strong, nonatomic) NSMutableDictionary *item;
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
    
    //set background color of the tableview to gray
    UIColor *bgColor = [[UIColor alloc] initWithRed:0.22 green:0.22 blue:0.22 alpha:1.0];
    self.tableView.backgroundColor = bgColor;

}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
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

/*************from CoreDataTableViewController.m*/
@synthesize fetchedResultsController = _fetchedResultsController;
@synthesize suspendAutomaticTrackingOfChangesInManagedObjectContext = _suspendAutomaticTrackingOfChangesInManagedObjectContext;
@synthesize debug = _debug;
@synthesize beganUpdates = _beganUpdates;

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

#pragma mark - Fetching

- (void)performFetch
{
    if (self.fetchedResultsController) {
        if (self.fetchedResultsController.fetchRequest.predicate) {
            if (self.debug) NSLog(@"[%@ %@] fetching %@ with predicate: %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), self.fetchedResultsController.fetchRequest.entityName, self.fetchedResultsController.fetchRequest.predicate);
        } else {
            if (self.debug) NSLog(@"[%@ %@] fetching all %@ (i.e., no predicate)", NSStringFromClass([self class]), NSStringFromSelector(_cmd), self.fetchedResultsController.fetchRequest.entityName);
        }
        NSError *error;
        [self.fetchedResultsController performFetch:&error];
        if (error) NSLog(@"[%@ %@] %@ (%@)", NSStringFromClass([self class]), NSStringFromSelector(_cmd), [error localizedDescription], [error localizedFailureReason]);
    } else {
        if (self.debug) NSLog(@"[%@ %@] no NSFetchedResultsController (yet?)", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    }
    //[self.cartItems reloadData];
}

- (void)setFetchedResultsController:(NSFetchedResultsController *)newfrc
{
    NSFetchedResultsController *oldfrc = _fetchedResultsController;
    if (newfrc != oldfrc) {
        _fetchedResultsController = newfrc;
        newfrc.delegate = self;
        if ((!self.title || [self.title isEqualToString:oldfrc.fetchRequest.entity.name]) && (!self.navigationController || !self.navigationItem.title)) {
            self.title = newfrc.fetchRequest.entity.name;
        }
        if (newfrc) {
            if (self.debug) NSLog(@"[%@ %@] %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), oldfrc ? @"updated" : @"set");
            [self performFetch];
        } else {
            if (self.debug) NSLog(@"[%@ %@] reset to nil", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
            //[self.cartItems reloadData];
        }
    }
}

#pragma mark - NSFetchedResultsControllerDelegate

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    if (!self.suspendAutomaticTrackingOfChangesInManagedObjectContext) {
        //[self.cartItems beginUpdates];
        self.beganUpdates = YES;
    }
}

- (void)controller:(NSFetchedResultsController *)controller
  didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
		   atIndex:(NSUInteger)sectionIndex
	 forChangeType:(NSFetchedResultsChangeType)type
{
    if (!self.suspendAutomaticTrackingOfChangesInManagedObjectContext)
    {
        switch(type)
        {
            /*
            case NSFetchedResultsChangeInsert:
                [self.cartItems insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
                break;
                
            case NSFetchedResultsChangeDelete:
                [self.cartItems deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
                break;
            */ 
        }
    }
}


- (void)controller:(NSFetchedResultsController *)controller
   didChangeObject:(id)anObject
	   atIndexPath:(NSIndexPath *)indexPath
	 forChangeType:(NSFetchedResultsChangeType)type
	  newIndexPath:(NSIndexPath *)newIndexPath
{
    if (!self.suspendAutomaticTrackingOfChangesInManagedObjectContext)
    {
        switch(type)
        {
            /*
            case NSFetchedResultsChangeInsert:
                [self.cartItems insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
                break;
                
            case NSFetchedResultsChangeDelete:
                [self.cartItems deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
                break;
                
            case NSFetchedResultsChangeUpdate:
                [self.cartItems reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
                break;
                
            case NSFetchedResultsChangeMove:
                [self.cartItems deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
                [self.cartItems insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
                break;
            */
        }
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    //if (self.beganUpdates) [self.cartItems endUpdates];
}

- (void)endSuspensionOfUpdatesDueToContextChanges
{
    _suspendAutomaticTrackingOfChangesInManagedObjectContext = NO;
}

- (void)setSuspendAutomaticTrackingOfChangesInManagedObjectContext:(BOOL)suspend
{
    if (suspend) {
        _suspendAutomaticTrackingOfChangesInManagedObjectContext = YES;
    } else {
        [self performSelector:@selector(endSuspensionOfUpdatesDueToContextChanges) withObject:0 afterDelay:0];
    }
}


@end
