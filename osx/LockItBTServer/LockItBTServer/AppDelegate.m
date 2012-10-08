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
- (void)updateStatus:(NSString*)statusText withGoodFeeling:(BOOL)feelingGood;
@end

@implementation AppDelegate

@synthesize statusLabel = _statusLabel,
            consoleTextView = _consoleTextView,
            connectButton = _connectButton,
            device = _device,
            channel = _channel;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    [_connectButton setTitle:@"Connect"];
    [_connectButton setEnabled:NO];
    [self connectToDevice];
}

-(void)applicationWillTerminate:(NSNotification *)notification{
    [self disconnectFromDevice];
}

- (IBAction)didTouchConnectButton:(id)sender {
    if([_connectButton.title isEqualToString:@"Connect"]){
        [self connectToDevice];
    }
    else{
        [self disconnectFromDevice];
    }
}

#pragma mark - Private
//http://kristianlindroos.wordpress.com/tag/iobluetooth/

- (void)connectToDevice{
    IOBluetoothDeviceSelectorController * deviceSelectVC = [IOBluetoothDeviceSelectorController deviceSelector];
    [self updateStatus:@"Not Connected" withGoodFeeling:NO];
    [self log:@"Finding devices.."];
    
    int t = [deviceSelectVC runModal];
    
    if(t == kIOBluetoothUISuccess){
        _device = [[deviceSelectVC getResults] lastObject];
        [self updateStatus:[NSString stringWithFormat:@"Connecting to %@", [_device name]] withGoodFeeling:YES];
        [self log:_statusLabel.stringValue];
    }
    else{
        [self updateStatus:@"Could not find any devices" withGoodFeeling:NO];
        [self log:@"Device selection failed.."];
    }
    
    if([_device openConnection] == kIOReturnSuccess){
        [self log:@"Connection opened.."];
    }
    else{
        [self log:@"Connection not opened.."];
    }
    
    [_connectButton setTitle:@"Connect"];
    [_connectButton setEnabled:YES];

    if([_device isConnected]){
        [self log:@"Device connected"];
        [self log:@"Opening comm channel.."];
        IOBluetoothRFCOMMChannel *newChannel;
        [_device openRFCOMMChannelSync:&newChannel withChannelID:1 delegate:self];
        if([newChannel isOpen]){
            [newChannel setDelegate:self];
            _channel = newChannel;
            [self updateStatus:[NSString stringWithFormat:@"Connected to %@", [_device name]] withGoodFeeling:YES];
            [self log:_statusLabel.stringValue];
            
            [_connectButton setTitle:@"Disconnect"];
            [_connectButton setEnabled:YES];
            
            [self sendStringDataToDevice:@"H"];
        }
        else{
            [self updateStatus:@"Disconnected.." withGoodFeeling:NO];
            [self log:@"Channel not opened"];
        }
    }
    else{
        [self updateStatus:@"Connection failed.." withGoodFeeling:NO];
        [self log:_statusLabel.stringValue];
    }
}

- (void)disconnectFromDevice{
    if([_device isConnected]){
        [_device closeConnection];
        [self updateStatus:@"Disconnected" withGoodFeeling:NO];
    }
    [_connectButton setTitle:@"Connect"];
    [_connectButton setEnabled:YES];
}

- (void)sendStringDataToDevice:(NSString *)data {
    NSData *theData = [data dataUsingEncoding:NSASCIIStringEncoding];
    [_channel writeSync:&theData length:[theData length]];
}

- (void)log:(NSString*)text{
    [_consoleTextView setString:[NSString stringWithFormat:@"%@\n%@", _consoleTextView.string, text]];
}

- (void)updateStatus:(NSString*)statusText withGoodFeeling:(BOOL)feelingGood{
    [_statusLabel setStringValue:statusText];
    [_statusLabel setTextColor:feelingGood? [NSColor greenColor] : [NSColor redColor]];
}

#pragma mark - IOBluetoothRFCOMMChannelDelegate

- (void)rfcommChannelData:(IOBluetoothRFCOMMChannel*)rfcommChannel data:(void *)dataPointer length:(size_t)dataLength{
    NSData *data = [NSData dataWithBytes:dataPointer length:dataLength];
    NSString *value = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"Received data: %@", value);
}

- (void)rfcommChannelClosed:(IOBluetoothRFCOMMChannel*)rfcommChannel{
    [self disconnectFromDevice];
}

@end
