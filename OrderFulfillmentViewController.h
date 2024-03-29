//
//  OrderFulfillmentViewController.h
//  QuickStart
//
//  Created by Curtis Howell on 5/11/13.
//  Copyright (c) 2013 Windows Azure. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OrderFulfillmentViewController : UIViewController

@property (strong, nonatomic) NSNumber *orderNum;

@property (strong, nonatomic) NSNumber *venueID;
@property (strong, nonatomic) NSString *venueName;

- (void)connectToAzure;

@end
