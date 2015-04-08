//
//  settingsViewController.h
//  rk1robot
//
//  Created by Evangelos Georgiou on 26/01/2014.
//  Copyright (c) 2014 Evangelos Georgiou. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "Settings.h"
#import <Accounts/Accounts.h>
#import <Social/Social.h>
#import <QuartzCore/QuartzCore.h>

@interface settingsViewController : UIViewController<UITextFieldDelegate>
{
    SLComposeViewController *mySLComposerSheet;
}

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (strong, nonatomic) IBOutlet UITextField *ipaddressTextfield;
@property (strong, nonatomic) IBOutlet UITextField *portnumberTextfield;

- (IBAction)saveButtonPressed:(id)sender;

- (IBAction)screenTapped:(id)sender;

- (IBAction)facebookButtonPressed:(id)sender;
- (IBAction)twitterButtonPressed:(id)sender;
@end
