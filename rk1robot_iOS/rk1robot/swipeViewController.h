//
//  swipeViewController.h
//  rk1robot
//
//  Created by Evangelos Georgiou on 26/01/2014.
//  Copyright (c) 2014 Evangelos Georgiou. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "Settings.h"
#import <CocoaAsyncSocket/GCDAsyncSocket.h>
#import "Reachability.h"
#import <Accounts/Accounts.h>
#import <Social/Social.h>
#import <QuartzCore/QuartzCore.h>

@interface swipeViewController : UIViewController<GCDAsyncSocketDelegate>
{
    GCDAsyncSocket *tcpsocket;
    NSTimer *timer;
    
    int left;
    BOOL leftDirection;
    BOOL leftmotorstate;
    int right;
    BOOL rightDirection;
    BOOL rightmotorstate;
    
    BOOL directionstate;
    
    SLComposeViewController *mySLComposerSheet;
}

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@property (strong, nonatomic) IBOutlet UILabel *ipaddressLabel;
@property (strong, nonatomic) IBOutlet UILabel *portLabel;

@property (strong, nonatomic) IBOutlet UILabel *leftLabel;
@property (strong, nonatomic) IBOutlet UILabel *rightLabel;

@property (strong, nonatomic) IBOutlet UILabel *batteryLabel;

- (IBAction)infoButtonPressed:(id)sender;

- (IBAction)swipeupGesture:(id)sender;
- (IBAction)swipedownGesture:(id)sender;
- (IBAction)swipeleftGesture:(id)sender;
- (IBAction)swiperightGesture:(id)sender;
- (IBAction)tapGesture:(id)sender;

- (IBAction)facebookButtonPressed:(id)sender;
- (IBAction)twitterButtonPressed:(id)sender;

@end
