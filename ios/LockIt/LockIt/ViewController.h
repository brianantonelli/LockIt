//
//  ViewController.h
//  LockIt
//
//  Created by Brian Antonelli on 10/17/12.
//  Copyright (c) 2012 Brian Antonelli. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController

@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic) IBOutlet UILabel *lastUpdateLabel;

- (IBAction)didTapLock:(id)sender;
- (IBAction)didTapUnlock:(id)sender;
- (void) requestLockState;
- (void) readLastStateResponse;

@end
