//
//  digitalcontrolViewController.m
//  rk1digital
//
//  Created by Evangelos Georgiou on 12/03/2014.
//  Copyright (c) 2014 Evangelos Georgiou. All rights reserved.
//

#import "digitalcontrolViewController.h"

@interface digitalcontrolViewController ()

@end

@implementation digitalcontrolViewController

@synthesize ipaddressLabel, portLabel, batteryLabel, digitalPinValueArray, pin10stateSegmentedControl, pin11stateSegmentedControl, pin12stateSegmentedControl, pin13stateSegmentedControl;

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
    }
    
    dispatch_queue_t mainQueue = dispatch_get_main_queue();
    tcpsocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:mainQueue];
    
    NSError *err = nil;
    if (![tcpsocket connectToHost:ipaddressLabel.text onPort:[portLabel.text integerValue] error:&err]) // Asynchronous!
    {
        // If there was an error, it's likely something like "already connected" or "no delegate set"
        NSLog(@"listen error: %@", err);
    }
    
    digitalPinValueArray = [[NSMutableArray alloc] initWithObjects:[NSNumber numberWithInt:0], [NSNumber numberWithInt:0], [NSNumber numberWithInt:0], [NSNumber numberWithInt:0], nil];
    
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

- (IBAction)infoButtonPressed:(id)sender {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"RK1 | Information" message:[NSString stringWithFormat:@"To control the RK1 robot digital pins use the segmented buttons to change the pin states."] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    
    alertView.tag = 0;
    [alertView show];
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
    
    [self sendDigitalPinControl:[digitalPinValueArray objectAtIndex:0] pin11:[digitalPinValueArray objectAtIndex:1] pin12:[digitalPinValueArray objectAtIndex:1] pin13:[digitalPinValueArray objectAtIndex:3]];
}

- (IBAction)pin10statechangeSegmentedControl:(id)sender {
    [digitalPinValueArray replaceObjectAtIndex:0 withObject:[NSNumber numberWithInt:(int)pin10stateSegmentedControl.selectedSegmentIndex]];
}

- (IBAction)pin11statechangeSegmentedControl:(id)sender {
    [digitalPinValueArray replaceObjectAtIndex:1 withObject:[NSNumber numberWithInt:(int)pin11stateSegmentedControl.selectedSegmentIndex]];
}

- (IBAction)pin12statechangeSegmentedControl:(id)sender {
    [digitalPinValueArray replaceObjectAtIndex:2 withObject:[NSNumber numberWithInt:(int)pin12stateSegmentedControl.selectedSegmentIndex]];
}

- (IBAction)pin13statechangeSegmentedControl:(id)sender {
    [digitalPinValueArray replaceObjectAtIndex:3 withObject:[NSNumber numberWithInt:(int)pin13stateSegmentedControl.selectedSegmentIndex]];
}

- (void)sendDigitalPinControl:(NSNumber *)pin10 pin11:(NSNumber *)pin11 pin12:(NSNumber *)pin12 pin13:(NSNumber *)pin13
{

    Byte TxDataBytes[5];
    
	TxDataBytes[0] = 3;
	TxDataBytes[1] = [pin10 intValue];
	TxDataBytes[2] = [pin11 intValue];
	TxDataBytes[3] = [pin12 intValue];
    TxDataBytes[4] = [pin13 intValue];
    
    NSLog(@"d0: %d, d1: %d, d2: %d, d3: %d, d4: %d", TxDataBytes[0], TxDataBytes[1], TxDataBytes[2], TxDataBytes[3], TxDataBytes[4]);
    
    NSData *TxData = [[NSData alloc] initWithBytes:TxDataBytes length:5];

    [tcpsocket writeData:TxData withTimeout:-1 tag:0];
    
}
@end
