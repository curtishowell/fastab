//
//  CartViewController.m
//  QuickStart
//
//  Created by studentuser on 4/11/13.
//  Copyright (c) 2013 Windows Azure. All rights reserved.
//

#import "CartViewController.h"
#import "ItemInCart.h"
#import "DrinkTypeTVC.h"
#import <Foundation/Foundation.h>
#import "AzureConnection.h"

@interface CartViewController ()

@property (strong, nonatomic) NSDecimalNumber *subtotal;
@property (strong, nonatomic) NSDecimalNumber *tip;
@property (strong, nonatomic) NSDecimalNumber *total;

@property (strong, nonatomic) NSMutableArray *cart; //of ItemInCart
@property (weak, nonatomic) IBOutlet UILabel *totalLabel;
@property (weak, nonatomic) IBOutlet UILabel *tipLabel;
@property (weak, nonatomic) IBOutlet UILabel *subtotalLabel;
@property (weak, nonatomic) IBOutlet UISegmentedControl *tipControl;
@property (weak, nonatomic) IBOutlet UILabel *barLocation;
@property (weak, nonatomic) IBOutlet UITableView *cartItems;
@property (nonatomic) BOOL beganUpdates;

//temp
@property (strong, nonatomic) UIManagedDocument *document;

//Azure Connections
@property (strong, nonatomic) AzureConnection *azureOrders;
@property (strong, nonatomic) AzureConnection *azureOrderItems;


- (void)setupManagedDocumentContext;
- (void)addItemToCart;

@end

@implementation CartViewController

@synthesize cart;
@synthesize tipControl;
@synthesize tip;
@synthesize subtotal;
@synthesize total;

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    //[self setupManagedDocumentContext];
    
    if(!self.managedObjectContext) {
        [self setupManagedDocumentContext];
    }
    
    //just to make sure, but should have been setup when the view was loaded

        
}

- (void)setupManagedDocumentContext {
    if(!self.managedObjectContext){
        NSURL *url = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
        url = [url URLByAppendingPathComponent:@"Cart"];
        // UIManagedDocument *document = [[UIManagedDocument alloc] initWithFileURL:url];
        _document = [[UIManagedDocument alloc] initWithFileURL:url];
        
        if(![[NSFileManager defaultManager] fileExistsAtPath:[url path]]) {
            [_document saveToURL:url forSaveOperation:UIDocumentSaveForCreating completionHandler:^(BOOL success) {
                if(success) {
                    self.managedObjectContext = _document.managedObjectContext;
                    NSLog(@"successfully set up managed object context");
                    [self addItemToCart];
                    //[self.cartItems reloadData];
                    
                }
            }];
        } else if(_document.documentState == UIDocumentStateClosed) {
            [_document openWithCompletionHandler:^(BOOL success) {
                self.managedObjectContext = _document.managedObjectContext;
                NSLog(@"successfully set up managed object context");
                [self addItemToCart];
                //[self.cartItems reloadData];
                
            }];
        } else {//already open
            self.managedObjectContext = _document.managedObjectContext;
            [self addItemToCart];
            //[self.cartItems reloadData];
        }
    }
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    //change the name of the text label *barLocation
    _barLocation.text = self.venueName;
    [self initialSetup];
}

- (void)setManagedObjectContext:(NSManagedObjectContext *)managedObjectContext {
    
    if(managedObjectContext && !_managedObjectContext) {
        _managedObjectContext = managedObjectContext;
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"ItemInCart"];
        request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"itemID" ascending:YES selector:@selector(compare:)]];
        
        request.predicate = [NSPredicate predicateWithFormat:@"venueID = %d", [self.venueID intValue]];
        //request.predicate = nil; //TODO: filter to only items for the currently-viewed venue
        
        self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                            managedObjectContext:managedObjectContext
                                                                              sectionNameKeyPath:nil
                                                                                       cacheName:nil];
    } else if(!managedObjectContext && _managedObjectContext) {
        self.fetchedResultsController = nil;
    }
}

- (void)initialSetup {
    //Initializing the subtotal and total content.
    //Change this code later to sum and incorporate the total of items in the cart
    
    self.subtotal = [NSDecimalNumber decimalNumberWithString:@"0.00"];
    self.tip = [NSDecimalNumber decimalNumberWithString:@"0.00"];
    self.total = [NSDecimalNumber decimalNumberWithString:@"0.00"];
    //_subtotalLabel.text = [NSString stringWithFormat:@"$%@", subtotal];
    //_totalLabel.text = [NSString stringWithFormat:@"$%@", subtotal];
}



- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"drinkItem"];
    
    ItemInCart *itemInCart = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    NSString *tempItemName = itemInCart.name;
    NSString *tempItemdesc = [itemInCart.qty stringValue];
    
    //Set the labels for each table cell
    cell.textLabel.text = itemInCart.name;
    cell.detailTextLabel.text = [itemInCart.qty stringValue];
    NSDecimalNumber *drinkRowPrice = itemInCart.price;
    NSDecimalNumber *drinkRowQuantity = [NSDecimalNumber decimalNumberWithString:[itemInCart.qty stringValue]];
    NSDecimalNumber *drinkRowTotal = [drinkRowPrice decimalNumberByMultiplyingBy: drinkRowQuantity];
    NSDecimalNumber *tempTotal = [drinkRowTotal decimalNumberByAdding: total];
    total = tempTotal;
    subtotal = tempTotal;
    _subtotalLabel.text = [NSString stringWithFormat:@"$%@", tempTotal];
    _totalLabel.text = [NSString stringWithFormat:@"$%@", tempTotal];
         
    return cell;
}

- (void)addItemToCart
{
    NSManagedObjectContext *moc = self.managedObjectContext;
    
    //if there is an object stored in the temp item
    if(self.tempItem){
        
    
        NSMutableDictionary *item = self.tempItem;
        self.tempItem = nil; //so the temp item is only added to the cart once
        
        //make sure managed document object context is open for writing
        
        //NSManagedObjectContext *moc = [self managedObjectContext];
        
        
        NSFetchRequest *request= [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"ItemInCart" inManagedObjectContext: moc];
        [request setEntity:entity];
        
        
        //NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"ItemInCart"];
        //request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"itemID" ascending:YES]]; //remove is this is optional- test!
        
        //see if that item is already in the cart
        NSLog(@"itemID is %@", [item objectForKey:@"itemID"]);
        int temp = [[item objectForKey:@"itemID"] intValue];
        NSArray *idList = [NSArray arrayWithObjects:[NSNumber numberWithInt:temp], nil];
        //request.predicate = [NSPredicate predicateWithFormat:@"itemID = %@", [item objectForKey:@"itemID"]];
        //request.predicate = [NSPredicate predicateWithFormat:@"itemID == %d", [[item objectForKey:@"itemID"] intValue]];
        request.predicate = [NSPredicate predicateWithFormat:@"itemID IN %@", idList];
        
        NSError *error = nil;
        //self.managedObjectContext
        NSArray *matches = [moc executeFetchRequest:request error:&error];
        
        
        //LOOOOOKKKK HEERRREEEEEEE!!!!!!!!!!
        
        if (!matches || [matches count] > 1) {
            //handle error?
        } else if (![matches count]){
            //Item doesn't yet exist - add the item to the cart
            
            //
            ItemInCart *cdItem = [NSEntityDescription insertNewObjectForEntityForName:@"ItemInCart"
                                                               inManagedObjectContext:self.managedObjectContext];

            cdItem.itemID = [item objectForKey:@"itemID"];
            cdItem.itemType = [item objectForKey:@"itemTypeID"];
            cdItem.name = [item objectForKey:@"itemName"];
            cdItem.price = [item objectForKey:@"price"];
            cdItem.qty = [item objectForKey:@"qty"];
            cdItem.venueName = [item objectForKey:@"venueName"];
            cdItem.venueID = [item objectForKey:@"venueID"];
            
            int matchesCount = [matches count];
            
        } else {
            //add 1 to the existingItems's qty
            ItemInCart *existingItem = [matches lastObject];
            int existingQty = [existingItem.qty integerValue];
            int updatedValue = existingQty + 1;
            existingItem.qty = [NSNumber numberWithInt:updatedValue]; //make sure this is updating the object in the core data cart
            int temp = [existingItem.qty integerValue];
        }
    }
    
    //THE MONEY RIGHT HERE!!!!
    
    //soooooo sexy
    
    [_document saveToURL:_document.fileURL
            forSaveOperation:UIDocumentSaveForOverwriting
           completionHandler:^(BOOL success) {
               if (success) {
                   NSLog(@"saved");
               } else {
                   NSLog(@"unable to save");
               }
           }];
    
    /*
    // NEVER USE THIS THING AGAIN
    NSError *error = nil;
    BOOL success = [moc save:&error];
    if (!success) {
        // do error handling here.
        NSLog(@"Boo");
    }
    self.managedObjectContext = moc;
    */
}

- (IBAction)tipChange:(UISegmentedControl *)sender {
    tipControl = sender;
    [self setTipAndTotal];
}

- (void) setTipAndTotal {
    // user has selected a pre-defined tip amount
    // currently the segmented control has only 3 choices
    // Can add in the custom element later on
    if(tipControl.selectedSegmentIndex < 3){
        
        //temp!
        //this will be commented out later when we figure out how to total
        //up the content in the shopping cart
        //subtotal = [NSDecimalNumber decimalNumberWithString:@"4.69"];
        
        NSInteger *index = tipControl.selectedSegmentIndex;
        NSDecimalNumber *tipPercent = [NSDecimalNumber decimalNumberWithString:[NSString stringWithFormat:@"%@",[self tipPercentages:(NSInteger)index]]];
        
        // define the handler for how to round the NSDecimalNumbers
        NSDecimalNumberHandler *handler = [NSDecimalNumberHandler decimalNumberHandlerWithRoundingMode:NSRoundPlain
                                                                                                 scale:2
                                                                                      raiseOnExactness:NO
                                                                                       raiseOnOverflow:NO
                                                                                      raiseOnUnderflow:NO
                                                                                   raiseOnDivideByZero:NO];
        tip = [tipPercent decimalNumberByMultiplyingBy:subtotal withBehavior:handler];
        total = [subtotal decimalNumberByAdding:tip];
        
        //set the tip and total amounts
        _subtotalLabel.text = [NSString stringWithFormat:@"$%@", subtotal];
        _tipLabel.text = [NSString stringWithFormat:@"$%@", tip];
        _totalLabel.text = [NSString stringWithFormat:@"$%@",total];
    }
}

