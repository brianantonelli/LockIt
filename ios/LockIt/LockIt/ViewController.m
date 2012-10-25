//
//  ViewController.m
//  LockIt
//
//  Created by Brian Antonelli on 10/17/12.
//  Copyright (c) 2012 Brian Antonelli. All rights reserved.
//

#import "ViewController.h"
#import "LockEngine.h"

#define kCommandLock @"Lock"
#define kCommandUnlock @"Unlock"
#define kCommandStatus @"GetState"

@interface ViewController (){
    BOOL readingLockState;
    long lastResponseID;
    int attempts;
    NSTimer *staleAnimator;
}
-(void) styleButton:(UIButton*)button withColor:(NSString*)color;
-(void) animateStale;
@end

@implementation ViewController

- (void)viewDidLoad
{
    lastResponseID = 0;
    attempts = 0;
    
    // Background gradient
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"NSTexturedFullScreenBackgroundColor.png"]]];
    
    // Style buttons
    [self styleButton:_lockButton withColor:@"blue"];
    [self styleButton:_unlockButton withColor:@"blue"];
    
    // Style navigation bar
    self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:248/1000 green:248/1000 blue:248/1000 alpha:1];

    [super viewDidLoad];
}

-(void) styleButton:(UIButton*)button withColor:(NSString*)color{
    // a bit hacky
    UIImage *buttonImage = [[UIImage imageNamed:[NSString stringWithFormat:@"%@Button.png", color]] resizableImageWithCapInsets:UIEdgeInsetsMake(18, 18, 18, 18)];
    UIImage *buttonImageHighlight = [[UIImage imageNamed:[NSString stringWithFormat:@"%@ButtonHighlight.png", color]] resizableImageWithCapInsets:UIEdgeInsetsMake(18, 18, 18, 18)];
    [button setBackgroundImage:buttonImage forState:UIControlStateNormal];
    [button setBackgroundImage:buttonImageHighlight forState:UIControlStateHighlighted];
    
    [button setTitleColor:(([color isEqualToString:@"grey"]) ? [UIColor lightGrayColor] : [UIColor whiteColor]) forState:UIControlStateNormal];
    [button setTitleColor:(([color isEqualToString:@"grey"]) ? [UIColor lightGrayColor] : [UIColor whiteColor]) forState:UIControlStateHighlighted];
}

-(void)viewDidAppear:(BOOL)animated{
    [self enableUnknownMode];
    [self requestLockState];
    
    [super viewDidAppear:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    SettingsViewController *settingsVC = [segue destinationViewController];
    settingsVC.delegate = self;
}

-(void) requestLockState{
    NSLog(@"requestLockState");
    LockEngine *engine = ApplicationDelegate.lockEngine;
    
    [engine sendCommand:kCommandStatus
              withToken:ApplicationDelegate.deviceToken
    onCompletion:^(id jsonResponse) {
        [self readLastStateResponse];
    }
    onError:^(NSError *error) {
        NSLog(@"Error sending command: %@", [error localizedDescription]);
    }];
}

- (void) readLastStateResponse{
    if(readingLockState) return;

    readingLockState = YES;
    LockEngine *engine = ApplicationDelegate.lockEngine;

    [engine getLatestStateOnCompletion:^(id jsonResponse) {
        readingLockState = NO;
        jsonResponse = [jsonResponse objectAtIndex:0];
        NSString *idStr = [jsonResponse objectForKey:@"id"];
        long rId = [idStr longLongValue];
        BOOL stale = [[jsonResponse objectForKey:@"stale"] boolValue];
        if(rId > lastResponseID || stale){
            lastResponseID = rId;
            
            BOOL locked = [[jsonResponse objectForKey:@"state"] isEqualToString:@"Locked"];

            if(locked){
                [_statusLabel setText:@"Your front door is locked."];
                [_lockImageView setImage:[UIImage imageNamed:@"locked.png"]];
                [self styleButton:_lockButton withColor:@"grey"];
                [_lockButton setEnabled:NO];
                [self styleButton:_unlockButton withColor:@"blue"];
                [_unlockButton setEnabled:YES];
            }
            else{
                [_statusLabel setText:@"Your front door is unlocked."];
                [_lockImageView setImage:[UIImage imageNamed:@"unlocked.png"]];
                [self styleButton:_lockButton withColor:@"blue"];
                [_lockButton setEnabled:YES];
                [self styleButton:_unlockButton withColor:@"grey"];
                [_unlockButton setEnabled:NO];
            }
            
            if(stale){
                [self enableUnknownMode];
            }
            else{
                [self disableUnknownMode];
            }

            [_lastUpdateLabel setText:[NSString stringWithFormat:@"Updated %@", [jsonResponse objectForKey:@"time_processed"]]];
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 3 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                [self requestLockState];
            });
        }
        else{
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                [self readLastStateResponse];
            });
        }
    } onError:^(NSError *error) {
        NSLog(@"Error getting lock state: %@", [error localizedDescription]);
        readingLockState = NO;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            [self readLastStateResponse];
        });
    }];
}

-(void) enableUnknownMode{
    [_statusLabel setText:@"Door Status Unknown"];
    [_unlockButton setEnabled:NO];
    [_lockButton setEnabled:NO];

    if(staleAnimator == nil){
        staleAnimator = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(animateStale) userInfo:nil repeats:YES];
    }
}

-(void) disableUnknownMode{
    if(staleAnimator == nil) return;
    
    [staleAnimator invalidate];
    staleAnimator = nil;
    
    [_unknownLabel setHidden:YES];
}

#pragma mark - Private
                     
-(void) animateStale{
    if([_unknownLabel isHidden]){
        [_unknownLabel setHidden:NO];
    }
    else{
        [_unknownLabel setHidden:YES];
    }
}
                     
#pragma mark - IBActions

- (IBAction)didTapLock:(id)sender {
    LockEngine *engine = ApplicationDelegate.lockEngine;

    [engine sendCommand:kCommandLock
              withToken:ApplicationDelegate.deviceToken
    onCompletion:^(id jsonResponse) {
        NSLog(@"Response: %@", jsonResponse);
    }
    onError:^(NSError *error) {
        [[[UIAlertView alloc] initWithTitle:@"Error Locking"
                                   message:[error localizedDescription]
                                  delegate:nil
                         cancelButtonTitle:nil
                          otherButtonTitles:@"Ok", nil] show];
    }];
}

- (IBAction)didTapUnlock:(id)sender {
    LockEngine *engine = ApplicationDelegate.lockEngine;
    NSLog(@"locKEngine %@", engine);
    [engine sendCommand:kCommandUnlock
              withToken:ApplicationDelegate.deviceToken
    onCompletion:^(id jsonResponse) {
       NSLog(@"Response: %@", jsonResponse);
    }
    onError:^(NSError *error) {
        [[[UIAlertView alloc] initWithTitle:@"Error Unlocking"
                                    message:[error localizedDescription]
                                   delegate:nil
                          cancelButtonTitle:nil
                          otherButtonTitles:@"Ok", nil] show];
    }];
}

#pragma mark - SettingsViewDelegate

-(void) settingsViewDidDismiss{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
