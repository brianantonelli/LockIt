//
//  SettnigsViewController.m
//  LockIt
//
//  Created by Brian Antonelli on 10/21/12.
//  Copyright (c) 2012 Brian Antonelli. All rights reserved.
//

#import "SettingsViewController.h"

@interface SettingsViewController ()

@end

@implementation SettingsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Background gradient
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"NSTexturedFullScreenBackgroundColor.png"]]];
    
    // Style buttons
    UIImage *buttonImage = [[UIImage imageNamed:@"blueButton.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(18, 18, 18, 18)];
    UIImage *buttonImageHighlight = [[UIImage imageNamed:@"blueButtonHighlight.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(18, 18, 18, 18)];
    //        [_lockButton setBackgroundImage:buttonImage forState:UIControlStateNormal];
    //        [_lockButton setBackgroundImage:buttonImageHighlight forState:UIControlStateHighlighted];
    
    // Style navigation bar
    _navBar.tintColor = [UIColor colorWithRed:248/1000 green:248/1000 blue:248/1000 alpha:1];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)didTapDoneButton:(id)sender {
    if(_delegate) [_delegate settingsViewDidDismiss];
}
@end