- (NSArray *)tipPercentages:(NSInteger *)index {
    static NSArray *tipPercentages = nil;
    NSDecimalNumber *index0 = [NSDecimalNumber decimalNumberWithString:@"0.0"];
    NSDecimalNumber *index1 = [NSDecimalNumber decimalNumberWithString:@"0.15"];
    NSDecimalNumber *index2 = [NSDecimalNumber decimalNumberWithString:@"0.20"];
    tipPercentages = @[index0, index1, index2];
    return [tipPercentages objectAtIndex:index];
}




- (IBAction)sendOrder:(id)sender {
    
    //TODO: make sure user is logged in and has a Stripe user ID in their account
    
    //TODO: add progress spinning UI
    
    
    // Create the connections to Azure - this creates the Mobile Service client inside the wrapped service
    self.azureOrders = [[AzureConnection alloc] initWithTableName: @"Order"];
    self.azureOrderItems = [[AzureConnection alloc] initWithTableName: @"OrderItem"];
    
    
    NSDictionary *order = @{ @"status" : @"placed", @"subtotal" : self.subtotal, @"tip" : self.tip, @"total" : self.total, @"venueID" : self.venueID };
	
	UIViewController *viewController = self; //used fore segueing
	
    [self.azureOrders addItem:order completion:^(NSUInteger index){
        
        //TODO: kill progress and connection UIs
        
		NSLog(@"Order successfully created");
        
        int orderItemsCount = [[[self.fetchedResultsController sections] objectAtIndex:0] numberOfObjects];
        
        NSNumber *orderNumber = [[self.azureOrders.items objectAtIndex:index] objectForKey:@"id"];
        
        for(int i = 0; i < orderItemsCount; i ++) {
            
            
            
            NSLog(@"building 1 orderItem");
            
            //ItemInCart *itemInCart = [[[self.fetchedResultsController sections] objectAtIndex:0] objectAtIndex:i];
            
            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:i inSection:0];
            
            ItemInCart *itemInCart = [self.fetchedResultsController objectAtIndexPath:indexPath];
            
            NSDictionary *orderItem = @{ @"orderID" : orderNumber, @"itemID" : itemInCart.itemID, @"qty" : itemInCart.qty, @"price" : itemInCart.price };
            
            [self.azureOrderItems addItem:orderItem completion:^(NSUInteger index){
                NSLog(@"saved 1 orderItem");
            }];
            
        }
        
        
 

        
        
        
        
		//when all orderitems have been added successfully, segoe to the waiting for order view
//		dispatch_async(dispatch_get_main_queue(), ^{
//			[viewController performSegueWithIdentifier:@"PaymentToBarList" sender:viewController];
//		});
        
        
    }];

    
    //TODO: create order
    
    //TODO: add orderItems once we have the order #
    
    //TODO: success- take to waiting for item page
    

}



/*
- (void) fillLineItems
{
    LineItem *l1 = [[LineItem alloc] init];
    l1.ID = 1;
    l1.name = @"Manny's";
    l1.price = 5;
    l1.qty = 1;
    
    LineItem *l2 = [[LineItem alloc] init];
    l2.ID = 2;
    l2.name = @"Mack & Jack's";
    l2.price = 4;
    l2.qty = 2;
    
    
    [cart addObject:l1];
    [cart addObject:l2];
    
}
*/

/*logic to add a line item
 if the id exists in the cart
 add the qty to the qty of the correspondig line item in the cart
 else
 add the line item to the cart
 */



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
    [self.cartItems reloadData];
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
            [self.cartItems reloadData];
        }
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[[self.fetchedResultsController sections] objectAtIndex:section] numberOfObjects];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	return [[[self.fetchedResultsController sections] objectAtIndex:section] name];
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
	return [self.fetchedResultsController sectionForSectionIndexTitle:title atIndex:index];
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    return [self.fetchedResultsController sectionIndexTitles];
}

#pragma mark - NSFetchedResultsControllerDelegate

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    if (!self.suspendAutomaticTrackingOfChangesInManagedObjectContext) {
        [self.cartItems beginUpdates];
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
            case NSFetchedResultsChangeInsert:
                [self.cartItems insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
                break;
                
            case NSFetchedResultsChangeDelete:
                [self.cartItems deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
                break;
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
        }
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    if (self.beganUpdates) [self.cartItems endUpdates];
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
