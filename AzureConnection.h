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
//@property (nonatomic, strong)   MSTable *barListing;
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

//add item
- (void) addItem:(NSDictionary *) item
      completion:(CompletionWithIndexBlock) completion;

//modify item
-(void)modifyItem:(NSDictionary *)item
         original:(NSDictionary *)original
       completion:(CompletionWithIndexBlock)completion;


- (void)refreshDataOnSuccess:(CompletionBlock)completion
               withPredicate:(NSPredicate *)predicate
             sortAscendingBy:(NSString *)sortString;

//save credentials because azure for some reason does not do this automatically
- (void) storeUserCredentials;
- (void)removeUserCredentials;

@end
