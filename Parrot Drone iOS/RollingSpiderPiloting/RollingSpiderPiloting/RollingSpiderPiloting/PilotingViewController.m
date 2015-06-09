/*
    Copyright (C) 2014 Parrot SA

    Redistribution and use in source and binary forms, with or without
    modification, are permitted provided that the following conditions
    are met:
    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in
      the documentation and/or other materials provided with the 
      distribution.
    * Neither the name of Parrot nor the names
      of its contributors may be used to endorse or promote products
      derived from this software without specific prior written
      permission.

    THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
    "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
    LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
    FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
    COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
    INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
    BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS
    OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED 
    AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
    OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT
    OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
    SUCH DAMAGE.
*/
//
//  PilotingViewController.m
//  RollingSpiderPiloting
//
//  Created on 19/01/2015.
//  Copyright (c) 2015 Parrot. All rights reserved.
//

#import "PilotingViewController.h"
#import "DeviceController.h"
#import "ViewController.h"
#import "RingScanTableViewController.h"
#import "NavController.h"

@interface PilotingViewController () <DeviceControllerDelegate>
@property (nonatomic, strong) DeviceController* deviceController;
@property (nonatomic, strong) UIAlertView *alertView;
@end

@implementation PilotingViewController

@synthesize service = _service;
@synthesize batteryLabel = _batteryLabel;

- (void)viewDidLoad
{
    self.HIDServ = [OpenSpatialBluetooth sharedBluetoothServ];
    self.HIDServ.delegate = self;
    mFlying = false;
    
    [super viewDidLoad];
    NSLog(@"viewDidLoad ...");
    
    [_batteryLabel setText:@"?%"];
    
    _alertView = [[UIAlertView alloc] initWithTitle:[_service name] message:@"Connecting ..."
                                           delegate:self cancelButtonTitle:nil otherButtonTitles:nil, nil];
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    [_alertView show];
        mFlying = false;
    
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        _deviceController = [[DeviceController alloc]initWithARService:_service];
        [_deviceController setDelegate:self];
        BOOL connectError = [_deviceController start];
        
        connected = !connectError;
        
        if(connected) {
            self.statusLabel.text = @"Connected";
        } else {
            self.statusLabel.text = @"Disconnected";
        }
        
        NSLog(@"connectError = %d", connectError);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [_alertView dismissWithClickedButtonIndex:0 animated:TRUE];
            
        });
        
        if (connectError)
        {
//            dispatch_async(dispatch_get_main_queue(), ^{
                [self.navigationController popViewControllerAnimated:YES];
//            });

        }
        else
        {
            //only with RollingSpider in version 1.97 : date and time must be sent to permit a reconnection
            NSDate *currentDate = [NSDate date];
            [_deviceController sendDate:currentDate];
            [_deviceController sendTime:currentDate];
        }
    });
}

- (void) viewDidDisappear:(BOOL)animated
{
    _alertView = [[UIAlertView alloc] initWithTitle:[_service name] message:@"Disconnecting ..."
                                           delegate:self cancelButtonTitle:nil otherButtonTitles:nil, nil];
    [_alertView show];
    
    NSLog(@"CONNECTED BOOLEAN SET TO FALSE");
    connected = false;
    self.statusLabel.text = @"Disconnected";
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [_deviceController stop];
        [_alertView dismissWithClickedButtonIndex:0 animated:TRUE];
    });
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark events

- (IBAction)emergencyClick:(id)sender {
    [_deviceController sendEmergency];
}

- (IBAction)takeoffClick:(id)sender {
    [_deviceController sendTakeoff];
}

- (IBAction)landingClick:(id)sender {
    [_deviceController sendLanding];
}

//events for gaz:
- (IBAction)gazUpTouchDown:(id)sender {
    [_deviceController setGaz:50];
}
- (IBAction)gazDownTouchDown:(id)sender {
    [_deviceController setGaz:-50];
}

- (IBAction)gazUpTouchUp:(id)sender {
    [_deviceController setGaz:0];
}
- (IBAction)gazDownTouchUp:(id)sender {
    [_deviceController setGaz:0];
}

//events for yaw:
- (IBAction)yawLeftTouchDown:(id)sender {
    [_deviceController setYaw:-50];
}
- (IBAction)yawRightTouchDown:(id)sender {
    [_deviceController setYaw:50];
}

- (IBAction)yawLeftTouchUp:(id)sender {
    [_deviceController setYaw:0];
}

