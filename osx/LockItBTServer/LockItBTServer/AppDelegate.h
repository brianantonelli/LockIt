//
//  AppDelegate.h
//  LockItBTServer
//
//  Created by Brian Antonelli on 10/8/12.
//  Copyright (c) 2012 Brian Antonelli. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <IOBluetooth/IOBluetooth.h>
#import <IOBluetoothUI/IOBluetoothUI.h>

@interface AppDelegate : NSObject <NSApplicationDelegate, IOBluetoothRFCOMMChannelDelegate>{
    IOBluetoothRFCOMMChannel *__autoreleasing *channel;
}

@property(nonatomic, strong) IOBluetoothDevice *device;
@property(nonatomic, strong) IOBluetoothRFCOMMChannel *channel;

#pragma mark - IBOutlet

@property (assign) IBOutlet NSWindow *window;
@property (weak) IBOutlet NSTextField *statusLabel;
@property (strong) IBOutlet NSTextView *consoleTextView;

@end
