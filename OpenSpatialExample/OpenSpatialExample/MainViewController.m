//
//  MainViewController.m
//  Example App
//
//  Copyright (c) 2015 Nod Labs. All rights reserved.
//

#import "MainViewController.h"

@interface MainViewController ()

@end

@implementation MainViewController

- (void)viewDidLoad {
    self.HIDServ = [OpenSpatialBluetooth sharedBluetoothServ];
    self.HIDServ.delegate = self;
    [self.HIDServ connectToNodDevices];
    self.logTextView.editable = false;
    self.peripherals = [[NSMutableArray alloc] init];
    [super viewDidLoad];
    
    self.nodDevicePicker.enabled = (self.peripherals.count > 0) ? true : false;
    self.dataTypePicker.enabled = NO;
    self.dataSwitch.enabled = NO;
    [self.dataSwitch addTarget:self action:@selector(stateChanged:) forControlEvents:UIControlEventValueChanged];
    
    NSArray* allDataTypes = @[ODACCELEROMETER, ODGYRO, ODCOMPASS, ODEULER, ODTRANSLATION, ODANALOG, ODRELATIVEXY, ODGESTURE, ODBUTTON, ODSLIDER];
    
    self.dataTypesBackspin = [NSMutableArray arrayWithArray:allDataTypes];
    [self.dataTypesBackspin removeObject:ODSLIDER];
    [self.dataTypesBackspin removeObject:ODRELATIVEXY];
    
    self.dataTypesRing = [NSMutableArray arrayWithArray:allDataTypes];
    [self.dataTypesRing removeObject:ODANALOG];
    
    self.tagsDict = [[NSMutableDictionary alloc] initWithObjects:@[@(OS_RAW_ACCELEROMETER_TAG), @(OS_RAW_GYRO_TAG), @(OS_RAW_COMPASS_TAG), @(OS_EULER_ANGLES_TAG), @(OS_TRANSLATIONS_TAG), @(OS_ANALOG_DATA_TAG), @(OS_RELATIVE_XY_TAG), @(OS_DIRECTION_GESTURE_TAG), @(OS_BUTTON_EVENT_TAG), @(OS_SLIDER_GESTURE_TAG)] forKeys:allDataTypes];
}

- (void) didConnectToNod: (CBPeripheral*) peripheral {
    [self consoleLogAndTextView:[NSString stringWithFormat:@"%@ - Connected", peripheral.name]];
    [self.peripherals addObject:peripheral.name];
    self.nodDevicePicker.enabled = TRUE;
    self.dataSwitch.enabled = YES;
}

-(void)didDisconnectFromNod:(NSString *)peripheral {
    [self consoleLogAndTextView:[NSString stringWithFormat:@"%@ - Disconnected", peripheral]];
    [self.peripherals removeObject:peripheral];
    if(self.peripherals.count == 0) {
        self.nodDevicePicker.enabled = FALSE;
        self.dataSwitch.enabled = NO;
    }
}

-(void)consoleLogAndTextView:(NSString *)input {
    NSLog(@"%@", input);
    [self appendTextViewString:input];
}