- (IBAction)yawRightTouchUp:(id)sender {
    [_deviceController setYaw:0];
}

//events for yaw:
- (IBAction)rollLeftTouchDown:(id)sender {
    [_deviceController setFlag:1];
    [_deviceController setRoll:-50];
}
- (IBAction)rollRightTouchDown:(id)sender {
    [_deviceController setFlag:1];
    [_deviceController setRoll:50];
}

- (IBAction)rollLeftTouchUp:(id)sender {
    [_deviceController setFlag:0];
    [_deviceController setRoll:0];
}
- (IBAction)rollRightTouchUp:(id)sender {
    [_deviceController setFlag:0];
    [_deviceController setRoll:0];
}

//events for pitch:
- (IBAction)pitchForwardTouchDown:(id)sender {
    [_deviceController setFlag:1];
    [_deviceController setPitch:50];
}
- (IBAction)pitchBackTouchDown:(id)sender {
    [_deviceController setFlag:1];
    [_deviceController setPitch:-50];
}

- (IBAction)pitchForwardTouchUp:(id)sender {
    [_deviceController setFlag:0];
    [_deviceController setPitch:0];
}
- (IBAction)pitchBackTouchUp:(id)sender {
    [_deviceController setFlag:0];
    [_deviceController setPitch:0];
}

#pragma mark DeviceControllerDelegate

- (void)onDisconnectNetwork:(DeviceController *)deviceController {
    NSLog(@"onDisconnect ...");
    
    connected = false;
    self.statusLabel.text = @"Disconnected";
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.navigationController popViewControllerAnimated:YES];
    });
}

- (void)onUpdateBattery:(DeviceController *)deviceController batteryLevel:(uint8_t)percent {
    NSLog(@"onUpdateBattery");
    
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString *text = [[NSString alloc] initWithFormat:@"%d%%", percent];
        [_batteryLabel setText:text];
    });
}

- (void) didConnectToNod: (CBPeripheral*) peripheral {
    NSLog(@"connected %@",peripheral);

    [self subscribeEvents];
}


- (void)subscribeEvents {
    for(NSString* name in [self.HIDServ.connectedPeripherals allKeys])
    {
        [self.HIDServ subscribeToPointerEvents:name];
        [self.HIDServ subscribeToButtonEvents:name];
    }
}


-(void)buttonEventFired: (ButtonEvent *) buttonEvent
{
//    NSLog(@"This is the value of button event type from %@", [buttonEvent.peripheral name]);
    switch([buttonEvent getButtonEventType])
    {
        case TOUCH0_DOWN:
            NSLog(@"Touch 0 Down");
            zeroPressed = true;
            break;
        case TOUCH0_UP:
            NSLog(@"Touch 0 Up");
            zeroPressed = false;
            break;
        case TOUCH1_DOWN:
            NSLog(@"Touch 1 Down");
            onePressed = true;
            break;
        case TOUCH1_UP:
            NSLog(@"Touch 1 Up");
            onePressed = false;
            break;
        case TOUCH2_DOWN:
            NSLog(@"Touch 2 Down");
            twoPressed = true;
            break;
        case TOUCH2_UP:
            NSLog(@"Touch 2 Up");
            twoPressed = false;
            break;
        case TACTILE0_DOWN:
            NSLog(@"Tactile 0 Down");
            break;
        case TACTILE0_UP:
            NSLog(@"Tactile 0 Up");
            break;
        case TACTILE1_DOWN:
            NSLog(@"Tactile 1 Down");
            break;
        case TACTILE1_UP:
            NSLog(@"Tactile 1 Up");
            break;
    }
    
    if([buttonEvent getButtonEventType] == TACTILE0_DOWN || [buttonEvent getButtonEventType] == TACTILE1_DOWN) {
        if(mFlying) {
            [self landingClick:nil];
            mFlying = false;
        } else {
            [self takeoffClick:nil];
            mFlying = true;
        }
    }
}

- (void) clip_accums {
    if (accum_x > 3000) {
        accum_x = 3000;
    }
    if (accum_x < -3000) {
        accum_x = -3000;
    }
    if (accum_y > 3000) {
        accum_y = 3000;
    }
    if (accum_y < -3000) {
        accum_y = -3000;
    }
}

- (void) clip_accums2 {
    if (accum_2x > 3000) {
        accum_2x = 3000;
    }
    if (accum_2x < -3000) {
        accum_2x = -3000;
    }
    if (accum_2y > 3000) {
        accum_2y = 3000;
    }
    if (accum_2y < -3000) {
        accum_2y = -3000;
    }
}

