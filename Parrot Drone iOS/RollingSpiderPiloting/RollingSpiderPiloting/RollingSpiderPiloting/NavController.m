//
//  NavController.m
//  RollingSpiderPiloting
//
//  Created by Neel on 6/8/15.
//  Copyright (c) 2015 Parrot. All rights reserved.
//

#import "NavController.h"

@interface NavController ()

@end

@implementation NavController

@synthesize holdService = _holdService;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    RingScanTableViewController *dest = (RingScanTableViewController*)[segue destinationViewController];

    dest.holdService = self.holdService;

}

@end
