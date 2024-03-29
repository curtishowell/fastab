//
//  AppDelegate.h
//  Fastab
//
//  Created by Curtis Howell on 5/22/13.
//  Copyright (c) 2013 Curtis Howell. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;


@property (strong, nonatomic) NSString *deviceToken;


- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

@end