-(void)pointerEventFired: (PointerEvent *) pointerEvent {
//        NSLog(@"This is the x value of the pointer event from %@", [pointerEvent.peripheral name]);
//        NSLog(@"%hd", [pointerEvent getXValue]);
//    
//        NSLog(@"This is the y value of the pointer event from %@", [pointerEvent.peripheral name]);
//        NSLog(@"%hd", [pointerEvent getYValue]);
    
    bool noRoll = false;
    bool noPitch = false;
    
//    if(!mFlying) {
//        return;
//    }
    
    if(onePressed || zeroPressed) {
        accum_x += pointerEvent.xVal;
        accum_y += pointerEvent.yVal;
        [self clip_accums];
        
//        NSLog(@"Accum-x:  %d", accum_x);
//        NSLog(@"Accum-y:  %d", accum_y);
        
        if(connected) {
            
            if ((accum_x) > 1000) {
                [_deviceController setFlag:1];
                
                NSLog(@"X: %f", (25+(accum_x-1000)*0.0125) );
                [_deviceController setRoll:(int8_t)(25+(accum_x-1000)*0.0125)];
            }else if ((accum_x) < -1000){
                [_deviceController setFlag:1];
                NSLog(@"Accumx: %d", accum_x);
                NSLog(@"X: %f", (-25+(accum_x+1000)*0.0125) );
                [_deviceController setRoll:(int8_t)(-25+(accum_x+1000)*0.0125)];
            }else{
//                noRoll = true;
//                [_deviceController setFlag:0];
//                [_deviceController setRoll:(int8_t)0];
            }
            
            
            // Order matters of pitch and roll from before. But for new logic, it does not matter
            if ((accum_y) > 1000) {
                [_deviceController setFlag:1];
                
                NSLog(@"Y: %f", (25+(accum_y-1000)*0.0125));
//                NSLog(@"Move forwards");
                [_deviceController setPitch:(int8_t)(25+(accum_y-1000)*0.0125)];
                
            }else if ((accum_y) < -1000){
                [_deviceController setFlag:1];
                
                NSLog(@"Y: %f", (-25+(accum_y+1000)*0.0125));
//                NSLog(@"Move backwards");
                [_deviceController setPitch:(int8_t)(-25+(accum_y+1000)*0.0125)];

            }else{
//                noPitch = true;
//                [_deviceController setFlag:0];
//                [_deviceController setPitch:(int8_t)0];
            }
            
//            if(noRoll && noPitch) {
//                [_deviceController setFlag:0];
//                [_deviceController setRoll:(int8_t)0];
//                [_deviceController setPitch:(int8_t)0];
//            } else if(noRoll) {
//                [_deviceController setFlag:0];
//                [_deviceController setRoll:(int8_t)0];
//            } else if(noPitch) {
//                [_deviceController setFlag:0];
//                [_deviceController setPitch:(int8_t)0];
//            }
            
        }
    }
    else {
        accum_x = 0;
        accum_y = 0;
        [_deviceController setFlag:0];
        [_deviceController setPitch:(int8_t)0];
        [_deviceController setRoll:(int8_t)0];
    }
    
    if(twoPressed) {
        accum_2x += pointerEvent.xVal;
        accum_2y += pointerEvent.yVal;
        [self clip_accums2];
        
        if(connected) {
            if ((accum_2y) > 1000) {
                [_deviceController setGaz: (int8_t)(40+(accum_2y-1000)*0.02)];
            }else if ((accum_2y) < -1000){
                [_deviceController setGaz:(int8_t)(-40+(accum_2y-1000)*0.02)];
            }else{
                [_deviceController setGaz:0];
            }
            
            if ((accum_2x) > 1000) {
                [_deviceController setYaw:(int8_t)(25+(accum_2x - 1000) * 0.0125)];
            } else if ((accum_2x) < -1000){
                [_deviceController setYaw:(int8_t)(-25+(accum_2x - 1000) * 0.0125)];
            }else{
                [_deviceController setYaw:0];
            }
        }

    } else {
        accum_2x = 0;
        accum_2y = 0;
        [_deviceController setYaw:(int8_t)0];
        [_deviceController setGaz:(int8_t)0];
    }
}

- (int)signi:(int)i {
    if (i == 0){
        return 0;
    }
    if (i >> 31 != 0) {
        return -1;
    }
    return +1;
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
        NavController *dest = (NavController *)[segue destinationViewController];
        dest.holdService = self.service;
}


@end
