//
//  BTEngine.m
//  LockItBTServer
//
//  Created by Brian Antonelli on 10/16/12.
//  Copyright (c) 2012 Brian Antonelli. All rights reserved.
//

#import "BTEngine.h"

@implementation BTEngine

-(void) getCommandsOnCompletion:(BTResponseBlock)completionBlock onError:(MKNKErrorBlock)errorBlock{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"get_new_commands", @"command", nil];
    
    MKNetworkOperation *op = [self operationWithPath:@"service_bt.php" params:params];
    [op onCompletion:^(MKNetworkOperation *completedOperation) {
        completionBlock([completedOperation responseJSON]);
    } onError:^(NSError *error) {
        errorBlock(error);
    }];
    [self enqueueOperation:op];
}

-(void) updateCommandID:(NSString*)commandId withCode:(NSString*)code andStatus:(NSString*)status andPayload:(NSString*)payload onCompletion:(BTResponseBlock)completionBlock onError:(MKNKErrorBlock)errorBlock{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                            @"update_command", @"command", 
                            commandId, @"command_id", 
                            code, @"response_code", 
                            status, @"status", 
                            payload, @"payload", nil];
    
    MKNetworkOperation *op = [self operationWithPath:@"service_bt.php" params:params];
    [op onCompletion:^(MKNetworkOperation *completedOperation) {
        completionBlock([completedOperation responseJSON]);
    } onError:^(NSError *error) {
        errorBlock(error);
    }];
    [self enqueueOperation:op];
}

-(void) sendPushMessage:(NSString*)message{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"send_message", @"command", message, @"message", nil];
    
    MKNetworkOperation *op = [self operationWithPath:@"service_bt.php" params:params];
    [self enqueueOperation:op];
}

@end
