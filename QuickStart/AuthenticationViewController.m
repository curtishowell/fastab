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
    
    //hide back button
    self.navigationItem.hidesBackButton = YES;
}

- (void) login
{
    
    
    
    [self.azureConnection.client loginWithProvider:@"facebook"
                 onController:self
					 animated:YES
				   completion:^(MSUser *user, NSError *error) {
					   if (error) {
                           NSLog(@"Authentication Error: %@", error);
                           // Note that error.code == -1503 indicates
                           // that the user cancelled the dialog
                       } else {
                           NSLog(@"Success Logging in");
                           
                           
                           
                           
                           
                           //[self.azureConnection refreshDataOnSuccess:^{
                           //}];
                           
                           
                           [self performSegueWithIdentifier:@"AuthToPayment" sender:self];
                           
                       }
                       
                       [self dismissViewControllerAnimated:YES completion:nil];
                       
                       //user logs in or cancels
                       //[self refresh];
                   }];
    
    
    /*UINavigationController *controller =
    
    [self.azureConnection.client
     loginViewControllerWithProvider:@"facebook"
     completion:^(MSUser *user, NSError *error) {
         if (error) {
             NSLog(@"Authentication Error: %@", error);
             // Note that error.code == -1503 indicates
             // that the user cancelled the dialog
         } else {
             NSLog(@"Success Logging in");
             
             
             
              
           
             //[self.azureConnection refreshDataOnSuccess:^{
             //}];
             
             
            [self performSegueWithIdentifier:@"AuthToPayment" sender:self];

         }
         
         [self dismissViewControllerAnimated:YES completion:nil];
     }];*/
    
    /*replce with this call to eliminate the warning?
     
     // Logs in the current end user with the given provider by presenting the
     // MSLoginController with the given |controller|.
     -(void) loginWithProvider:(NSString *)provider
     onController:(UIViewController *)controller
     animated:(BOOL)animated
     completion:(MSClientLoginBlock)completion;
     
     */
    
    
    //[self presentViewController:controller animated:YES completion:nil];
    
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
