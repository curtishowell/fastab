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
@property (strong, nonatomic) NSString *venue;

//set by item type TVC before segueing
@property (nonatomic, strong) NSNumber *itemTypeID;
@property (nonatomic, strong) NSString *itemTypeName;

@property (strong, nonatomic) NSNumber *venueID;
@property (strong, nonatomic) NSString *venueName;



@end
