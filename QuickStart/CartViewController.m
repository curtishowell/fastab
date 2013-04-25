//
//  CartViewController.m
//  QuickStart
//
//  Created by studentuser on 4/11/13.
//  Copyright (c) 2013 Windows Azure. All rights reserved.
//

#import "CartViewController.h"
#import "LineItem.h"
#import "Item.h"
#import "DrinkTypeTVC.h"
#import <Foundation/Foundation.h>
//#import "NSFetchRequest.h"
//#import "CoreDataTableViewController.h"

@interface CartViewController ()

@property (strong, nonatomic) NSDecimalNumber *subtotal;
@property (strong, nonatomic) NSDecimalNumber *tip;
@property (strong, nonatomic) NSDecimalNumber *total;

@property (strong, nonatomic) NSMutableArray *cart; //of LineItems
@property (weak, nonatomic) IBOutlet UILabel *totalLabel;
@property (weak, nonatomic) IBOutlet UILabel *tipLabel;
@property (weak, nonatomic) IBOutlet UILabel *subtotalLabel;
@property (weak, nonatomic) IBOutlet UISegmentedControl *tipControl;
@property (weak, nonatomic) IBOutlet UILabel *barLocation;
@property (weak, nonatomic) IBOutlet UITableView *cartItems;


@end

@implementation CartViewController

@synthesize managedObjectContext;
@synthesize cart;
@synthesize tipControl;
@synthesize tip;
@synthesize subtotal;
@synthesize total;


/*
 //Logic for core data (aka what needs to get done for the core data shit)
 1) Create the Core Data Model
 2) Establish a Table for cartItems
 3) Add in the attributes (item_Name, price, item_Type, Quantity, item_ID)
 4) Create NSManaged Object out of the table
 5) Connect the managed object into this file. 
 6) WORK SOME MAGIC SHIT
    a) Query the local "database" for the content (array of cartItems)
    b) In the "cellForRowAtIndexPath" method, will 
*/



//- (NSMutableArray *)cart
//{
//    if(! _cart){
//        _cart = [[NSMutableArray alloc] init];
//        
//        //put a couple line items in the array
//        [self fillLineItems];
//    }
//    return _cart;
//}

- (void)viewDidLoad
{
    [super viewDidLoad];
    //change the name of the text label *barLocation
    _barLocation.text = self.venue;
    [self initialSetup];
}

- (void)initialSetup {
    //Initializing the subtotal and total content.
    //Change this code later to sum and incorporate the total of items in the cart
    
    subtotal = [NSDecimalNumber decimalNumberWithString:@"0.00"];
    total = [NSDecimalNumber decimalNumberWithString:@"0.00"];
    //_subtotalLabel.text = [NSString stringWithFormat:@"$%@", subtotal];
    //_totalLabel.text = [NSString stringWithFormat:@"$%@", subtotal];
}


- (void)dBConnection {
    //NSURL *docURL = fileURLWithPath;
    //UIManagedDocument *tempDocument = [[UIManagedDocument alloc] initWithFileURL:docURL];
    NSManagedObjectContext *moc = [self managedObjectContext];
    
    NSString *aTitle = _barLocation.text;
    
    /*
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
 
    //NSFetchRequest *request = [[NSFetchRequest fetchRequestWithEntityName:@"ItemInCart"];
    //NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@“title” ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)];
    //request.sortDescriptors = @[sortDescriptor];
 
   
     
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"venueName == %@", aTitle];
    [request setEntity:[NSEntityDescription entityForName:@"ItemInCart" inManagedObjectContext:moc]];
    [request setPredicate:predicate];
    
    NSError *error = nil;
    cart = [moc executeFetchRequest:request error:&error];
    */
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    //Used to get the size of the cart so we know how many rows to make
    //NSInteger *size = [cart count];
    
    //Temporarily creating a predetermined amount
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //This will grab the index/row for the NSIndexPath to be used to find the appropriate value in the array of cartItems.
    //NSInteger spot = indexPath.row;
    
    static NSString *CellIdentifier = @"drinkItem";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    }
    
    cell.textLabel.textColor = [UIColor blackColor];
    
    //need to change the string we send in to objectForKey
    //cell.textLabel.text = [item objectForKey:@"name"];
    
    NSInteger middle = cell.frame.size.width / 2;
    //We change these two quantities to the name and price of the object once we get access to the data model
    cell.detailTextLabel.text = @"$4.99";
    cell.textLabel.text = @"Panda (x1)";
    
    //We change the price here too
    NSDecimalNumber *addToTotal = [NSDecimalNumber decimalNumberWithString:@"4.99"];
    NSDecimalNumber *tempTotal = [addToTotal decimalNumberByAdding: total];
    total = tempTotal;
    subtotal = tempTotal;
    _subtotalLabel.text = [NSString stringWithFormat:@"$%@", tempTotal];
    _totalLabel.text = [NSString stringWithFormat:@"$%@", tempTotal];
    
    
    /*
    //Here is a way to add another view that could potentially hold the text for quantity.
    //However, problem that occurred is that once placed, it stays permanenet, and thus when we scroll, it overalaps with the other "quantity" labels that are placed below lower in the list
    UILabel *labelOne = [[UILabel alloc]initWithFrame:CGRectMake(middle,cell.textLabel.frame.origin.y , 80, 20)];
    labelOne.text = @"Left";
    [cell.contentView addSubview:labelOne];
    */
     
    return cell;
}

- (void)addItemToCart:(Item *)item
{
    for(LineItem *lineItem in cart) {
        if(lineItem.ID == item.ID){
            //item was already in the cart; add 1 to the qty and return
            lineItem.qty += 1;
            return;
        }
        
    }
    
    //item was not already in the cart, so put the data from the Item into a LineItem and add it to the cart
    LineItem *newItem = [[LineItem alloc] init];
    newItem.qty = 1;
    newItem.ID = item.ID;
    newItem.name = item.name;
    newItem.price = item.price;
    newItem.imageURL = item.imageURL;
    newItem.itemType = item.itemType;
    
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

@end
