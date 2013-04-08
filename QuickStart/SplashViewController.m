//
//  SplashViewController.m
//  QuickStart
//
//  Created by studentuser on 4/6/13.
//  Copyright (c) 2013 Windows Azure. All rights reserved.
//

#import "SplashViewController.h"
#import "AuthenticationViewController.h"
#import "TodoService.h"
@interface SplashViewController ()

@end

@implementation SplashViewController

//Logic
//
//If (first_time_launched) {
//      GOTO_Authentication
//}
//Else {
//      SHOW_LOADING_CIRCLE
//      LOAD_BAR&DRINK_DATA
//}

- (void)viewWillAppear:(BOOL)animated
{
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    
    BOOL firstTime = [standardUserDefaults boolForKey:@"firstTimeRun"];
    
    //not first time running
    if(firstTime) {
        //NSLog(@"WE are here 1");
        [self performSegueWithIdentifier:@"SkipFirstAuthentication" sender:self];
    } else {
        [standardUserDefaults setBool:YES forKey:@"firstTimeRun"];
        //go to first run experience
        //NSLog(@"We ar here 2");
        [self performSegueWithIdentifier:@"AuthenticateFB" sender:self];
        
    }
    
}



@end
