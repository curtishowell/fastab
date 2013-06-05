//
//  FirstViewController.m
//  Fastab Terminal
//
//  Created by Curtis Howell on 5/13/13.
//  Copyright (c) 2013 Curtis Howell. All rights reserved.
//

#import "FirstViewController.h"
#import <Foundation/Foundation.h>
#import <WindowsAzureMobileServices/WindowsAzureMobileServices.h>
#import "AzureConnection.h"


#define ITEM_MARGIN 15
#define ITEM_HEIGHT 40

#define ITEM_LABEL_WIDTH 400

#define ITEM_QTY_WIDTH 70


@interface FirstViewController ()

@property (weak, nonatomic) IBOutlet UITableView *toMakeList;
@property (weak, nonatomic) IBOutlet UITableView *toPickUpList;

//Azure Connections
@property (strong, nonatomic) AzureConnection *azureMake;
@property (strong, nonatomic) AzureConnection *azurePickUp;
@property (strong, nonatomic) AzureConnection *azureAuth;
@property (weak, nonatomic) IBOutlet UIButton *LogInOut;


//Contains list of items in each list
//@property (strong, nonatomic) NSMutableArray *pickUpItems;
//@property (strong, nonatomic) NSMutableArray *makeItems;

@end

@implementation FirstViewController

//- (IBAction)handleSwipe:(UISwipeGestureRecognizer *)sender {
//}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self logIn];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedNotification) name:@"receivedNotification" object:nil];


    //TODO: add some logic about constricting to one venue, probably on the server side by linking the userid to a venue
    
    
    //set background color of the tableviews to gray
    UIColor *bgColor = [[UIColor alloc] initWithRed:0.22 green:0.22 blue:0.22 alpha:1.0];
    self.toMakeList.backgroundColor = bgColor;
    self.toPickUpList.backgroundColor = bgColor;
    
    
    //Testing timer code
    //[NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(testing) userInfo:nil repeats:YES];
    
}

- (IBAction)logInOut:(id)sender {
    if(self.azureAuth.client.currentUser){ //logged in, so log out
        [self.azureAuth removeUserCredentials];
        self.azureAuth = nil;
        self.azureMake = nil;
        self.azurePickUp = nil;
        
        //clear data out of table views
        [self.toMakeList reloadData];
        [self.toPickUpList reloadData];
        
        [self.LogInOut setTitle:@"Log in" forState:UIControlStateNormal];
        //[self.LogInOut sizeToFit];
    } else { //not logged in, so log in!
        [self logIn];
    }
}


- (void)logIn {
    
    if(!self.azureAuth){
    
        self.azureAuth = [[AzureConnection alloc] init];
        
        if(!self.azureAuth.client.currentUser){
        
            [self.azureAuth.client loginWithProvider:@"facebook"
                                        onController:self
                                            animated:YES
                                          completion:^(MSUser *user, NSError *error) {
                                              if (error) {
                                                  NSLog(@"Authentication Error: %@", error);
                                                  // Note that error.code == -1503 indicates
                                                  // that the user cancelled the dialog
                                              } else {
                                                  NSLog(@"Success Logging in");
                                                  
                                                  [self.LogInOut setTitle:@"Log out" forState:UIControlStateNormal];
                                                  //[self.LogInOut sizeToFit];
                                                  
                                                  [self.azureAuth storeUserCredentials];

                                                  self.azureMake = [[AzureConnection alloc] initWithTableName: @"Order"];
                                                  self.azurePickUp = [[AzureConnection alloc] initWithTableName: @"Order"];
                                                  
                                                  [self refreshTables];

                                              }
                                              
                                              [self dismissViewControllerAnimated:YES completion:nil];
                                              
                                          }];
        } else { //already logged in, so init tables
            self.azureMake = [[AzureConnection alloc] initWithTableName: @"Order"];
            self.azurePickUp = [[AzureConnection alloc] initWithTableName: @"Order"];
            
            [self refreshTables];
            
            
            [self.LogInOut setTitle:@"Log out" forState:UIControlStateNormal];
            //[self.LogInOut sizeToFit];
        }
    }
}

- (IBAction)headerBarTap:(id)sender {
    [self refreshTables];
}



- (void)refreshTables {

    //Azure: To Make
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"status == 'orderPlaced' AND venueID == 3"];
    [self.azureMake refreshDataOnSuccess:^{
        //[self build]
        [self.toMakeList reloadData];
    } withPredicate:predicate];
    
    //Azure: To Pick Up
    predicate = [NSPredicate predicateWithFormat:@"status == 'ready-for-pickup' AND venueID == 3"];
