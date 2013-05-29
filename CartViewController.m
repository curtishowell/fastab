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
#import "QuartzCore/QuartzCore.h"
#import "ActionSheetPicker.h"
#import "ActionSheetStringPicker.h"
#import "OrderFulfillmentViewController.h"

@interface CartViewController ()

@property (strong, nonatomic) NSDecimalNumber *subtotal;
@property (strong, nonatomic) NSDecimalNumber *tip;
@property (strong, nonatomic) NSDecimalNumber *total;

@property (weak, nonatomic) IBOutlet UILabel *totalLabel;
@property (weak, nonatomic) IBOutlet UISegmentedControl *tipControl;
@property (weak, nonatomic) IBOutlet UITableView *cartItems;
@property (nonatomic) BOOL beganUpdates;
@property (strong, nonatomic) NSNumber *orderNumbo;

//temp
@property (strong, nonatomic) UIManagedDocument *document;

//Azure Connections
@property (strong, nonatomic) AzureConnection *azureOrders;
@property (strong, nonatomic) AzureConnection *azureOrderItems;

//activity view properties
@property (nonatomic, retain) UIActivityIndicatorView * activityView;
@property (nonatomic, retain) UIView *loadingView;
@property (nonatomic, retain) UILabel *loadingLabel;

//managed object context
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;


- (void)setupManagedDocumentContext;
- (void)addItemToCart;
- (void)clearCart;
- (void)completeOrder;
- (void)saveManagedObjectContext;
- (void)calculateSubtotal;

@end

@implementation CartViewController

//@synthesize cart;
@synthesize tipControl;
@synthesize tip;
@synthesize subtotal;
@synthesize total;
@synthesize activityView;
@synthesize loadingLabel;
@synthesize loadingView;

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
                    
                }
            }];
        } else if(_document.documentState == UIDocumentStateClosed) {
            [_document openWithCompletionHandler:^(BOOL success) {
                self.managedObjectContext = _document.managedObjectContext;
                NSLog(@"successfully set up managed object context");
                [self addItemToCart];
                
            }];
        } else {//already open
            self.managedObjectContext = _document.managedObjectContext;
            [self addItemToCart];
        }
    }
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    //change the name of the text label *barLocation
    self.navigationItem.title = self.venueName;
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

    [self setTipAndTotal];
    
}



- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"drinkItem"];
    
    ItemInCart *itemInCart = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    //Set the labels for each table cell OLD, NON-CUSTOM CELLS
    //cell.textLabel.text = itemInCart.name;
    //cell.detailTextLabel.text = [itemInCart.qty stringValue];
    
    
    NSDecimalNumber *drinkRowPrice = itemInCart.price;
    NSDecimalNumber *drinkRowQuantity = [NSDecimalNumber decimalNumberWithString:[itemInCart.qty stringValue]];
    NSDecimalNumber *drinkRowTotal = [drinkRowPrice decimalNumberByMultiplyingBy: drinkRowQuantity];
//    NSDecimalNumber *tempTotal = [drinkRowTotal decimalNumberByAdding: total];
    
    
    //set labels in the cell using the custom cell
    UILabel *label;
    label = (UILabel *)[cell viewWithTag:1];
    label.text = [NSString stringWithFormat:@"%@", itemInCart.name];
    
    
    NSString *unitPrice = [NSNumberFormatter
                                localizedStringFromNumber:itemInCart.price
                                numberStyle:NSNumberFormatterCurrencyStyle];
    label = (UILabel *)[cell viewWithTag:2];
    label.text = [NSString stringWithFormat:@"%@ @ %@", itemInCart.qty, unitPrice];
    
    NSString *lineItemTotal = [NSNumberFormatter
                                localizedStringFromNumber:drinkRowTotal
                                numberStyle:NSNumberFormatterCurrencyStyle];
    label = (UILabel *)[cell viewWithTag:3];
    label.text = [NSString stringWithFormat:@"%@", lineItemTotal];

    [self setTipAndTotal];
         
    return cell;
}