-(void)openSpatialDataFired:(OpenSpatialData *)openSpatialData {
    switch (openSpatialData.dataType) {
        case OS_BUTTON_EVENT_TAG: {
            ButtonData* buttonData = (ButtonData *) openSpatialData;
            if(buttonData.buttonState == UP) {
                [self consoleLogAndTextView:[NSString stringWithFormat:@"%@ - %d - Button Up", openSpatialData.peripheral.name, buttonData.buttonID]];
            }
            if(buttonData.buttonState == DOWN) {
                [self consoleLogAndTextView:[NSString stringWithFormat:@"%@ - %d - Button Down", openSpatialData.peripheral.name, buttonData.buttonID]];
            }
            break;
        }
        case OS_RELATIVE_XY_TAG: {
            RelativeXYData* relativeXYData = (RelativeXYData *) openSpatialData;
            [self consoleLogAndTextView:[NSString stringWithFormat:@"%@ - RelativeXY:[%d,%d]" , openSpatialData.peripheral.name, relativeXYData.x, relativeXYData.y]];
            break;
        }
        case OS_EULER_ANGLES_TAG: {
            EulerData* eulerData = (EulerData *) openSpatialData;
            [self consoleLogAndTextView:[NSString stringWithFormat:@"%@ - Euler:[%f, %f, %f]" , openSpatialData.peripheral.name, eulerData.roll, eulerData.pitch, eulerData.yaw]];
            break;
        }
        case OS_RAW_ACCELEROMETER_TAG: {
            AccelerometerData* accelData = (AccelerometerData *) openSpatialData;
            [self consoleLogAndTextView:[NSString stringWithFormat:@"%@ - Accel:[%f, %f, %f]" , openSpatialData.peripheral.name, accelData.x, accelData.y, accelData.z]];
            break;
        }
        case OS_RAW_GYRO_TAG: {
            GyroscopeData* gyroData = (GyroscopeData *) openSpatialData;
            [self consoleLogAndTextView:[NSString stringWithFormat:@"%@ - Gyro:[%f, %f, %f]" , openSpatialData.peripheral.name, gyroData.x, gyroData.y, gyroData.z]];
            break;
        }
        case OS_RAW_COMPASS_TAG: {
            CompassData* compassData = (CompassData *) openSpatialData;
            [self consoleLogAndTextView:[NSString stringWithFormat:@"%@ - Compass:[%d, %d, %d]" , openSpatialData.peripheral.name, compassData.x, compassData.y, compassData.z]];
            break;
        }
        case OS_TRANSLATIONS_TAG: {
            TranslationData* translationData = (TranslationData *) openSpatialData;
            [self consoleLogAndTextView:[NSString stringWithFormat:@"%@ - Translation:[%f, %f, %f]" , openSpatialData.peripheral.name, translationData.x, translationData.y, translationData.z]];
            break;
        }
        case OS_DIRECTION_GESTURE_TAG: {
            GestureData* gestureData = (GestureData *) openSpatialData;
            switch (gestureData.gestureType) {
                case GESTURE_RIGHT: {
                    [self consoleLogAndTextView:[NSString stringWithFormat:@"%@ - Gesture Right", openSpatialData.peripheral.name]];
                    break;
                }
                case GESTURE_LEFT: {
                    [self consoleLogAndTextView:[NSString stringWithFormat:@"%@ - Gesture Left", openSpatialData.peripheral.name]];
                    break;
                }
                case GESTURE_DOWN: {
                    [self consoleLogAndTextView:[NSString stringWithFormat:@"%@ - Gesture Down", openSpatialData.peripheral.name]];
                    break;
                }
                case GESTURE_UP: {
                    [self consoleLogAndTextView:[NSString stringWithFormat:@"%@ - Gesture Up", openSpatialData.peripheral.name]];
                    break;
                }
                case GESTURE_CLOCKWISE: {
                    [self consoleLogAndTextView:[NSString stringWithFormat:@"%@ - Gesture Clockwise", openSpatialData.peripheral.name]];
                    break;
                }
                case GESTURE_COUNTERCLOCKWISE: {
                    [self consoleLogAndTextView:[NSString stringWithFormat:@"%@ - Gesture Counterclockwise", openSpatialData.peripheral.name]];
                    break;
                }
            }
            break;
        }
        case OS_SLIDER_GESTURE_TAG: {
            SliderData* sliderData = (SliderData *) openSpatialData;
            switch (sliderData.sliderType) {
                case SLIDE_DOWN: {
                    [self consoleLogAndTextView:[NSString stringWithFormat:@"%@ - Slide Down", openSpatialData.peripheral.name]];
                    break;
                }
                case SLIDE_UP: {
                    [self consoleLogAndTextView:[NSString stringWithFormat:@"%@ - Slide Up", openSpatialData.peripheral.name]];
                    break;
                }
            }
            break;
        }
        case OS_ANALOG_DATA_TAG: {
            AnalogData* analogData = (AnalogData *) openSpatialData;
            [self consoleLogAndTextView:[NSString stringWithFormat:@"%@ - Analog:[%d, %d, %d]", openSpatialData.peripheral.name, analogData.x, analogData.y, analogData.trigger]];
            break;
        }
    }
}

