//
//  ItemInCart.h
//  QuickStart
//
//  Created by TechFee Committee on 4/29/13.
//  Copyright (c) 2013 Windows Azure. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface ItemInCart : NSManagedObject

@property (nonatomic, retain) NSNumber * itemID;
@property (nonatomic, retain) NSNumber * itemType;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSDecimalNumber * price;
@property (nonatomic, retain) NSNumber * qty;
@property (nonatomic, retain) NSString * venueName;
@property (nonatomic, retain) NSNumber * venueID;

@end
