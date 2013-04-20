//
//  Item.h
//  QuickStart
//
//  Created by Curtis Howell on 4/19/13.
//  Copyright (c) 2013 Windows Azure. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Item : NSObject

@property (nonatomic) int *ID;
@property (nonatomic, strong) NSString *name;
@property (nonatomic) double *price;
@property (nonatomic, strong) NSString *imageURL;
@property (nonatomic, strong) NSNumber *itemType;
@property (nonatomic) int *qty;


@end
