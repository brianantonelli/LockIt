//
//  BTEngine.h
//  LockItBTServer
//
//  Created by Brian Antonelli on 10/16/12.
//  Copyright (c) 2012 Brian Antonelli. All rights reserved.
//

#import "MKNetworkKit.h"
#define kBTEngineURL @"127.0.0.1/lockit"

@interface BTEngine : MKNetworkEngine

typedef void (^BTResponseBlock)(id jsonResponse);

-(void) getCommandsOnCompletion:(BTResponseBlock)completionBlock onError:(MKNKErrorBlock)errorBlock;

-(void) updateCommandID:(NSString*)commandId withCode:(NSString*)code andStatus:(NSString*)status andPayload:(NSString*)payload onCompletion:(BTResponseBlock)completionBlock onError:(MKNKErrorBlock)errorBlock;

-(void) sendPushMessage:(NSString*)message;

-(void) sendState:(NSString*)state;

@end
