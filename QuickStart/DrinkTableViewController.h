//
//  DrinkTableViewController.h
//  QuickStart
//
//  Created by studentuser on 4/9/13.
//  Copyright (c) 2013 Windows Azure. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DrinkTableViewController : UITableViewController

@property (nonatomic, strong) NSArray *drinkTypeListing; //List of drink types per bar
@property (nonatomic, strong) NSArray *specificDrinks; //List of specific drinks for a type

@end