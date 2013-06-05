//
//  OrderFulfillmentViewController.m
//  QuickStart
//
//  Created by Curtis Howell on 5/11/13.
//  Copyright (c) 2013 Windows Azure. All rights reserved.
//

#import "OrderFulfillmentViewController.h"
#import "AzureConnection.h"
#import <AudioToolbox/AudioServices.h>

@interface OrderFulfillmentViewController ()

@property (strong, nonatomic) AzureConnection *azureOrder;

@property (nonatomic, weak) IBOutlet UILabel *titleLabel;
@property (nonatomic, weak) IBOutlet UILabel *subtitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *keyWord;
@property (weak, nonatomic) IBOutlet UILabel *pickUpMessage;
@property (weak, nonatomic) IBOutlet UILabel *toPickupSubtitle;
@property (weak, nonatomic) IBOutlet UIImageView *keywordBG;
@property (weak, nonatomic) IBOutlet UILabel *readyForPickup;

@end

@implementation OrderFulfillmentViewController

@synthesize orderNum;
@synthesize titleLabel;
@synthesize subtitleLabel;
@synthesize keyWord;
@synthesize pickUpMessage;
@synthesize toPickupSubtitle;


- (void)viewDidLoad
{
    [super viewDidLoad];
    NSLog(@"This order number is%@", orderNum);
    [self connectToAzure];
}

- (void)connectToAzure
{
    self.azureOrder = [[AzureConnection alloc] initWithTableName: @"Order"];
    //orderNum = [NSNumber numberWithInt:[orderNum intValue] - 1];
    
    /*
    if (self.orderNum == nil) {
        NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
        self.orderNum = [NSNumber numberWithInt:[standardUserDefaults integerForKey:@"orderNumber"]];
    }
     */
    
    int orderNumber = [self.orderNum  intValue];
    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"id == %d", orderNumber];
    [self.azureOrder refreshDataOnSuccess:^{
        NSLog(@"successfully refreshed table");
        //NSArray *temp = self.azureOrder.items;
        NSLog(@"Number items%lu ",(unsigned long)[self.azureOrder.items count] );
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadViewData) name:@"ReloadAppDelegateTable" object:nil];
        [self checkOrderStatus];
    } withPredicate:predicate];
    
}

- (void)reloadViewData {
    NSLog(@"Reloading OrderFulFillment Page");
    self.azureOrder = [[AzureConnection alloc] initWithTableName: @"Order"];
    //orderNum = [NSNumber numberWithInt:[orderNum intValue] - 1];
    
    if (self.orderNum == nil) {
        NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
        self.orderNum = [NSNumber numberWithInt:[standardUserDefaults integerForKey:@"orderNumber"]];
    }
    int orderNumber = [self.orderNum  intValue];
    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"id == %d", orderNumber];
    [self.azureOrder refreshDataOnSuccess:^{
        NSLog(@"successfully refreshed table");
        //NSArray *temp = self.azureOrder.items;
        NSLog(@"Number items%lu ",(unsigned long)[self.azureOrder.items count] );
        [self checkOrderStatus];
    } withPredicate:predicate];
    
    //[self connectToAzure];
}

- (void)checkOrderStatus {
    NSDictionary *order = [self.azureOrder.items objectAtIndex:0];
    NSString *status = [order objectForKey:@"status"];
    
    NSLog(@"Object before is %@", titleLabel);
    
    if ([status isEqual: @"orderPlaced"]) {
        NSLog(@"an order has been placed");
        
    } else if ([status isEqual: @"ready-for-pickup"]) {
        NSLog(@"BOO!");
        //[titleLabel setText:@"Your order is ready for pickup!"];
        [titleLabel setHidden:YES];
        [subtitleLabel setHidden:YES];
        [toPickupSubtitle setHidden:NO];
        [keyWord setHidden:NO];
        [pickUpMessage setHidden:NO];
        [self.keywordBG setHidden:NO];
        NSString *magicWord = [order objectForKey:@"keyword"];
        [keyWord setText:magicWord];
        [self.readyForPickup setHidden:NO];
        
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
        
    } else if ([status isEqual:@"picked-up"]) {    // assuming the status is equal to "picked-up"
        NSLog(@"the order has been picked up");
        [self.navigationController setNavigationBarHidden:NO animated:YES];
        [self performSegueWithIdentifier:@"backToBars" sender:self];
        [[NSNotificationCenter defaultCenter] removeObserver:self];
        //[[NSNotificationCenter defaultCenter] removeObserver:self forKeyPath:@"ReloadAppDelegateTable"];
    }
}

/*
Methods to Make:
    1) ViewDidLoad/Appear
    2) Check the status
 
    ** Get the item number passed to this file saved as a variable?? DONE
    ** Would get the order number from the CartViewController DONE
    ** Make this into a public variable in the .h file? DONE
 
    ** Need to import Azure Client DONE

 
*/



/*
Query Azure for the order that is in progress
If status is still in order DONE
    show the current message DONE
Else if status is ready-for-pickup DONE
    change the text to show the keyword
    Need to have the keyword message stored somewhere...
Else //Assuming that the order is completed
    seque to the barTVC??
    or figure a way to display that view controller instead
        //Prefer to do the latter way so it will help avoid stacking too many view controllers in memory
*/
/*from head

- (void)viewDidLoad {
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedNotification) name:@"receivedNotification" object:nil];

}*/


- (void)receivedNotification {
    
}





@end
