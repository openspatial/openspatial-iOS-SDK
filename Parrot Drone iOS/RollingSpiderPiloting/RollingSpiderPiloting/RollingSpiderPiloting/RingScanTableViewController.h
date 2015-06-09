//
//  RingScanTableViewController.h
//  Example App
//
//  Created by Neel Bhoopalam on 6/9/14.
//  Copyright (c) 2014 Nod Labs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OpenSpatialBluetooth.h"
#import "PilotingViewController.h"

@interface RingScanTableViewController : UITableViewController <OpenSpatialBluetoothDelegate>

@property NSMutableArray* rings;

- (IBAction)cancelNodRingSelection:(id)sender;

@property (strong, nonatomic) ARService *holdService;

@end