//
//  AppDelegate.m
//  LockItBTServer
//
//  Created by Brian Antonelli on 10/8/12.
//  Copyright (c) 2012 Brian Antonelli. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate()
- (void)connectToDevice;
- (void)disconnectFromDevice;
- (void)sendStringDataToDevice:(NSString *)data;
- (void)log:(NSString*)text;
@end

@implementation AppDelegate

@synthesize statusLabel = _statusLabel,
            consoleTextView = _consoleTextView,
            device = _device,
            channel = _channel;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    [self connectToDevice];
}

-(void)applicationWillTerminate:(NSNotification *)notification{
    [self disconnectFromDevice];
}

#pragma mark - Private
//http://kristianlindroos.wordpress.com/tag/iobluetooth/

- (void)connectToDevice{
    IOBluetoothDeviceSelectorController * deviceSelectVC = [IOBluetoothDeviceSelectorController deviceSelector];
    [_statusLabel setStringValue:@"Not Connected"];
    [self log:@"Finding devices.."];
    
    int t = [deviceSelectVC runModal];
    
    if(t == kIOBluetoothUISuccess){
        _device = [[deviceSelectVC getResults] lastObject];
        [_statusLabel setStringValue:[NSString stringWithFormat:@"Connecting to %@", [_device name]]];
        [self log:_statusLabel.stringValue];
    }
    else{
        [self log:@"Device selection failed.."];
    }
    
    if([_device openConnection] == kIOReturnSuccess){
        [self log:@"Connection opened.."];
    }
    else{
        [self log:@"Connection not opened.."];
    }
    
    if([_device isConnected]){
        [self log:@"Device connected"];
        IOBluetoothRFCOMMChannel *newChannel;
        [self log:@"Opening comm channel.."];
        [_device openRFCOMMChannelSync:&newChannel withChannelID:1 delegate:self];
        if([newChannel isOpen]){
            [newChannel setDelegate:self];
            _channel = newChannel;
            [_statusLabel setStringValue:[NSString stringWithFormat:@"Connected to %@", [_device name]]];
            [self log:_statusLabel.stringValue];
        }
        else{
            [_statusLabel setStringValue:@"Disconnected.."];
            [self log:@"Channel not opened"];
        }
    }
    else{
        [_statusLabel setStringValue:@"Connection failed.."];
        [self log:_statusLabel.stringValue];
    }
}

- (void)disconnectFromDevice{
    if([_device isConnected]){
        [_device closeConnection];
        [_statusLabel setStringValue:@"Disconnected.."];
    }
}

- (void)sendStringDataToDevice:(NSString *)data {
    NSData *theData = [data dataUsingEncoding:NSASCIIStringEncoding];
    [_channel writeSync:[theData bytes] length:[theData length]];
}

- (void)log:(NSString*)text{
    [_consoleTextView setString:[NSString stringWithFormat:@"%@\n%@", _consoleTextView.string, text]];
}

#pragma mark - IOBluetoothRFCOMMChannelDelegate

- (void)rfcommChannelData:(IOBluetoothRFCOMMChannel*)rfcommChannel data:(void *)dataPointer length:(size_t)dataLength{
    NSData *data = [NSData dataWithBytes:dataPointer length:dataLength];
    NSString *value = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"Received data: %@", value);
}

@end
