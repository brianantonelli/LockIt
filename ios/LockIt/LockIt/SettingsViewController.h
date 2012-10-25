//
//  SettnigsViewController.h
//  LockIt
//
//  Created by Brian Antonelli on 10/21/12.
//  Copyright (c) 2012 Brian Antonelli. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SettingsViewDelegate

-(void) settingsViewDidDismiss;

@end

@interface SettingsViewController : UITableViewController

@property (weak, nonatomic) IBOutlet UINavigationBar *navBar;
@property(nonatomic, assign) id<SettingsViewDelegate> delegate;
@property (weak, nonatomic) IBOutlet UILabel *serverLabel;

- (IBAction)didTapDoneButton:(id)sender;

@end
