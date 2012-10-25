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

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Background gradient
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"NSTexturedFullScreenBackgroundColor.png"]]];
        
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

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
}

@end