//    [self.azurePickUp refreshDataOnSuccess:^{
//        [self.toPickUpList reloadData];
//    } withPredicate:predicate];
    
    [self.azurePickUp refreshDataOnSuccess:^{
        [self.toPickUpList reloadData];
    } withPredicate:predicate sortAscendingBy:@"keyword"];
    
    
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
    
    if (tableView == self.toMakeList) {
        
        int width = self.toMakeList.frame.size.width;
        
        int row = indexPath.row;
        NSDictionary *item = [self.azureMake.items objectAtIndex:row];
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
        
    } else if (tableView == self.toPickUpList) {
        
        int width = self.toPickUpList.frame.size.width;
        
        int row = indexPath.row;
        NSDictionary *item = [self.azurePickUp.items objectAtIndex:row];
        NSArray *orderItems = [item objectForKey:@"orderItems"];
        int count = [orderItems count];
        
        NSString *keyword = [[item objectForKey:@"keyword"] description];
        
        //keyword
        CGRect keywordRect = CGRectMake(ITEM_MARGIN, 0, width - ITEM_MARGIN, ITEM_HEIGHT);
        UIColor *keywordColor = [[UIColor alloc] initWithRed:0.541 green:1 blue:0.22 alpha:1];
        [self drawlabel:keyword atRect:keywordRect withColor:keywordColor onView:cell withAlignment:NSTextAlignmentLeft];
        
        
        for(int i = 0; i < count; i ++){
            NSDictionary *orderItem = [orderItems objectAtIndex:i];
            NSString *description = [orderItem objectForKey:@"itemName"];
            NSString *qty = [[orderItem objectForKey:@"qty"] description];
            
            CGRect qtyRect = CGRectMake(ITEM_MARGIN, (i + 1) * ITEM_HEIGHT, ITEM_QTY_WIDTH, ITEM_HEIGHT);
            CGRect labelRect = CGRectMake(ITEM_MARGIN * 2 + ITEM_QTY_WIDTH, (i + 1) * ITEM_HEIGHT, width - (ITEM_MARGIN * 3 + ITEM_QTY_WIDTH), ITEM_HEIGHT);
            

            [self drawlabel:qty atRect:qtyRect withColor:[UIColor whiteColor] onView:cell withAlignment:NSTextAlignmentRight];
            [self drawlabel:description atRect:labelRect withColor:[UIColor whiteColor] onView:cell withAlignment:NSTextAlignmentLeft];            
        }
        
        UISwipeGestureRecognizer *gestureRa = [[UISwipeGestureRecognizer alloc]
                                              initWithTarget:self action:@selector(handleSwipeFrom:)];
        [gestureRa setDirection:UISwipeGestureRecognizerDirectionLeft];//|UISwipeGestureRecognizerDirectionRight)];
        [cell addGestureRecognizer:gestureRa];
    }
    
    //Initialize a Swipe gesture recognizer for each table view cell.
    UISwipeGestureRecognizer *gestureR = [[UISwipeGestureRecognizer alloc]
                                          initWithTarget:self action:@selector(handleSwipeFrom:)];
    [gestureR setDirection:UISwipeGestureRecognizerDirectionRight];//|UISwipeGestureRecognizerDirectionRight)];
    [cell addGestureRecognizer:gestureR];

    return cell;
}

//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
//{
//    //Currently Defaulting to having one section for both views
//    return 1;
//}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{
    int rows = 0;
    if (tableView == self.toMakeList) {
        rows = [self.azureMake.items count];
    } else if (tableView == self.toPickUpList) {
        rows = [self.azurePickUp.items count];
    }
    return rows;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == self.toMakeList) {
        
        int row = indexPath.row;
        NSDictionary *item = [self.azureMake.items objectAtIndex:row];
        NSDictionary *orderItems = [item objectForKey:@"orderItems"];
        int count = [orderItems count];
        int height = count * ITEM_HEIGHT;
        
        return height > 0 ? height : ITEM_HEIGHT;
                
    } else { //assume: if (tableView == self.toPickUpList) {
        int row = indexPath.row;
        NSDictionary *item = [self.azurePickUp.items objectAtIndex:row];
        NSDictionary *orderItems = [item objectForKey:@"orderItems"];
        int count = [orderItems count];
        int height = (count + 1) * ITEM_HEIGHT; // + 1 for keyword label
        
        return height > 0 ? height : ITEM_HEIGHT;
    }
}

//- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
//{
//    NSString *header = @"";
//	if (tableView == self.toMakeList) {
//        header = @"Drinks to Make";
//    } else if (tableView == self.toPickUpList) {
//        header = @"Drinks to Pickup";
//    }
//    return header;
//}


- (IBAction)refreshPlease:(id)sender {
    [self refreshTables];
}




