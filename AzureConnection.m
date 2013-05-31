//
//  AzureConnection.m
//  QuickStart
//
//  Created by studentuser on 4/6/13.
//  Copyright (c) 2013 Windows Azure. All rights reserved.
//

#import "AzureConnection.h"
#import <WindowsAzureMobileServices/WindowsAzureMobileServices.h>
#import "AppDelegate.h"

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
        self.client = [newClient clientwithFilter:(id)self];
        
        //if user has stored authentication creds, load the creds itno the MSClient
		NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
		
		NSString *userId = [standardUserDefaults stringForKey:@"userId"];
		NSString *token = [standardUserDefaults stringForKey:@"token"];
		
		if(userId && token) {
			self.client.currentUser = [[MSUser alloc] initWithUserId:userId];
			self.client.currentUser.mobileServiceAuthenticationToken = token;
		}
        
        //BOOL firstTime = [standardUserDefaults boolForKey:@"firstTimeRun"];
        //
        //    //not first time running
        //    if(firstTime) {
        //        //NSLog(@"WE are here 1");
        //        [self performSegueWithIdentifier:@"SkipFirstAuthentication" sender:self];
        //    } else {
        //        [standardUserDefaults setBool:YES forKey:@"firstTimeRun"];
//		[standardUserDefaults setValue:userId forKey:@"userId"];
//		[standardUserDefaults setValue:token forKey:@"token"];
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

//store the userid and auth token in user defaults to be read later to persist auth
//across sessions and across instances of AzureConnection
- (void) storeUserCredentials
{
	
	//store user details locally in nsUserDefaults
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    
    NSString *userId = self.client.currentUser.userId;
    [standardUserDefaults setValue:userId forKey:@"userId"];
    
    //TODO: store this token in the os x keychain instead of userdefaults
    [standardUserDefaults setValue:self.client.currentUser.mobileServiceAuthenticationToken forKey:@"token"];
    
    
    
    
    //store the device key and user acct info in Azure
    NSString *deviceToken = [(AppDelegate *)[[UIApplication sharedApplication] delegate] deviceToken];
    NSDictionary *device = @{ @"deviceToken" : deviceToken, @"userId" : userId };
     
    AzureConnection *azureConnection = [[AzureConnection alloc] initWithTableName: @"Devices"];
    
    [azureConnection addItem:device completion:^(NSUInteger index){
        
    }];

}

- (void)removeUserCredentials
{
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    
    [standardUserDefaults removeObjectForKey:@"userId"];
    [standardUserDefaults removeObjectForKey:@"userToken"];
    [standardUserDefaults synchronize];
    
//    //just for testing to make sure the values were cleared out
//    NSString *userId = [standardUserDefaults stringForKey:@"userId"];
//    NSString *token = [standardUserDefaults stringForKey:@"userToken"];
    
}

-(void)modifyItem:(NSDictionary *)item
         original:(NSDictionary *)original
       completion:(CompletionWithIndexBlock)completion
{
    // Cast the public items property to the mutable type (it was created as mutable)
    NSMutableArray *mutableItems = (NSMutableArray *) items;
    
    // Replace the original in the items array
    NSUInteger index = [items indexOfObjectIdenticalTo:original];
    [mutableItems replaceObjectAtIndex:index withObject:item];
    
    // Update the item in the TodoItem table and remove from the items array on completion
    [self.table update:item completion:^(NSDictionary *item, NSError *error) {
        
        [self logErrorIfNotNil:error];
        
        // Let the caller know that we have finished
        completion(index);
    }];
}


@end
