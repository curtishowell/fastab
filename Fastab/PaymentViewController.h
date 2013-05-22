//
//  PaymentViewController.h
//  QuickStart
//
//  Created by Curtis Howell on 4/20/13.
//  Copyright (c) 2013 Windows Azure. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "STPView.h"

@interface PaymentViewController : UIViewController <STPViewDelegate>

@property IBOutlet STPView *stripeView;

@end
