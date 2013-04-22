//
//  AuthenticationViewController.m
//  QuickStart
//
//  Created by studentuser on 4/6/13.
//  Copyright (c) 2013 Windows Azure. All rights reserved.
//

#import <WindowsAzureMobileServices/WindowsAzureMobileServices.h>
#import "AuthenticationViewController.h"
#import "AzureConnection.h"

@interface AuthenticationViewController ()
@property (strong, nonatomic) AzureConnection *azureConnection;
@end

@implementation AuthenticationViewController

@synthesize azureConnection;

- (IBAction)LogInFB:(UIButton *)sender
{
    [self login];
}

- (IBAction)skipToBars:(UIButton *)sender {
    [self performSegueWithIdentifier:@"ViewBars" sender:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.azureConnection = [[AzureConnection alloc]init];
}

- (void) login
{
    NSLog(@"Step1");
    UINavigationController *controller =
    
    [self.azureConnection.client
     loginViewControllerWithProvider:@"facebook"
     completion:^(MSUser *user, NSError *error) {
         if (error) {
             NSLog(@"Authentication Error: %@", error);
             // Note that error.code == -1503 indicates
             // that the user cancelled the dialog
         } else {
             // No error, so load the data
             NSLog(@"Success Logging in");
            [self performSegueWithIdentifier:@"AuthToPayment" sender:self];
             //[self.azureConnection refreshDataOnSuccess:^{
             //}];
         }
         
         [self dismissViewControllerAnimated:YES completion:nil];
     }];
    
    
    [self presentViewController:controller animated:YES completion:nil];
    
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


@end