- (void)appendTextViewString:(NSString *)input {
        NSString *passedIn = [NSString stringWithFormat:@"%@\n", input];
        NSString *newText = [self.logTextView.text stringByAppendingString:passedIn];
        self.logTextView.text = newText;
        lineCount++;
        if(lineCount > 75) {
            [self.logTextView setSelectedRange:NSMakeRange(0, self.logTextView.text.length/2)];
            [self.logTextView setText:@""];
            lineCount = 0;
        }
    
        [self.logTextView scrollRangeToVisible:NSMakeRange(newText.length, 0)];
}

- (IBAction)selectNodDevice:(UIControl *)sender {
    [ActionSheetStringPicker showPickerWithTitle:@"Select Nod Device" rows:self.peripherals initialSelection:self.selectedIndexDevice target:self successAction:@selector(nodDeviceWasSelected:element:) cancelAction:@selector(actionPickerCancelled:) origin:sender];
}

- (IBAction)selectDataType:(UIControl *)sender {
    if(self.backspinData) {
        [ActionSheetStringPicker showPickerWithTitle:@"Select Data Type" rows:self.dataTypesBackspin initialSelection:self.selectedIndexDataType target:self successAction:@selector(dataTypeWasSelected:element:) cancelAction:@selector(actionPickerCancelled:) origin:sender];
    } else {
        [ActionSheetStringPicker showPickerWithTitle:@"Select Data Type" rows:self.dataTypesRing initialSelection:self.selectedIndexDataType target:self successAction:@selector(dataTypeWasSelected:element:) cancelAction:@selector(actionPickerCancelled:) origin:sender];
    }
}

- (void)nodDeviceWasSelected:(NSNumber *)selectedIndex element:(id)element {
    self.selectedIndexDevice = [selectedIndex intValue];
    self.nodDevicePicker.text = (self.peripherals)[(NSUInteger) self.selectedIndexDevice];
    self.backspinData = [[self.nodDevicePicker.text substringToIndex:4] isEqualToString:@"nod2"] ? true : false;
    self.dataTypePicker.enabled = TRUE;
    [self updateSwitchStatus];
}

- (void)dataTypeWasSelected:(NSNumber *)selectedIndex element:(id)element {
    self.selectedIndexDataType = [selectedIndex intValue];
    self.dataTypePicker.text = self.backspinData ? (self.dataTypesBackspin)[(NSUInteger) self.selectedIndexDataType] : (self.dataTypesRing)[(NSUInteger) self.selectedIndexDataType];
    [self updateSwitchStatus];
}

-(void)stateChanged:(UISwitch *)switchState {
    NSArray* dataArray = [[NSArray alloc] initWithObjects:[self.tagsDict objectForKey:self.dataTypePicker.text], nil];
    if(self.dataSwitch.on) {
        [self.HIDServ subscribeToEvents:self.nodDevicePicker.text forEventTypes:dataArray];
        for(int i=0; i < dataArray.count; i++) {
            NSLog(@"Array: %@", dataArray[i]);
        }
    } else {
        [self.HIDServ unsubscribeFromEvents:self.nodDevicePicker.text forEventTypes:dataArray];
    }
}

-(void)updateSwitchStatus {
    NodDevice* dev = [self.HIDServ.connectedPeripherals objectForKey:self.nodDevicePicker.text];
    BOOL switchStatus = [[dev.subscribedTo objectForKey:self.dataTypePicker.text] boolValue];
    [self.dataSwitch setOn:switchStatus animated:YES];
}

- (void)actionPickerCancelled:(id)sender {
    NSLog(@"Delegate has been informed that ActionSheetPicker was cancelled");
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    return NO;
}
- (IBAction)clearLogs:(id)sender {
    [self.logTextView setText:@""];
}
@end