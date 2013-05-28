//
//  OrderFulfillmentViewController.m
//  QuickStart
//
//  Created by Curtis Howell on 5/11/13.
//  Copyright (c) 2013 Windows Azure. All rights reserved.
//

#import "OrderFulfillmentViewController.h"

@interface OrderFulfillmentViewController ()

//- (void)receivedNotification;

@end

@implementation OrderFulfillmentViewController

- (void)viewDidLoad {
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedNotification) name:@"receivedNotification" object:nil];

}


- (void)receivedNotification {
    
}





@end
