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
    BOOL requestingLockState;
}
-(void) requestLockState;
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark Private Methods

-(void) requestLockState{
    if(requestingLockState) return;
    
    requestingLockState = YES;
    
    
}

#pragma mark -
#pragma mark IBActions

- (IBAction)didTapLock:(id)sender {
    NSLog(@"did tap lock!");

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
    NSLog(@"did tap unlock!");

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
@end
