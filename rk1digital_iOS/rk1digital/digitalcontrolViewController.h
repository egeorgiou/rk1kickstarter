//
//  digitalcontrolViewController.h
//  rk1digital
//
//  Created by Evangelos Georgiou on 12/03/2014.
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

@interface digitalcontrolViewController : UIViewController<GCDAsyncSocketDelegate>
{
    GCDAsyncSocket *tcpsocket;
    NSTimer *timer;

    SLComposeViewController *mySLComposerSheet;
}

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@property (strong, nonatomic) IBOutlet UILabel *ipaddressLabel;
@property (strong, nonatomic) IBOutlet UILabel *portLabel;

@property (strong, nonatomic) IBOutlet UILabel *batteryLabel;

- (IBAction)infoButtonPressed:(id)sender;

- (IBAction)facebookButtonPressed:(id)sender;
- (IBAction)twitterButtonPressed:(id)sender;

@property (nonatomic, strong) NSMutableArray *digitalPinValueArray;

@property (strong, nonatomic) IBOutlet UISegmentedControl *pin10stateSegmentedControl;
@property (strong, nonatomic) IBOutlet UISegmentedControl *pin11stateSegmentedControl;
@property (strong, nonatomic) IBOutlet UISegmentedControl *pin12stateSegmentedControl;
@property (strong, nonatomic) IBOutlet UISegmentedControl *pin13stateSegmentedControl;

- (IBAction)pin10statechangeSegmentedControl:(id)sender;
- (IBAction)pin11statechangeSegmentedControl:(id)sender;
- (IBAction)pin12statechangeSegmentedControl:(id)sender;
- (IBAction)pin13statechangeSegmentedControl:(id)sender;


@end
