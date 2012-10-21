//
//  AppDelegate.m
//  LockItBTServer
//
//  Created by Brian Antonelli on 10/8/12.
//  Copyright (c) 2012 Brian Antonelli. All rights reserved.
//

#import "AppDelegate.h"
#import "BTEngine.h"

#define kBTOutLock        @"l"
#define kBTOutUnlock      @"u"
#define kBTOutStatus      @"s"

#define kBTInLocked       @"1"
#define kBTInUnlocked     @"2"
#define kBTInKnocking     @"3"
#define kBTInLowBatt      @"4"
#define kBTInStateLocked  @"5"
#define kBTInStateUnlockd @"6"

#define kPushLocked       @"The front door was locked."
#define kPushUnlocked     @"The front door was unlocked."
#define kPushKnocking     @"Someone is knocking on the front door."
#define kPushLowBattery   @"Low battery!"

#define kStateLocked      @"locked"
#define kStateUnlocked    @"unlocked"

@interface AppDelegate(){
    BOOL connected;
}

@property(nonatomic, strong) NSTimer *commandChecker;
@property(nonatomic, strong) BTEngine *engine;

- (void)connectToDevice;
- (void)disconnectFromDevice;
- (void)sendStringDataToDevice:(NSString *)data;
- (void)log:(NSString*)text;
- (void)updateStatus:(NSString*)statusText withGoodFeeling:(BOOL)feelingGood;
- (void)onConnect;
- (void)onDisconnect;
@end

@implementation AppDelegate

@synthesize statusLabel = _statusLabel,
            consoleTextView = _consoleTextView,
            connectButton = _connectButton,
            device = _device,
            channel = _channel,
            commandChecker = _commandChecker,
            engine = _engine;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    [_connectButton setTitle:@"Connect"];
    [_connectButton setEnabled:NO];
    
    _engine = [[BTEngine alloc] initWithHostName:kBTEngineURL];
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
    [self onConnect];
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
            
            [self onConnect];
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
    [self onDisconnect];
    if([_device isConnected]){
        [_device closeConnection];
        [self updateStatus:@"Disconnected" withGoodFeeling:NO];
    }
    [_connectButton setTitle:@"Connect"];
    [_connectButton setEnabled:YES];
}

- (void)sendStringDataToDevice:(NSString *)data {
    NSData *theData = [data dataUsingEncoding:NSASCIIStringEncoding];
    [_channel writeSync:[theData bytes] length:[theData length]];
}

- (void)log:(NSString*)text{
    [_consoleTextView setString:[NSString stringWithFormat:@"%@\n%@", _consoleTextView.string, text]];
}

- (void)updateStatus:(NSString*)statusText withGoodFeeling:(BOOL)feelingGood{
    [_statusLabel setStringValue:statusText];
    [_statusLabel setTextColor:feelingGood? [NSColor greenColor] : [NSColor redColor]];
}

- (void)onConnect{
    connected = YES;
    _commandChecker = [NSTimer scheduledTimerWithTimeInterval:2.0
                                                       target:self
                                                     selector:@selector(checkForNewCommands)
                                                     userInfo:nil
                                                      repeats:YES];
}

- (void)onDisconnect{
    connected = NO;
    if(_commandChecker != nil){
        [_commandChecker invalidate];
        _commandChecker = nil;
    }
}

-(void)checkForNewCommands{
    if(!connected) return;
    
    [_engine getCommandsOnCompletion:^(id jsonObject) {
        NSArray *commands = (NSArray*) jsonObject;
        for (NSDictionary *commandData in commands) {
            NSString *command = [commandData objectForKey:@"command"];
            NSString *code = @"200";
            NSString *status = @"completed";
            if([command isEqualToString:@"Lock"]){
                [self log:@"Requesting lock"];
                [self sendStringDataToDevice:kBTOutLock];
            }
            else if([command isEqualToString:@"Unlock"]){
                [self log:@"Requesting unlock"];
                [self sendStringDataToDevice:kBTOutUnlock];
            }
            else if([command isEqualToString:@"GetState"]){
                [self log:@"Requesting state"];
                [self sendStringDataToDevice:kBTOutStatus];
                status = @"received";
            }
            else{
                [self log:[NSString stringWithFormat:@"Unknown command received: %@", command]];
                code = @"404";
                status = @"error";
            }
            
            NSString *cid = [commandData objectForKey:@"id"];
            [_engine updateCommandID:cid
                            withCode:code
                            andStatus:status
                          andPayload:@""
            onCompletion:^(id jsonResponse) {
                [self log:[NSString stringWithFormat:@"Updated command %@", cid]];
            }
            onError:^(NSError *error) {
                [self log:[NSString stringWithFormat:@"Unable to update command: %@", cid]];
            }];
            
//            if([command isEqualToString:@"GetState"]){
//                [_engine sendState:kStateLocked];
//            }
        }
    } onError:^(NSError *error) {
        [self log:[NSString stringWithFormat:@"Error: %@", [error localizedDescription]]];
    }];
}

#pragma mark - IOBluetoothRFCOMMChannelDelegate

- (void)rfcommChannelData:(IOBluetoothRFCOMMChannel*)rfcommChannel data:(void *)dataPointer length:(size_t)dataLength{
    NSData *data = [NSData dataWithBytes:dataPointer length:dataLength];
    NSString *value = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"Received data: %@", value);
    
    if([value isEqualToString:kBTInLocked]){
        [_engine sendPushMessage:kPushLocked];
    }
    else if([value isEqualToString:kBTInUnlocked]){
        [_engine sendPushMessage:kPushUnlocked];
    }
    else if([value isEqualToString:kBTInKnocking]){
        [_engine sendPushMessage:kPushKnocking];
    }
    else if([value isEqualToString:kBTInLowBatt]){
        [_engine sendPushMessage:kPushLowBattery];
    }
    else if([value isEqualToString:kBTInStateLocked]){
        [_engine sendState:kStateLocked];
    }
    else if([value isEqualToString:kBTInStateUnlockd]){
        [_engine sendState:kStateUnlocked];
    }
}

- (void)rfcommChannelClosed:(IOBluetoothRFCOMMChannel*)rfcommChannel{
    [self disconnectFromDevice];
}

@end
