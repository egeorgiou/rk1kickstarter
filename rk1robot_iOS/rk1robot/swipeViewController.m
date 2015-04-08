//
//  swipeViewController.m
//  rk1robot
//
//  Created by Evangelos Georgiou on 26/01/2014.
//  Copyright (c) 2014 Evangelos Georgiou. All rights reserved.
//

#import "swipeViewController.h"

@interface swipeViewController ()

@end

@implementation swipeViewController

@synthesize leftLabel, rightLabel, ipaddressLabel, portLabel, batteryLabel;

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

- (void)viewDidAppear:(BOOL)animated
{
    Reachability *networkReachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [networkReachability currentReachabilityStatus];
    if (networkStatus == NotReachable) {
        NSLog(@"There is NO connection");
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"No connection" message:[NSString stringWithFormat:@"Connection is not reachable..."] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        
        alertView.tag = 0;
        [alertView show];
    }
    else {
        NSLog(@"There IS internet connection");
        
    }
    
    AppDelegate* appDelegate = [UIApplication sharedApplication].delegate;
    self.managedObjectContext = appDelegate.managedObjectContext;
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Settings" inManagedObjectContext:self.managedObjectContext];
    
    [fetchRequest setEntity:entity];
    
    NSError* error;
    NSArray *fetchedRecords = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    if (fetchedRecords.count == 0) {
        Settings *newEntry = [NSEntityDescription insertNewObjectForEntityForName:@"Settings" inManagedObjectContext:self.managedObjectContext];
        
        newEntry.ipaddress = @"192.168.1.1";
        newEntry.port = [NSNumber numberWithInt:2000];
        newEntry.leftmotorstate = [NSNumber numberWithBool:NO];
        newEntry.rightmotorstate = [NSNumber numberWithBool:NO];
        newEntry.direction = [NSNumber numberWithBool:NO];
        
        NSError *error;
        if (![self.managedObjectContext save:&error]) {
            NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
        }
        
        ipaddressLabel.text = [NSString stringWithFormat:@"192.168.1.1"];
        portLabel.text = [NSString stringWithFormat:@"2000"];
    }
    else
    {
        Settings *record = [fetchedRecords objectAtIndex:0];
        ipaddressLabel.text = [NSString stringWithFormat:@"%@", record.ipaddress];
        portLabel.text = [NSString stringWithFormat:@"%@", record.port];
        leftmotorstate = [record.leftmotorstate boolValue];
        rightmotorstate = [record.rightmotorstate boolValue];
        directionstate = [record.direction boolValue];
    }
    
    left = 0;
    right = 0;
    
    leftDirection = NO;
    rightDirection = NO;
    
    dispatch_queue_t mainQueue = dispatch_get_main_queue();
    tcpsocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:mainQueue];
    
    NSError *err = nil;
    if (![tcpsocket connectToHost:ipaddressLabel.text onPort:[portLabel.text integerValue] error:&err]) // Asynchronous!
    {
        // If there was an error, it's likely something like "already connected" or "no delegate set"
        NSLog(@"listen error: %@", err);
    }
    
    timer = [NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(onTimer) userInfo:nil repeats:YES];
}

