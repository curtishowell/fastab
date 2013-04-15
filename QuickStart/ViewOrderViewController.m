//
//  ViewOrderViewController.m
//  QuickStart
//
//  Created by studentuser on 4/14/13.
//  Copyright (c) 2013 Windows Azure. All rights reserved.
//

/*Will need to create different seques from Bar Listing and Drink Listing to this view when an order has been placed. We can just create the modal seques from those views to this view, give them identifiers and when the button is clicked will seque to the proper view depending.

*/
#import "ViewOrderViewController.h"

@interface ViewOrderViewController ()

@end

@implementation ViewOrderViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
