//
//  LockEngine.h
//  LockIt
//
//  Created by Brian Antonelli on 10/18/12.
//  Copyright (c) 2012 Brian Antonelli. All rights reserved.
//

#define kLockEngineURL @"127.0.0.1/lockit"

typedef void (^WebServiceResponseBlock)(id jsonResponse);

@interface LockEngine : MKNetworkEngine

-(void) registerToken:(NSString*)token
             withUDID:(NSString*)udid
         onCompletion:(WebServiceResponseBlock)completionBlock
              onError:(MKNKErrorBlock)errorBlock;

-(void) sendCommand:(NSString*)command
          withToken:(NSString*)token
       onCompletion:(WebServiceResponseBlock)completionBlock
            onError:(MKNKErrorBlock)errorBlock;

@end