-(void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port
{
    
    [tcpsocket readDataWithTimeout:-1 tag:0];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)sendUDPMotorControl:(BOOL)leftMotorDirection leftMotor:(int)leftMotor rightMotorDirection:(BOOL)rightMotorDirection rightMotor:(int)rightMotor
{
    int LMD = -1;
    
    if (leftmotorstate) {
        if (leftMotorDirection == YES) {
            LMD = 0;
        }
        else if (leftMotorDirection == NO) {
            LMD = 1;
        }
    }
    else
    {
        if (leftMotorDirection == YES) {
            LMD = 1;
        }
        else if (leftMotorDirection == NO) {
            LMD = 0;
        }
    }
    
    int RMD = -1;
    
    if (rightmotorstate) {
        if (rightMotorDirection == YES) {
            RMD = 0;
        }
        else if (rightMotorDirection == NO) {
            RMD = 1;
        }
    }
    else {
        if (rightMotorDirection == YES) {
            RMD = 1;
        }
        else if (rightMotorDirection == NO) {
            RMD = 0;
        }
    }
    
    if (directionstate) {
        if (leftmotorstate) {
            if (!rightmotorstate) {
                if (LMD == 1 && RMD == 0) {
                    LMD = 0;
                    RMD = 1;
                } else if (LMD == 0 && RMD == 1) {
                    LMD = 1;
                    RMD = 0;
                }
            } else {
                if (LMD == 0 && RMD == 0) {
                    LMD = 1;
                    RMD = 1;
                } else if (LMD == 1 && RMD == 1) {
                    LMD = 0;
                    RMD = 0;
                }
            }
        }
        else {
            if (LMD == 0 && RMD == 0) {
                LMD = 1;
                RMD = 1;
            } else if (LMD == 1 && RMD == 1) {
                LMD = 0;
                RMD = 0;
            }
        }
        
    }

    Byte TxDataBytes[5];
    
	TxDataBytes[0] = 1;
	TxDataBytes[1] = LMD;
	TxDataBytes[2] = leftMotor;
	TxDataBytes[3] = RMD;
    TxDataBytes[4] = rightMotor;
    
    NSLog(@"d0: %d, d1: %d, d2: %d, d3: %d, d4: %d", TxDataBytes[0], TxDataBytes[1], TxDataBytes[2], TxDataBytes[3], TxDataBytes[4]);
    
    NSData *TxData = [[NSData alloc] initWithBytes:TxDataBytes length:5];

    [tcpsocket writeData:TxData withTimeout:-1 tag:0];
    
}

- (IBAction)infoButtonPressed:(id)sender {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"RK1 | Information" message:[NSString stringWithFormat:@"To control the RK1 robot swipe (up | down | left | right) to increase the velocity of RK1 robot."] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    
    alertView.tag = 0;
    [alertView show];
}

- (IBAction)swipeupGesture:(id)sender {
    if (leftDirection ==  NO)
    {
        left = left + 50;
        
        if (left > 250) {
            left = 250;
        }
        
    }
    else if (leftDirection == YES)
    {
        left = left - 50;
        
        if (left < 0)
        {
            left = 50;
            
            leftDirection = NO;
            [leftLabel setTextColor:[UIColor blackColor]];
        }
    }
    
    if (rightDirection ==  NO)
    {
        right = right + 50;
        
        if (right > 250) {
            right = 250;
        }

    }
    else if (rightDirection == YES)
    {
        right = right - 50;
        
        if (right < 0)
        {
            right = 50;
            
            rightDirection = NO;
            [rightLabel setTextColor:[UIColor blackColor]];
        }
    }
    
    [leftLabel setText:[NSString stringWithFormat:@"%u", left]];
    [rightLabel setText:[NSString stringWithFormat:@"%u", right]];
}

- (IBAction)swipedownGesture:(id)sender {
    if (leftDirection ==  NO)
    {
        left = left - 50;
        
        if (left < 0) {
            left = 50;
            
            leftDirection = YES;
            [leftLabel setTextColor:[UIColor redColor]];
        }
        
    }
    else if (leftDirection == YES)
    {
        left = left + 50;
        
        if (left > 250)
        {
            left = 250;
        }
    }
    
    if (rightDirection ==  NO)
    {
        right = right - 50;
        
        if (right < 0) {
            right = 50;
            
            rightDirection = YES;
            [rightLabel setTextColor:[UIColor redColor]];
        }
        
    }
    else if (rightDirection == YES)
    {
        right = right + 50;
        
        if (right > 250)
        {
            right = 250;
        }
    }
    
    [leftLabel setText:[NSString stringWithFormat:@"%u", left]];
    [rightLabel setText:[NSString stringWithFormat:@"%u", right]];
}

- (IBAction)swipeleftGesture:(id)sender {
    if (leftDirection ==  NO)
    {
        left = left + 50;
        
        if (left > 250) {
            left = 250;
        }
        
    }
    else if (leftDirection == YES)
    {
        left = left - 50;
        
        if (left < 0)
        {
            left = 50;
            
            leftDirection = NO;
            [leftLabel setTextColor:[UIColor blackColor]];
        }
    }
    
    if (rightDirection ==  NO)
    {
        right = right - 50;
        
        if (right < 0) {
            right = 50;
            
            rightDirection = YES;
            [rightLabel setTextColor:[UIColor redColor]];
        }
        
    }
    else if (rightDirection == YES)
    {
        right = right + 50;
        
        if (right > 250)
        {
            right = 250;
        }
    }
    
    [leftLabel setText:[NSString stringWithFormat:@"%u", left]];
    [rightLabel setText:[NSString stringWithFormat:@"%u", right]];
}

- (IBAction)swiperightGesture:(id)sender {
    if (leftDirection ==  NO)
    {
        left = left - 50;
        
        if (left < 0) {
            left = 50;
            
            leftDirection = YES;
            [leftLabel setTextColor:[UIColor redColor]];
        }
        
    }
    else if (leftDirection == YES)
    {
        left = left + 50;
        
        if (left > 250)
        {
            left = 250;
        }
    }
    
    if (rightDirection ==  NO)
    {
        right = right + 50;
        
        if (right > 250) {
            right = 250;
        }
        
    }
    else if (rightDirection == YES)
    {
        right = right - 50;
        
        if (right < 0)
        {
            right = 50;
            
            rightDirection = NO;
            [rightLabel setTextColor:[UIColor blackColor]];
        }
    }
    
    [leftLabel setText:[NSString stringWithFormat:@"%u", left]];
    [rightLabel setText:[NSString stringWithFormat:@"%u", right]];
}

- (IBAction)tapGesture:(id)sender {
    leftDirection = NO;
    rightDirection = NO;
    
    left = 0;
    right = 0;
    
    [leftLabel setTextColor:[UIColor blackColor]];
    [rightLabel setTextColor:[UIColor blackColor]];
    
    [leftLabel setText:[NSString stringWithFormat:@"%u", left]];
    [rightLabel setText:[NSString stringWithFormat:@"%u", right]];
}

- (IBAction)facebookButtonPressed:(id)sender {
    mySLComposerSheet = [[SLComposeViewController alloc] init];
    mySLComposerSheet = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
    [mySLComposerSheet setInitialText:@"#rk1robot I'm using a RK1 iOS application! http://www.mymobilerobots.com/rk1"];
    [self presentViewController:mySLComposerSheet animated:YES completion:NULL];
}

- (IBAction)twitterButtonPressed:(id)sender {
    mySLComposerSheet = [[SLComposeViewController alloc] init];
    mySLComposerSheet = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
    [mySLComposerSheet setInitialText:@"#rk1robot I'm using a RK1 iOS application! http://www.mymobilerobots.com/rk1"];
    [self presentViewController:mySLComposerSheet animated:YES completion:NULL];
}

-(void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
    NSLog(@"Received UDP Packet");
    
    UInt8 *bytes = (UInt8 *)data.bytes;
    
    uint16_t updateValue = 0;
    updateValue = (bytes[2] << 8) | bytes[1];
    float voltage = updateValue * (5.0 / 1023.0);
    
    NSLog(@"%f", voltage);
    
    if (voltage > 2.0f && voltage < 4.5) {
        [batteryLabel setText:[NSString stringWithFormat:@"%.2fv", voltage]];
        
        if (voltage < 3.2) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"RK1 | Warning" message:[NSString stringWithFormat:@"The battery level on RK-1 Robot is too low!"] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            
            alertView.tag = 0;
            [alertView show];
        }
    }
    
    [tcpsocket readDataWithTimeout:-1 tag:0];
}

-(void)onTimer
{
    NSLog(@"Timer started");

    [self sendUDPMotorControl:leftDirection leftMotor:left rightMotorDirection:rightDirection rightMotor:right];
}

@end
