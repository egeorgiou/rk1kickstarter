//
//  dataViewController.h
//  rk1data
//
//  Created by Evangelos Georgiou on 03/02/2014.
//  Copyright (c) 2014 Evangelos Georgiou. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "Settings.h"
//#import <CocoaAsyncSocket/GCDAsyncUdpSocket.h>
#import <CocoaAsyncSocket/GCDAsyncSocket.h>
#import "Reachability.h"
#import <Accounts/Accounts.h>
#import <Social/Social.h>
#import <QuartzCore/QuartzCore.h>

@interface dataViewController : UIViewController<GCDAsyncSocketDelegate, UITableViewDelegate, UITableViewDataSource>
{
    //GCDAsyncUdpSocket *udpSocket;
    GCDAsyncSocket *tcpsocket;
    NSTimer *timer;
    
    NSString *ipaddress;
    NSString *port;
    NSString *battery;

    SLComposeViewController *mySLComposerSheet;
}

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@property (strong, nonatomic) IBOutlet UITableView *tableview;

@property (nonatomic, retain) NSArray *analogPinNameArray;
@property (nonatomic, strong) NSMutableArray *analogPinValueArray;

@property (nonatomic, retain) NSArray *digitalPinNameArray;
@property (nonatomic, strong) NSMutableArray *digitalPinValueArray;

- (IBAction)infoButtonPressed:(id)sender;
- (IBAction)facebookButtonPressed:(id)sender;
- (IBAction)twitterButtonPressed:(id)sender;

@end
