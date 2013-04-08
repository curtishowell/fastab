//
//  AzureConnection.m
//  QuickStart
//
//  Created by studentuser on 4/6/13.
//  Copyright (c) 2013 Windows Azure. All rights reserved.
//

#import "AzureConnection.h"
#import <WindowsAzureMobileServices/WindowsAzureMobileServices.h>

@interface AzureConnection()

@property (nonatomic) NSInteger busyCount;
@property (nonatomic, strong)   MSTable *table;

@end

@implementation AzureConnection

@synthesize items;

-(AzureConnection *) init
{
    self = [super init];
    if (self) {
        // Initialize the Mobile Service client with your URL and key
        MSClient *newClient = [MSClient clientWithApplicationURLString:@"https://fastab.azure-mobile.net/"
                                                    withApplicationKey:@"EEOENdPBCHhkMKyCPkqHYIRHmFZJya73"];
        
        // Add a Mobile Service filter to enable the busy indicator
        self.client = [newClient clientwithFilter:self];
        
        //Uncomment line for creating a table to add items
        // Create an MSTable instance to allow us to work with the TodoItem table
        //self.table = [_client getTable:@"TodoItem"];
        
        self.items = [[NSMutableArray alloc] init];
        self.busyCount = 0;
    }
    
    return self;
}

- (void) busy:(BOOL) busy
{
    // assumes always executes on UI thread
    if (busy) {
        if (self.busyCount == 0 && self.busyUpdate != nil) {
            self.busyUpdate(YES);
        }
        self.busyCount ++;
    }
    else
    {
        if (self.busyCount == 1 && self.busyUpdate != nil) {
            self.busyUpdate(FALSE);
        }
        self.busyCount--;
    }
}

- (void) logErrorIfNotNil:(NSError *) error
{
    if (error) {
        NSLog(@"ERROR %@", error);
    }
}

- (void) handleRequest:(NSURLRequest *)request
                onNext:(MSFilterNextBlock)onNext
            onResponse:(MSFilterResponseBlock)onResponse
{
    // A wrapped response block that decrements the busy counter
    MSFilterResponseBlock wrappedResponse = ^(NSHTTPURLResponse *response, NSData *data, NSError *error) {
        [self busy:NO];
        onResponse(response, data, error);
    };
    
    // Increment the busy counter before sending the request
    [self busy:YES];
    onNext(request, wrappedResponse);
}

- (void) refreshDataOnSuccess:(CompletionBlock)completion
{
    // Create a predicate that finds items where complete is false
    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"complete == NO"];
    
    // Query the TodoItem table and update the items property with the results from the service
    //[self.table readWhere:predicate completion:^(NSArray *results, NSInteger totalCount, NSError *error) {
        
     //   [self logErrorIfNotNil:error];
        
     //   items = [results mutableCopy];
        
        // Let the caller know that we finished
     //   completion();
    //}];
    
}


@end
