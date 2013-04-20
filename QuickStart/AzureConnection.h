//
//  AzureConnection.h
//  QuickStart
//
//  Created by studentuser on 4/6/13.
//  Copyright (c) 2013 Windows Azure. All rights reserved.
//

#import <WindowsAzureMobileServices/WindowsAzureMobileServices.h>
#import <Foundation/Foundation.h>

#pragma mark * Block Definitions

typedef void (^CompletionBlock) ();
typedef void (^CompletionWithIndexBlock) (NSUInteger index);
typedef void (^BusyUpdateBlock) (BOOL busy);

@interface AzureConnection : NSObject
@property (nonatomic, strong)   MSTable *barListing;
@property (nonatomic, strong)   NSArray *items;
@property (nonatomic, strong)   MSClient *client;
//@property (nonatomic, strong)   NSArray *barList;
@property (nonatomic, copy)     BusyUpdateBlock busyUpdate;

- (void) refreshDataOnSuccess:(CompletionBlock) completion
                withPredicate:(NSPredicate *) predicate;

- (void) handleRequest:(NSURLRequest *)request
                onNext:(MSFilterNextBlock)onNext
            onResponse:(MSFilterResponseBlock)onResponse;

- (AzureConnection *) initWithTableName: (NSString *) tableName;
@end
