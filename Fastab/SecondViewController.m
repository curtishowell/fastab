//
//  SecondViewController.m
//  Fastab Terminal
//
//  Created by Curtis Howell on 5/13/13.
//  Copyright (c) 2013 Curtis Howell. All rights reserved.
//

#import "SecondViewController.h"
#import <Foundation/Foundation.h>
#import <WindowsAzureMobileServices/WindowsAzureMobileServices.h>
#import "AzureConnection.h"
#import "QuartzCore/QuartzCore.h"

#define ITEM_MARGIN 15
#define ITEM_HEIGHT 40

#define ITEM_LABEL_WIDTH 400

#define ITEM_QTY_WIDTH 70

@interface SecondViewController ()
@property (weak, nonatomic) IBOutlet UITableView *completedOrderTable;
@property (strong, nonatomic) AzureConnection *azureComplete;
@property int *howManyRows;

@property (nonatomic, retain) UIActivityIndicatorView * activityView;
@property (nonatomic, retain) UIView *loadingView;
@property (nonatomic, retain) UILabel *loadingLabel;

@end

@implementation SecondViewController

@synthesize activityView;
@synthesize loadingView;
@synthesize loadingLabel;

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedNotification) name:@"receivedNotification" object:nil];
    UIColor *bgColor = [[UIColor alloc] initWithRed:0.22 green:0.22 blue:0.22 alpha:1.0];
    self.completedOrderTable.backgroundColor = bgColor;
    
    self.completedOrderTable.dataSource = self;
    self.completedOrderTable.delegate = self;
    
    self.azureComplete = [[AzureConnection alloc] initWithTableName: @"Order"];
    [self refreshTables];
    
    //To implement Later
    [self showActivityIndicator];
    
}

- (void)refreshTables {
    
    //Azure: Picked-up
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"status == 'picked-up' AND venueID == 3"];
    [self.azureComplete refreshDataOnSuccess:^{
        //[self build]
        [self.completedOrderTable reloadData];
    } withPredicate:predicate];
    
}

- (void)drawlabel:(NSString *)string atRect:(CGRect)rect withColor:(UIColor *)color onView:(UIView *)view withAlignment:(NSTextAlignment)alignment {
    
    UIFont *itemFont = [UIFont systemFontOfSize:24];
    UILabel *label = [[UILabel alloc] initWithFrame:rect];
    
    [label setText:string];
    [label setFont:itemFont];
    label.textAlignment = alignment;
    label.textColor = color;
    label.backgroundColor = [UIColor clearColor];
    
    [view addSubview:label];
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc] init];
    
    if (tableView == self.completedOrderTable) {
        
        int width = self.completedOrderTable.frame.size.width;
        
        int row = indexPath.row;
        NSDictionary *item = [self.azureComplete.items objectAtIndex:row];
        NSArray *orderItems = [item objectForKey:@"orderItems"];
        int count = [orderItems count];
        
        for(int i = 0; i < count; i ++){
            NSDictionary *orderItem = [orderItems objectAtIndex:i];
            NSString *description = [orderItem objectForKey:@"itemName"];
            NSString *qty = [[orderItem objectForKey:@"qty"] description];
            
            CGRect qtyRect = CGRectMake(ITEM_MARGIN, i * ITEM_HEIGHT, ITEM_QTY_WIDTH, ITEM_HEIGHT);
            CGRect labelRect = CGRectMake(ITEM_MARGIN * 2 + ITEM_QTY_WIDTH, i * ITEM_HEIGHT, width - (ITEM_MARGIN * 3 + ITEM_QTY_WIDTH), ITEM_HEIGHT);
            
            [self drawlabel:qty atRect:qtyRect withColor:[UIColor whiteColor] onView:cell withAlignment:NSTextAlignmentRight];
            [self drawlabel:description atRect:labelRect withColor:[UIColor whiteColor] onView:cell withAlignment:NSTextAlignmentLeft];
            
        }
        
    }
   
    /*
    //Initialize a Swipe gesture recognizer for each table view cell.
    UISwipeGestureRecognizer *gestureR = [[UISwipeGestureRecognizer alloc]
                                          initWithTarget:self action:@selector(handleSwipeFrom:)];
    [gestureR setDirection:UISwipeGestureRecognizerDirectionRight];//|UISwipeGestureRecognizerDirectionRight)];
    [cell addGestureRecognizer:gestureR];
    */
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{
    int rows = 0;
    if (tableView == self.completedOrderTable) {
        rows = [self.azureComplete.items count];
    }
    return rows;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    //Currently Defaulting to having one section for both views
    return 1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
        int row = indexPath.row;
        NSDictionary *item = [self.azureComplete.items objectAtIndex:row];
        NSDictionary *orderItems = [item objectForKey:@"orderItems"];
        int count = [orderItems count];
        int height = count * ITEM_HEIGHT;
        
        return height > 0 ? height : ITEM_HEIGHT;
}

- (void)receivedNotification {
    [self refreshTables];
}

- (void)showActivityIndicator {

    //loadingView = [[UIView alloc] initWithFrame:CGRectMake(75, 120, 170, 170)];
	loadingView = [[UIView alloc] initWithFrame:CGRectMake(450, 250, 170, 170)];
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
    loadingLabel.text = @"Loading...";
    [loadingView addSubview:loadingLabel];
	
    [self.view addSubview:loadingView];
    [activityView startAnimating];
    
}

-(void) tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row == ((NSIndexPath*)[[self.completedOrderTable indexPathsForVisibleRows] lastObject]).row){
        [activityView stopAnimating];
        loadingView.hidden = YES;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
