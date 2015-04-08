//
//  settingsViewController.m
//  rk1robot
//
//  Created by Evangelos Georgiou on 26/01/2014.
//  Copyright (c) 2014 Evangelos Georgiou. All rights reserved.
//

#import "settingsViewController.h"

@interface settingsViewController ()

@end

@implementation settingsViewController

@synthesize ipaddressTextfield, portnumberTextfield, leftmotorstate, rightmotorstate, directionstate;

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
        
        ipaddressTextfield.text = [NSString stringWithFormat:@"192.168.1.1"];
        portnumberTextfield.text = [NSString stringWithFormat:@"2000"];
        leftmotorstate.selectedSegmentIndex = 0;
        rightmotorstate.selectedSegmentIndex = 0;
        directionstate.selectedSegmentIndex = 0;
    }
    else
    {
        Settings *record = [fetchedRecords objectAtIndex:0];
        ipaddressTextfield.text = [NSString stringWithFormat:@"%@", record.ipaddress];
        portnumberTextfield.text = [NSString stringWithFormat:@"%@", record.port];
        
        NSNumber *leftmotorstateData = record.leftmotorstate;
        NSNumber *rightmotorstateData = record.rightmotorstate;
        
        if ([leftmotorstateData boolValue]) {
            leftmotorstate.selectedSegmentIndex = 1;
        }
        else
        {
            leftmotorstate.selectedSegmentIndex = 0;
        }
        
        if ([rightmotorstateData boolValue]) {
            rightmotorstate.selectedSegmentIndex = 1;
        }
        else
        {
            rightmotorstate.selectedSegmentIndex = 0;
        }
        
        NSNumber *directionstateData = record.direction;
        
        if ([directionstateData boolValue]) {
            directionstate.selectedSegmentIndex = 1;
        }
        else
        {
            directionstate.selectedSegmentIndex = 0;
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)leftmotorstateButtonPressed:(id)sender {
    
}

- (IBAction)rightmotorstateButtonPressed:(id)sender {
    
}

- (IBAction)directionstateButtonPressed:(id)sender {
}

- (IBAction)saveButtonPressed:(id)sender {
    if ([ipaddressTextfield.text length]) {
        AppDelegate* appDelegate = [UIApplication sharedApplication].delegate;
        self.managedObjectContext = appDelegate.managedObjectContext;
        
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"Settings" inManagedObjectContext:self.managedObjectContext];
        
        [fetchRequest setEntity:entity];
        
        NSError* error;
        NSArray *fetchedRecords = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
        
        for (id object in fetchedRecords) {
            [self.managedObjectContext deleteObject:object];
        }
        
        Settings *newEntry = [NSEntityDescription insertNewObjectForEntityForName:@"Settings" inManagedObjectContext:self.managedObjectContext];
        
        newEntry.ipaddress = ipaddressTextfield.text;
        newEntry.port = [NSNumber numberWithInt:[portnumberTextfield.text intValue]];
        
        if (leftmotorstate.selectedSegmentIndex == 0) {
            newEntry.leftmotorstate = [NSNumber numberWithBool:NO];
        }
        else if (leftmotorstate.selectedSegmentIndex == 1) {
            newEntry.leftmotorstate = [NSNumber numberWithBool:YES];
        }
        
        if (rightmotorstate.selectedSegmentIndex == 0) {
            newEntry.rightmotorstate = [NSNumber numberWithBool:NO];
        }
        else if (rightmotorstate.selectedSegmentIndex == 1) {
            newEntry.rightmotorstate = [NSNumber numberWithBool:YES];
        }
        
        if (directionstate.selectedSegmentIndex == 0) {
            newEntry.direction = [NSNumber numberWithBool:NO];
        }
        else if (directionstate.selectedSegmentIndex == 1) {
            newEntry.direction = [NSNumber numberWithBool:YES];
        }
        
        if (![self.managedObjectContext save:&error]) {
            NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
        }
    }
    
    [ipaddressTextfield resignFirstResponder];
    [portnumberTextfield resignFirstResponder];
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"WARNING!" message:[NSString stringWithFormat:@"For all changes to the RK1 settings please ensure the application is fully restarted!"] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    
    alertView.tag = 0;
    [alertView show];
}


- (IBAction)screenTapped:(id)sender {
    [ipaddressTextfield resignFirstResponder];
    [portnumberTextfield resignFirstResponder];
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

@end
