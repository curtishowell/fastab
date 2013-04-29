//
//  CartViewController.h
//  QuickStart
//
//  Created by studentuser on 4/11/13.
//  Copyright (c) 2013 Windows Azure. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ItemInCart.h"
#import <Foundation/Foundation.h>


@interface CartViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate>

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

@property (strong, nonatomic) NSString *venue;

- (void)addItemToCart:(ItemInCart *)item;

@end