- (void)setItemQty:(NSArray *)itemAndQty
{
    NSLog(@"setting item and qty");
    NSNumber *newQty = itemAndQty[0];
    ItemInCart *item = itemAndQty[1];
    
    item.qty = newQty;
    
    [self saveManagedObjectContext];
    //also update subtotal and tip
}

//user clicks on a line item in the cart to adjust the quantity
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UIView *sender = self.view;
    
    ActionStringCancelBlock cancel = ^(ActionSheetStringPicker *picker) {
        NSLog(@"Block Picker Canceled");
    };
    NSArray *numbers = [NSArray arrayWithObjects:@"0", @"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9", @"10", @"11", @"12", @"13", @"14", @"15", @"16", @"17", @"18", @"19", @"20", nil];
    
    //get qty and item name out of
    ItemInCart *selectedItem = [self.fetchedResultsController objectAtIndexPath:indexPath];
    NSNumber *currentQty = selectedItem.qty;
    NSString *itemName = selectedItem.name;
    NSString *prompt = [NSString stringWithFormat:@"# of %@", itemName];
    
    ActionStringDoneBlock done = ^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue) {
        NSNumber *newQty = [NSNumber numberWithInt:selectedIndex];
        NSArray *itemAndQty = [NSArray arrayWithObjects:newQty, selectedItem, nil];
        [self performSelector:@selector(setItemQty:) withObject:itemAndQty];
    };
    
    [ActionSheetStringPicker showPickerWithTitle:prompt rows:numbers initialSelection:[currentQty integerValue] doneBlock:done cancelBlock:cancel origin:sender];
}


- (void)addItemToCart
{
    NSManagedObjectContext *moc = self.managedObjectContext;
    
    //if there is an object stored in the temp item
    if(self.tempItem){
        
    
        NSMutableDictionary *item = self.tempItem;
        self.tempItem = nil; //so the temp item is only added to the cart once
        
        
        NSFetchRequest *request= [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"ItemInCart" inManagedObjectContext: moc];
        [request setEntity:entity];
        
        //see if that item is already in the cart
        NSLog(@"itemID is %@", [item objectForKey:@"itemID"]);
        int temp = [[item objectForKey:@"itemID"] intValue];
        NSArray *idList = [NSArray arrayWithObjects:[NSNumber numberWithInt:temp], nil];

        request.predicate = [NSPredicate predicateWithFormat:@"itemID IN %@", idList];
        
        NSError *error = nil;
        //self.managedObjectContext
        NSArray *matches = [moc executeFetchRequest:request error:&error];
        
                
        if (!matches || [matches count] > 1) {
            //handle error?
        } else if (![matches count]){
            //Item doesn't yet exist - add the item to the cart
            
            ItemInCart *cdItem = [NSEntityDescription insertNewObjectForEntityForName:@"ItemInCart"
                                                               inManagedObjectContext:self.managedObjectContext];

            cdItem.itemID = [item objectForKey:@"itemID"];
            cdItem.itemType = [item objectForKey:@"itemTypeID"];
            cdItem.name = [item objectForKey:@"itemName"];
            cdItem.price = [item objectForKey:@"price"];
            cdItem.qty = [item objectForKey:@"qty"];
            cdItem.venueName = [item objectForKey:@"venueName"];
            cdItem.venueID = [item objectForKey:@"venueID"];
            
            
        } else {
            //add 1 to the existingItems's qty
            ItemInCart *existingItem = [matches lastObject];
            int existingQty = [existingItem.qty integerValue];
            int updatedValue = existingQty + 1;
            existingItem.qty = [NSNumber numberWithInt:updatedValue];
        }
    }
        
    [self saveManagedObjectContext];
    
}

