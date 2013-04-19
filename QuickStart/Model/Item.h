//
//  Item.h
//  QuickStart
//
//  Created by Curtis Howell on 4/19/13.
//  Copyright (c) 2013 Windows Azure. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Item : NSObject

@property (nonatomic, strong) NSNumber *ID;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSNumber *price;
@property (nonatomic, strong) NSString *imageURL;
@property (nonatomic, strong) NSNumber *itemType;

@end
