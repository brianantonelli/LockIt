//
//  ViewController.h
//  LockIt
//
//  Created by Brian Antonelli on 10/17/12.
//  Copyright (c) 2012 Brian Antonelli. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SettingsViewController.h"

@interface ViewController : UIViewController<SettingsViewDelegate>

@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic) IBOutlet UILabel *lastUpdateLabel;
@property (weak, nonatomic) IBOutlet UIButton *lockButton;
@property (weak, nonatomic) IBOutlet UIButton *unlockButton;
@property (weak, nonatomic) IBOutlet UIImageView *lockImageView;

- (IBAction)didTapLock:(id)sender;
- (IBAction)didTapUnlock:(id)sender;
- (void) requestLockState;
- (void) readLastStateResponse;

@end
