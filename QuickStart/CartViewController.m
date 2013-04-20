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

@interface CartViewController ()

@property (strong, nonatomic) NSDecimalNumber *subtotal;
@property (strong, nonatomic) NSDecimalNumber *tip;
@property (strong, nonatomic) NSDecimalNumber *total;

@property (strong, nonatomic) NSMutableArray *cart; //of LineItems
@property (weak, nonatomic) IBOutlet UILabel *totalLabel;
@property (weak, nonatomic) IBOutlet UILabel *tipLabel;
@property (weak, nonatomic) IBOutlet UILabel *subtotalLabel;
@property (weak, nonatomic) IBOutlet UISegmentedControl *tipControl;


@end

@implementation CartViewController

@synthesize cart;
@synthesize tipControl;
@synthesize tip;
@synthesize subtotal;
@synthesize total;

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
    [self setTipAndTotal];
}

- (void) setTipAndTotal {
    // user has selected a pre-defined tip amount
    if(tipControl.selectedSegmentIndex < 3){
        
        //temp!
        subtotal = [NSDecimalNumber numberWithInt:5];
        
        NSDecimalNumber *tipPercent = [self tipPercentages][tipControl.selectedSegmentIndex];
        tip = [tipPercent decimalNumberByMultiplyingBy:subtotal];
        total = [subtotal decimalNumberByAdding:tip];
        
        //set the tip and total amounts
        _subtotalLabel.text = [NSString stringWithFormat:@"%@", subtotal];
    }
}

- (NSArray *)tipPercentages {
    static NSArray *tipPercentages = nil;
    tipPercentages = @[@0, @.15, @.2];
    return tipPercentages;
}

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

/*logic to add a line item
 if the id exists in the cart
 add the qty to the qty of the correspondig line item in the cart
 else
 add the line item to the cart
 */

@end
