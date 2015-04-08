//
//  dataViewController.m
//  rk1data
//
//  Created by Evangelos Georgiou on 03/02/2014.
//  Copyright (c) 2014 Evangelos Georgiou. All rights reserved.
//

#import "dataViewController.h"

@interface dataViewController ()

@end

@implementation dataViewController

@synthesize analogPinNameArray, analogPinValueArray, digitalPinNameArray, digitalPinValueArray;

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
    
    ipaddress = [[NSString alloc] init];
    port = [[NSString alloc] init];
    battery = [[NSString alloc] init];
    battery = @"0v";
    
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
        
        ipaddress = [NSString stringWithFormat:@"192.168.1.1"];
        port = [NSString stringWithFormat:@"2000"];
    }
    else
    {
        Settings *record = [fetchedRecords objectAtIndex:0];
        ipaddress = [NSString stringWithFormat:@"%@", record.ipaddress];
        port = [NSString stringWithFormat:@"%@", record.port];
    }
    
    dispatch_queue_t mainQueue = dispatch_get_main_queue();
    tcpsocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:mainQueue];
    
    NSError *err = nil;
    if (![tcpsocket connectToHost:ipaddress onPort:[port integerValue] error:&err]) // Asynchronous!
    {
        // If there was an error, it's likely something like "already connected" or "no delegate set"
        NSLog(@"listen error: %@", err);
    }
    
    analogPinNameArray = [[NSArray alloc] initWithObjects:@"A0", @"A1", @"A2", @"A3", @"A4", @"A5", nil];
    analogPinValueArray = [[NSMutableArray alloc] initWithObjects:@"0", @"0", @"0", @"0", @"0", @"0", nil];
    
    digitalPinNameArray = [[NSArray alloc] initWithObjects:@"D10", @"D11", @"D12", @"D13", nil];
    digitalPinValueArray = [[NSMutableArray alloc] initWithObjects:@"LOW", @"LOW", @"LOW", @"LOW", nil];
    
    timer = [NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(onTimer) userInfo:nil repeats:YES];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)infoButtonPressed:(id)sender {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"RK-1 | Information" message:[NSString stringWithFormat:@"To get data from the RK1 robot make sure the wifi connection is enabled first."] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    
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

-(void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port
{
    
    [tcpsocket readDataWithTimeout:-1 tag:0];
}

-(void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
    NSLog(@"Received UDP Packet");
    
    UInt8 *bytes = (UInt8 *)data.bytes;
    
    uint16_t updateValue = 0;
    
    for (int i = 1; i < 7; i++) {
        updateValue = (bytes[i * 2] << 8) | bytes[(i * 2) - 1];
        
        [analogPinValueArray replaceObjectAtIndex:(i - 1) withObject:[NSNumber numberWithInt:updateValue]];
    }
    
    for (int j = 18; j < 22; j++) {
        NSString *pinState = @"LOW";
        if ((int)bytes[j] == 1) {
            pinState = @"HIGH";
        }
        [digitalPinValueArray replaceObjectAtIndex:(j - 18) withObject:pinState];
    }
    
    updateValue = (bytes[2] << 8) | bytes[1];
    float voltage = updateValue * (5.0 / 1023.0);
    
    NSLog(@"%f", voltage);
    
    if (voltage > 2.0f && voltage < 4.5) {
        battery = [NSString stringWithFormat:@"%.2fv", voltage];
        
        if (voltage < 3.2) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"RK1 | Warning" message:[NSString stringWithFormat:@"The battery level on RK-1 Robot is too low!"] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            
            alertView.tag = 0;
            [alertView show];
        }
    }
    
    [tcpsocket readDataWithTimeout:-1 tag:0];
    
    [self.tableview reloadData];
}

-(void)onTimer
{
    NSLog(@"Timer started");
    
    Byte TxDataBytes[5];
    
	TxDataBytes[0] = 2;
    TxDataBytes[1] = 0;
    TxDataBytes[2] = 0;
    TxDataBytes[3] = 0;
    TxDataBytes[4] = 0;
    
    NSData *TxData = [[NSData alloc] initWithBytes:TxDataBytes length:5];
    
    [tcpsocket writeData:TxData withTimeout:-1 tag:0];
}

-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView{
    return 3;
}

-(NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        return @"Settings";}
    if (section == 1) {
        return @"Analog Pin Data"; }
    if (section == 2) {
        return @"Digital Pin State"; }
    else {
        return @"default"; }
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 3;}
    if (section == 1) {
        return 6; }
    if (section == 2) {
        return 4; }
    else {
        return 0; }
}

-(UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    
    if (indexPath.section == 0) {
        switch (indexPath.item) {
            case 0:
                cell.textLabel.text = @"IP Address";
                cell.detailTextLabel.text = ipaddress;
                break;
            case 1:
                cell.textLabel.text = @"Port Number";
                cell.detailTextLabel.text = port;
                break;
            case 2:
                cell.textLabel.text = @"Battery";
                cell.detailTextLabel.text = battery;
                break;
            default:
                break;
        }
    }
    
    if (indexPath.section == 1) {
        cell.textLabel.text = [analogPinNameArray objectAtIndex:indexPath.item];
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", [analogPinValueArray objectAtIndex:indexPath.item]];
    }
    
    if (indexPath.section == 2) {
        cell.textLabel.text = [digitalPinNameArray objectAtIndex:indexPath.item];
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", [digitalPinValueArray objectAtIndex:indexPath.item]];
    }
    
    return cell;
}

@end