- (void)handleSwipeFrom:(UISwipeGestureRecognizer *)recognizer {
    //Here we will handle what happens when the gesture is done
    UITableViewCell *cell = [recognizer view];
    
    //NSString *orderName = cell.textLabel.text;
    if (recognizer.direction == UISwipeGestureRecognizerDirectionRight) {
        NSLog(@"We are Swiping Right!");
        
        //This is TEMP. For Demo purposes to differentiate between the two right gestures
        if (cell.superview == self.toPickUpList) {
            //call method to delete from pickup
            //[self deleteToMakeDrink: cell viewToChange:_toPickUpList listToChange:_pickUpItems];
            NSLog(@"Cell is from pickUP");
            
            //added 5/21/13
            NSIndexPath *path = [self.toPickUpList indexPathForCell:cell];
            [self addDrinkPickUp:cell atPath:path];
            
        } else if (cell.superview == self.toMakeList) {
            //move to pickup

            //[self.toMakeList beginUpdates];
            //[self.azureMake.items removeObjectAtIndex:path.row];
            //[self.toMakeList deleteRowsAtIndexPaths:[NSArray arrayWithObject:path] withRowAnimation:UITableViewRowAnimationFade];
            //[self.toMakeList endUpdates];
            //[self deleteToMakeDrink: cell viewToChange:_toMakeList listToChange:_makeItems];
            
            NSIndexPath *path = [self.toMakeList indexPathForCell:cell];
            [self addDrinkPickUp:cell atPath:path];
        }
    } else if (recognizer.direction == UISwipeGestureRecognizerDirectionLeft) {
        NSIndexPath *path;
        if (cell.superview == self.toPickUpList) {
            path = [self.toPickUpList indexPathForCell:cell];
        } else {    //assuming swipe from the toMakeList
            path = [self.toMakeList indexPathForCell:cell];
        }
        [self cancelDrink:cell atPath:path];
         
//        if ([_pickUpItems containsObject:orderName]) {
//            [self addDrinkPickUp: cell viewToChange:_toMakeList listToChange:_makeItems];
//            [self deleteToMakeDrink: cell viewToChange:_toPickUpList listToChange:_pickUpItems];
//        }
    }
}

-(void)cancelDrink:(UITableViewCell *)cell atPath:(NSIndexPath *)path {
    NSMutableDictionary *original;
    NSMutableDictionary *modified;
    if (cell.superview == self.toMakeList) {
        original = [self.azureMake.items objectAtIndex:path.row];
        modified = [original mutableCopy];
        [modified setObject:@"cancelled" forKey:@"status"];
        [original removeObjectForKey:@"orderItems"];
        [modified removeObjectForKey:@"orderItems"];
        [self.azureMake modifyItem:modified original:original completion:^(NSUInteger index) {
            
            
            //        [self.toPickUpList reloadData];
            //        [self.toMakeList reloadData];
            
            [self refreshTables];
            
        }];
    } else {
        original = [self.azurePickUp.items objectAtIndex:path.row];
        modified = [original mutableCopy];
        [modified setObject:@"cancelled" forKey:@"status"];
        [original removeObjectForKey:@"orderItems"];
        [modified removeObjectForKey:@"orderItems"];
        [self.azurePickUp modifyItem:modified original:original completion:^(NSUInteger index) {
            
            
            //        [self.toPickUpList reloadData];
            //        [self.toMakeList reloadData];
            
            [self refreshTables];
            
        }];
    }
    
}

-(void)addDrinkPickUp:(UITableViewCell *)cell atPath:(NSIndexPath *)path
{
    
    
    NSMutableDictionary *original;
    NSMutableDictionary *modified;
    
    //[modified setObject:@"ready-for-pickup" forKey:@"status"];
    //added 5/21/13
    
    if (cell.superview == self.toMakeList) {
        original = [self.azureMake.items objectAtIndex:path.row];
        modified = [original mutableCopy];
        [modified setObject:@"ready-for-pickup" forKey:@"status"];
        [original removeObjectForKey:@"orderItems"];
        [modified removeObjectForKey:@"orderItems"];
        
        [self.azureMake modifyItem:modified original:original completion:^(NSUInteger index) {
            
            
            //        [self.toPickUpList reloadData];
            //        [self.toMakeList reloadData];
            NSLog(@"Modfied Status");
            [self refreshTables];
            
        }];
        
    } else { //Assuming cell.superviw == self.toPickUpList
        original = [self.azurePickUp.items objectAtIndex:path.row];
        modified = [original mutableCopy];
        [modified setObject:@"picked-up" forKey:@"status"];
        [original removeObjectForKey:@"orderItems"];
        [modified removeObjectForKey:@"orderItems"];
        
        [self.azurePickUp modifyItem:modified original:original completion:^(NSUInteger index) {
            
            
            //        [self.toPickUpList reloadData];
            //        [self.toMakeList reloadData];
            
            [self refreshTables];
            
        }];
    }
    
}

-(void)deleteToMakeDrink: (UITableViewCell*) cell viewToChange:(UITableView *)view listToChange:(NSMutableArray *)list
{
    [view beginUpdates];
    NSIndexPath *indexPath= [view indexPathForCell:cell];
    NSArray *paths = [NSArray arrayWithObject:indexPath];
    [view deleteRowsAtIndexPaths:paths withRowAnimation:UITableViewRowAnimationFade];
    [list removeObjectAtIndex:indexPath.row];
    [view endUpdates];
}

-(void)testing {
    NSLog(@"REPEAT");
    //Can call to refresh the shit here!
}



- (void)receivedNotification {
    [self refreshTables];
}

@end
