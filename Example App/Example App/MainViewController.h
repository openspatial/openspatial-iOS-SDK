//
//  MainViewController.h
//  Example App
//
//  Created by Neel Bhoopalam on 6/9/14.
//  Copyright (c) 2014 Nod Labs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <OpenSpatial/OpenSpatialBluetooth.h>

@interface MainViewController : UIViewController <OpenSpatialBluetoothDelegate>
{
    NSTimer *stopTimer;
    NSDate *startDate;
    BOOL running;
}

@property (weak, nonatomic) IBOutlet UILabel *xPointerlbl;
@property (weak, nonatomic) IBOutlet UILabel *yPointerlbl;

@property (weak, nonatomic) IBOutlet UILabel *xPose6Dlbl;
@property (weak, nonatomic) IBOutlet UILabel *yPose6Dlbl;
@property (weak, nonatomic) IBOutlet UILabel *zPose6Dlbl;
@property (weak, nonatomic) IBOutlet UILabel *rollPose6Dlbl;
@property (weak, nonatomic) IBOutlet UILabel *pitchPose6Dlbl;
@property (weak, nonatomic) IBOutlet UILabel *yawPose6Dlbl;


@property (weak, nonatomic) IBOutlet UILabel *time;

- (void)updateTimer;


@property OpenSpatialBluetooth *HIDServ;
@property CBPeripheral *lastNodPeripheral;
@property (weak, nonatomic) IBOutlet UILabel *connectedTimeStamp;
@property (weak, nonatomic) IBOutlet UILabel *disconnectedTimeStamp;
@property (weak, nonatomic) IBOutlet UILabel *xPointerValue;
@property (weak, nonatomic) IBOutlet UILabel *yPointerValue;
@property (weak, nonatomic) IBOutlet UILabel *batteryPercentage;



@property (weak, nonatomic) IBOutlet UILabel *buttonValue;
@property (weak, nonatomic) IBOutlet UILabel *gestureValue;


@property (weak, nonatomic) IBOutlet UILabel *pose6DxValue;
@property (weak, nonatomic) IBOutlet UILabel *pose6DyValue;
@property (weak, nonatomic) IBOutlet UILabel *pose6DzValue;

@property (weak, nonatomic) IBOutlet UILabel *pose6DrollValue;
@property (weak, nonatomic) IBOutlet UILabel *pose6DpitchValue;
@property (weak, nonatomic) IBOutlet UILabel *pose6DyawValue;

@end
