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
}
@end

@implementation ViewController

- (void)viewDidLoad
{
    lastResponseID = 0;
    [super viewDidLoad];
}

-(void)viewDidAppear:(BOOL)animated{
    [self requestLockState];
    
    [super viewDidAppear:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

-(void) requestLockState{
    
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
    NSLog(@"Reading State");
    if(readingLockState) return;
    
    readingLockState = YES;
    LockEngine *engine = ApplicationDelegate.lockEngine;

    [engine getLatestStateOnCompletion:^(id jsonResponse) {
        readingLockState = NO;
        jsonResponse = [jsonResponse objectAtIndex:0];
        NSString *idStr = [jsonResponse objectForKey:@"id"];
        NSLog(@"id = %@", idStr);
        long rId = [idStr longLongValue];
        NSLog(@"lid = %ld", rId);
        if(rId > lastResponseID){
            lastResponseID = rId;
            [_statusLabel setText:[jsonResponse objectForKey:@"state"]];
            [_lastUpdateLabel setText:[jsonResponse objectForKey:@"time_processed"]];
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 3 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                [self requestLockState];
            });
            
            NSLog(@"Received state: %@", [_statusLabel text]);
        }
        else{
            NSLog(@"Received stale lock state");
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