- (void)saveManagedObjectContext {
    [self.document saveToURL:self.document.fileURL
            forSaveOperation:UIDocumentSaveForOverwriting
           completionHandler:^(BOOL success) {
               if (success) {
                   NSLog(@"saved");
               } else {
                   NSLog(@"unable to save");
               }
           }];
}

- (IBAction)tipChange:(UISegmentedControl *)sender {
    //tipControl = sender;
    [self setTipAndTotal];
}

- (void) setTipAndTotal {
    // user has selected a pre-defined tip amount
    // currently the segmented control has only 4 choices
    // Can add in the custom element later on
    if(tipControl.selectedSegmentIndex < 4){
        
        [self calculateSubtotal];
        
        
        NSInteger *index = tipControl.selectedSegmentIndex;
        NSDecimalNumber *tipPercent = [NSDecimalNumber decimalNumberWithString:[NSString stringWithFormat:@"%@",[self tipPercentages:(NSInteger)index]]];
        
        // define the handler for how to round the NSDecimalNumbers
        NSDecimalNumberHandler *handler = [NSDecimalNumberHandler decimalNumberHandlerWithRoundingMode:NSRoundPlain
                                                                                                 scale:2
                                                                                      raiseOnExactness:NO
                                                                                       raiseOnOverflow:NO
                                                                                      raiseOnUnderflow:NO
                                                                                   raiseOnDivideByZero:NO];
        self.tip = [tipPercent decimalNumberByMultiplyingBy:subtotal withBehavior:handler];
        self.total = [subtotal decimalNumberByAdding:self.tip];
        
        //set the tip and total amounts
        NSString* currencyString = [NSNumberFormatter
                                    localizedStringFromNumber:total
                                    numberStyle:NSNumberFormatterCurrencyStyle];
        
        self.totalLabel.text = [NSString stringWithFormat:@"%@",currencyString];
    }
}

- (void)calculateSubtotal {
    
    NSDecimalNumber *tempSubtotal = [NSDecimalNumber decimalNumberWithString:@"0.0"];
    for(ItemInCart *item in [[self fetchedResultsController] fetchedObjects]){
        NSDecimalNumber *itemPrice = item.price;
        NSDecimalNumber *itemQty = [NSDecimalNumber decimalNumberWithString: [item.qty stringValue]];
        NSDecimalNumber *lineItemSubtotal = [itemPrice decimalNumberByMultiplyingBy:itemQty];
        tempSubtotal = [tempSubtotal decimalNumberByAdding:lineItemSubtotal];
    }
    
    self.subtotal = tempSubtotal;
}

- (NSArray *)tipPercentages:(NSInteger *)index {
    static NSArray *tipPercentages = nil;
    NSDecimalNumber *index0 = [NSDecimalNumber decimalNumberWithString:@"0.0"];
    NSDecimalNumber *index1 = [NSDecimalNumber decimalNumberWithString:@"0.15"];
    NSDecimalNumber *index2 = [NSDecimalNumber decimalNumberWithString:@"0.20"];
    NSDecimalNumber *index3 = [NSDecimalNumber decimalNumberWithString:@"0.25"];
    tipPercentages = @[index0, index1, index2, index3];
    return [tipPercentages objectAtIndex:index];
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
    loadingLabel.text = @"Sending...";
    [loadingView addSubview:loadingLabel];
	
    [self.view addSubview:loadingView];
    [activityView startAnimating];
}


- (IBAction)sendOrder:(id)sender {
    
    //TODO: make sure user is logged in
    
    
    // Create the connections to Azure - this creates the Mobile Service client inside the wrapped service
    self.azureOrders = [[AzureConnection alloc] initWithTableName: @"Order"];
    
    MSClient *azureClient = self.azureOrders.client;
    
    if(azureClient.currentUser == nil){
        
        [azureClient loginWithProvider:@"facebook"
                          onController:self
                              animated:YES
                            completion:^(MSUser *user, NSError *error) {
                                
                                if(!user || error){             //error logging in or user cancelled- recurse to force auth
                                    
                                    [self sendOrder:sender];
                                    return;
                                    
                                } else {                        //success logging in
                                    
                                    [self.azureOrders storeUserCredentials];
                                    
                                    [self completeOrder];
                                }
                                
                            }];
    } else {
        [self completeOrder];
        
    }
}

