//
//  PaymentViewController.m
//  QuickStart
//
//  Created by Curtis Howell on 4/20/13.
//  Copyright (c) 2013 Windows Azure. All rights reserved.
//

#import "PaymentViewController.h"

@interface PaymentViewController ()
@property (weak, nonatomic) IBOutlet UIBarButtonItem *saveButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *cancelButton;

@end

@implementation PaymentViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.stripeView = [[STPView alloc] initWithFrame:CGRectMake(15,75,290,55)
                                              andKey:@"pk_test_czwzkTp2tactuLOEOqbMTRzG"];
    self.stripeView.delegate = self;
    [self.view addSubview:self.stripeView];
}


- (void) stripeView:(PKView*)view
            withCard:(PKCard *)card
             isValid:(BOOL)valid
{
    NSLog(@"Card number: %@", card.number);
    NSLog(@"Card expiry: %lu/%lu", (unsigned long)card.expMonth, (unsigned long)card.expYear);
    NSLog(@"Card cvc: %@", card.cvc);
    NSLog(@"Address zip: %@", card.addressZip);
    
    self.saveButton.enabled = valid;
}

- (IBAction)save:(id)sender
{
    
    NSLog(@"saving!");
    
    //disbale the menu bar items
    self.cancelButton.enabled = NO;
    self.saveButton.enabled = NO;
    
    //send data to our awesomely robust backend servers
    
    //disable cancel and save buttons
    
    
    
    [self.stripeView createToken:^(STPToken *token, NSError *error) {
        if (error) {
            // Handle error
            // [self handleError:error];
        } else {
            // Send off token to your server
            [self handleToken:token];
        }
    }];
}


- (IBAction)cancel:(id)sender {
    NSLog(@"canceling!");
}


- (void)handleToken:(STPToken *)token
{
    NSLog(@"Received token %@", token.tokenId);
    
    //send the token to the server, where the server should create a Stripe User and store it 
    
    /*NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:@"https://example.com"]];
    request.HTTPMethod = @"POST";
    NSString *body     = [NSString stringWithFormat:@"stripeToken=%@", token.tokenId];
    request.HTTPBody   = [body dataUsingEncoding:NSUTF8StringEncoding];
    
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                               if (error) {
                                   // Handle error
                               }
                           }];*/
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


@end
