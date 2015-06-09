//
//  NavController.h
//  RollingSpiderPiloting
//
//  Created by Neel on 6/8/15.
//  Copyright (c) 2015 Parrot. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PilotingViewController.h"
#import "RingScanTableViewController.h"

@interface NavController : UINavigationController

@property (strong, nonatomic) ARService *holdService;

@end
