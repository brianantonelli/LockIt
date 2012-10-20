//
//  LockEngine.m
//  LockIt
//
//  Created by Brian Antonelli on 10/18/12.
//  Copyright (c) 2012 Brian Antonelli. All rights reserved.
//

#import "LockEngine.h"

@implementation LockEngine

-(void)registerToken:(NSString *)token withUDID:(NSString *)udid onCompletion:(WebServiceResponseBlock)completionBlock onError:(MKNKErrorBlock)errorBlock{
    MKNetworkOperation *op = [self operationWithPath:@"service_app.php" params:[NSMutableDictionary dictionaryWithObjectsAndKeys:token, @"device_token", udid, @"udid", @"register", @"command", nil]];
    [op onCompletion:^(MKNetworkOperation *completedOperation) {
        completionBlock([completedOperation responseJSON]);
    } onError:^(NSError *error) {
        errorBlock(error);
    }];
    [self enqueueOperation:op];
}

-(void) sendCommand:(NSString *)command withToken:(NSString *)token onCompletion:(WebServiceResponseBlock)completionBlock onError:(MKNKErrorBlock)errorBlock{
    NSLog(@"sendCommand");
    MKNetworkOperation *op = [self operationWithPath:@"service_app.php" params:[NSMutableDictionary dictionaryWithObjectsAndKeys:token, @"device_token", command, @"execute_command", @"send_command", @"command", nil]];
    [op onCompletion:^(MKNetworkOperation *completedOperation) {
        completionBlock([completedOperation responseJSON]);
    } onError:^(NSError *error) {
        errorBlock(error);
    }];
    [self enqueueOperation:op];
}

-(void) getLatestStateOnCompletion:(WebServiceResponseBlock)completionBlock
                           onError:(MKNKErrorBlock)errorBlock{
    MKNetworkOperation *op = [self operationWithPath:@"service_app.php" params:[NSMutableDictionary dictionaryWithObjectsAndKeys:@"get_last_state_response", @"command", nil]];
    [op onCompletion:^(MKNetworkOperation *completedOperation) {
        completionBlock([completedOperation responseJSON]);
    } onError:^(NSError *error) {
        errorBlock(error);
    }];
    [self enqueueOperation:op];
}

@end
