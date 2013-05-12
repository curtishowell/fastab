//
//  PaymentViewController.m
//  QuickStart
//
//  Created by Curtis Howell on 4/20/13.
//  Copyright (c) 2013 Windows Azure. All rights reserved.
//

#import "PaymentViewController.h"
#import "AzureConnection.h"
#import "QuartzCore/QuartzCore.h"

@interface PaymentViewController ()
@property (weak, nonatomic) IBOutlet UIBarButtonItem *saveButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *cancelButton;
@property (strong, nonatomic) AzureConnection *azureConnection;

//activity view properties
@property (nonatomic, retain) UIActivityIndicatorView * activityView;
@property (nonatomic, retain) UIView *loadingView;
@property (nonatomic, retain) UILabel *loadingLabel;
@end

@implementation PaymentViewController

@synthesize azureConnection;
@synthesize activityView;
@synthesize loadingView;
@synthesize loadingLabel;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.stripeView = [[STPView alloc] initWithFrame:CGRectMake(15,75,290,55)
                                              andKey:@"pk_test_PixRdiWtXsJAQPAltyhSEmP4"];
    self.stripeView.delegate = self;
    [self.view addSubview:self.stripeView];
    
    self.azureConnection = [[AzureConnection alloc] initWithTableName: @"PaymentDetails"];

}

- (void)viewDidAppear:(BOOL)animated
{
    MSClient *client = self.azureConnection.client;
	
	
	if (client.currentUser != nil) {
		return;
	}
	
	[client loginWithProvider:@"facebook"
				 onController:self
					 animated:YES
				   completion:^(MSUser *user, NSError *error) {
					   
					   [self.azureConnection storeUserCredentials];
					   
					}];
}

- (void) stripeView:(PKView*)view
            withCard:(PKCard *)card
             isValid:(BOOL)valid
{
    
    self.saveButton.enabled = valid;
    
    //if the number is valid, make the save button green
    if(valid) {
        self.saveButton.tintColor=[UIColor colorWithRed:.118 green:.604 blue:.278 alpha:1];
    } else {
        self.saveButton.tintColor = nil;
    }
}

- (IBAction)save:(id)sender
{
	
	
    
    NSLog(@"saving");
    
    //disbale the menu bar items
    self.cancelButton.enabled = NO;
    self.saveButton.enabled = NO;
	
	//show activity indicator
	[self showActivityIndicator];
	
    
    //send data to our awesomely robust backend servers
    [self.stripeView createToken:^(STPToken *token, NSError *error) {
        if (error) {
            // Handle error
            [self handleError:error];
        } else {
            // Send token to the Fastab server
            [self handleToken:token];
        }
    }];
}


- (IBAction)cancel:(id)sender {
    NSLog(@"canceling");
    [self performSegueWithIdentifier:@"PaymentToBarList" sender:self];
}


- (void)handleToken:(STPToken *)token
{
    NSLog(@"Received token %@", token.tokenId);
    
    //send the token to the server, where the server should create a Stripe User and store it 
    
    NSDictionary *item = @{ @"card_token" : token.tokenId, @"userId" : @"fakeid123" };
	
	UIViewController *viewController = self;
	
    [self.azureConnection addItem:item completion:^(NSUInteger index){
        
        //TODO: kill progress and connection UIs
        
		NSLog(@"token successfully sent to server");
		
		dispatch_async(dispatch_get_main_queue(), ^{
			[viewController performSegueWithIdentifier:@"PaymentToBarList" sender:viewController];
		});
    }];
    
    
}

- (void)handleError:(NSError *)error
{
    UIAlertView *message = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"Error")
                                                      message:[error localizedDescription]
                                                     delegate:nil
                                            cancelButtonTitle:NSLocalizedString(@"OK", @"OK")
                                            otherButtonTitles:nil];
    [message show];
}

- (void)showActivityIndicator {
	
	loadingView = [[UIView alloc] initWithFrame:CGRectMake(75, 155, 170, 170)];
	loadingView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
	loadingView.clipsToBounds = YES;
	loadingView.layer.cornerRadius = 10.0;
	
	activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
	activityView.frame = CGRectMake(65, 40, activityView.bounds.size.width, activityView.bounds.size.height);
    [loadingView addSubview:activityView];
	
    loadingLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 115, 130, 22)];
    loadingLabel.backgroundColor = [UIColor clearColor];
    loadingLabel.textColor = [UIColor whiteColor];
    loadingLabel.adjustsFontSizeToFitWidth = YES;
    loadingLabel.textAlignment = UITextAlignmentCenter;
    loadingLabel.text = @"Saving...";
    [loadingView addSubview:loadingLabel];
	
    [self.view addSubview:loadingView];
    [activityView startAnimating];
}


@end
