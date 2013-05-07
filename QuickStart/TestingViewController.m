//
//  TestingViewController.m
//  QuickStart
//
//  Created by TechFee Committee on 5/2/13.
//  Copyright (c) 2013 Windows Azure. All rights reserved.
//

#import "TestingViewController.h"
#import "ItemInCart.h"
#import <WindowsAzureMobileServices/WindowsAzureMobileServices.h>
#import <Foundation/Foundation.h>

@interface TestingViewController ()
@end

@implementation TestingViewController



- (void)prepareForSegue:(UIStoryboardSegue *)segue
                 sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"item1ToCart"]) {

        
        UITableViewController *cartViewController = segue.destinationViewController;
        
        NSMutableDictionary *itemDictionary = [[NSMutableDictionary alloc] init];
        
        [itemDictionary setObject:[NSNumber numberWithInt:1] forKey:@"itemID"];
        [itemDictionary setObject:[NSNumber numberWithInt:1] forKey:@"itemTypeID"];
        [itemDictionary setObject:@"test beer one" forKey:@"itemName"];
        [itemDictionary setObject:[NSDecimalNumber decimalNumberWithString:@"4.5"] forKey:@"price"];
        [itemDictionary setObject:[NSNumber numberWithInt:1] forKey:@"qty"];
        [itemDictionary setObject:@"test venue" forKey:@"venueName"];
        [itemDictionary setObject:[NSNumber numberWithInt:1] forKey:@"venueID"];
        
        
        //set values in the drink type view controller
        [cartViewController performSelector:@selector(setTempItem:)
                                 withObject:itemDictionary];
        [cartViewController performSelector:@selector(setVenueID:)
                                 withObject:[NSNumber numberWithInt:1]];
        [cartViewController performSelector:@selector(setVenueName:)
                                 withObject:@"test venue"];
        
        
    } else if([segue.identifier isEqualToString:@"item2ToCart"]) {
        
        UITableViewController *cartViewController = segue.destinationViewController;
        
        NSMutableDictionary *itemDictionary = [[NSMutableDictionary alloc] init];
        
        [itemDictionary setObject:[NSNumber numberWithInt:2] forKey:@"itemID"];
        [itemDictionary setObject:[NSNumber numberWithInt:2] forKey:@"itemTypeID"];
        [itemDictionary setObject:@"test beer deuce" forKey:@"itemName"];
        [itemDictionary setObject:[NSDecimalNumber decimalNumberWithString:@"5.5"] forKey:@"price"];
        [itemDictionary setObject:[NSNumber numberWithInt:1] forKey:@"qty"];
        [itemDictionary setObject:@"test venue" forKey:@"venueName2"];
        [itemDictionary setObject:[NSNumber numberWithInt:2] forKey:@"venueID"];
        
        
        //set values in the drink type view controller
        [cartViewController performSelector:@selector(setTempItem:)
                                 withObject:itemDictionary];
        [cartViewController performSelector:@selector(setVenueID:)
                                 withObject:[NSNumber numberWithInt:1]];
        [cartViewController performSelector:@selector(setVenueName:)
                                 withObject:@"test venue"];
        
        
    }
}




@end
