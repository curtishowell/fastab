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


- (MSClient *)clinet {
    if(!_client){
        _client = [[MSClient alloc] init];
    }
    return _client;
}

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
        
    }
    
    return self;
}


-(AzureConnection *) initWithTableName: (NSString*) tableName
{
    self = [self init]; //needed to get around compiler
    self.table = [self.client getTable:tableName];
    
    self.items = [[NSMutableArray alloc] init];
    self.busyCount = 0;
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

- (void) refreshDataOnSuccess:(CompletionBlock)completion withPredicate:(NSPredicate *) predicate
{
    // Create a predicate that finds items where complete is false
    //NSPredicate * predicate = [NSPredicate predicateWithFormat:@"name == name"];
    
    // Query the TodoItem table and update the items property with the results from the service
    [self.table readWhere:predicate completion:^(NSArray *results, NSInteger totalCount, NSError *error) {
        
        [self logErrorIfNotNil:error];
        
        items = [results mutableCopy];
        
        // Let the caller know that we finished
        completion();
    }];
    
}

/*
 
 
where did this implementation come from? Patrick, did you write this?
 
 
 -(void) addItem:(NSDictionary *)item
     completion:(CompletionWithIndexBlock)completion
{
    // TODO
    // Insert the item into the TodoItem table and add to the items array on completion
    [self.table insert:item completion:^(NSDictionary *result, NSError *error) {
        NSUInteger index = [items count];
        [(NSMutableArray *)items insertObject:item atIndex:index];
        
        [self logErrorIfNotNil:error];
        BOOL goodRequest = !((error) && (error.code == MSErrorMessageErrorCode));
        
        // detect text validation error from service.
        if (goodRequest) // The service responded appropriately
        {
            NSUInteger index = [items count];
            [(NSMutableArray *)items insertObject:result atIndex:index];
            
            // Let the caller know that we finished
            completion(index);
        }
        else{
            
            // if there's an error that came from the service
            // log it, and popup up the returned string.
            if (error && error.code == MSErrorMessageErrorCode) {
                NSLog(@"ERROR %@", error);
                UIAlertView *av =
                [[UIAlertView alloc]
                 initWithTitle:@"Request Failed"
                 message:error.localizedDescription
                 delegate:nil
                 cancelButtonTitle:@"OK"
                 otherButtonTitles:nil
                 ];
                [av show];
            }
        }
        
        
        // Let the caller know that we finished
        completion(index);
        
    }];
}*/

-(void)addItem:(NSDictionary *)item
    completion:(CompletionWithIndexBlock)completion
{
    // Insert the item into the TodoItem table and add to the items array on completion
    [self.table insert:item completion:^(NSDictionary *result, NSError *error)
     {
         [self logErrorIfNotNil:error];
         
         NSUInteger index = [items count];
         [(NSMutableArray *)items insertObject:result atIndex:index];
         
         // Let the caller know that we finished
         completion(index);
     }];
}


@end