//note- must ensure that the user is authenticated before calling this method
- (void)completeOrder {
    
    [self showActivityIndicator];
    
    self.azureOrderItems = [[AzureConnection alloc] initWithTableName: @"OrderItem"];
    
    
    //TODO: make sure user has a Stripe user ID in their account (should be obscured in azure so stripe id isn't flying around). if not, prompt user to add CC
    
    
    NSDictionary *order = @{ @"status" : @"adding-order-items", @"subtotal" : self.subtotal, @"tip" : self.tip, @"total" : self.total, @"venueID" : self.venueID };
    
    CartViewController *viewController = self; //used fore segueing
    UIView *loadingAnimation = self.loadingView;
    
    [self.azureOrders addItem:order completion:^(NSUInteger orderIndex){
        
        //TODO: kill progress and connection UIs
        
        NSLog(@"Order successfully created");
        
        int orderItemsCount = [[[self.fetchedResultsController sections] objectAtIndex:0] numberOfObjects];
        
        NSNumber *orderNumber = [[self.azureOrders.items objectAtIndex:orderIndex] objectForKey:@"id"];
        
        //Pass along the order number to the OrderFulfillmentViewController
        //NEED TO DO STUFF HERE! **Patrick 5/23
        self.orderNumbo = orderNumber;
        
        
        __block int successfulOrderItemCount = 0;
        
        for(int i = 0; i < orderItemsCount; i ++) {
            
            NSLog(@"building 1 orderItem");
            
            //ItemInCart *itemInCart = [[[self.fetchedResultsController sections] objectAtIndex:0] objectAtIndex:i];
            
            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:i inSection:0];
            
            ItemInCart *itemInCart = [self.fetchedResultsController objectAtIndexPath:indexPath];
            
            NSDictionary *orderItem = @{ @"orderID" : orderNumber, @"itemID" : itemInCart.itemID, @"qty" : itemInCart.qty, @"price" : itemInCart.price };
            
            [self.azureOrderItems addItem:orderItem completion:^(NSUInteger orderItemIndex){
                NSLog(@"saved 1 orderItem");
                
                //increment countergi
                successfulOrderItemCount ++;
                
                //when the last Azure operation has completed, update the status of the order then segue to the next view
                if(successfulOrderItemCount == orderItemsCount){
                    
                    NSDictionary *original = [viewController.azureOrders.items objectAtIndex:orderIndex];
                    NSMutableDictionary *modified = [original mutableCopy];
                    
                    [modified setObject:@"payment-needs-processing" forKey:@"status"];
                    
                    [self.azureOrders modifyItem:modified original:original completion:^(NSUInteger index) {
                        [viewController clearCart];
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [loadingAnimation removeFromSuperview];
                            [self.navigationController setNavigationBarHidden:YES animated:YES];
                            [viewController performSegueWithIdentifier:@"cartToOrderFulfillment" sender:viewController];
                        });
                    }];
                }
            }];
            
        }
    }];

}

- (void)prepareForSegue:(UIStoryboardSegue *)segue
                 sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"cartToOrderFulfillment"]) {
        UIViewController *fulfillOrder = segue.destinationViewController;
        NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
        [standardUserDefaults setValue:self.orderNumbo forKey:@"orderNumber"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [fulfillOrder performSelector:@selector(setOrderNum:)
                           withObject:self.orderNumbo];
    }
}

- (void)clearCart {
    
    for(NSManagedObject *item in [[self fetchedResultsController] fetchedObjects]){
        [self.managedObjectContext deleteObject:item];
    }
    [self saveManagedObjectContext];
    [self setTipAndTotal];
    [self.tipControl setSelectedSegmentIndex:2];
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
