//
//  AppDelegate.h
//  LockIt
//
//  Created by Brian Antonelli on 10/17/12.
//  Copyright (c) 2012 Brian Antonelli. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LockEngine.h"

#define ApplicationDelegate ((AppDelegate *)[UIApplication sharedApplication].delegate)

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property(nonatomic, strong) LockEngine *lockEngine;
@property(nonatomic, strong) NSString *deviceToken;

@end
