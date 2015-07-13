//
//  RingScanTableViewController.m
//  Example App
//
//  Created by Neel Bhoopalam on 6/9/14.
//  Copyright (c) 2014 Nod Labs. All rights reserved.
//

#import "RingScanTableViewController.h"

@interface RingScanTableViewController ()

@property int selectedIndex;

@property OpenSpatialBluetooth *myHIDServ;

@end

@implementation RingScanTableViewController

- (id)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    self.rings = [[NSMutableArray alloc] init];
    return self;
}

- (void)viewDidLoad {
    [self loadInitialData];
    [super viewDidLoad];
}

/*
 * Called to start the bluetooth scan and initialize the central manager
 */
- (void) loadInitialData {
    self.myHIDServ = [OpenSpatialBluetooth sharedBluetoothServ];
    self.myHIDServ.delegate = self;
    [self.myHIDServ scanForPeripherals];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section
    if(section == 0) {
        return self.myHIDServ.foundPeripherals.count;
    }
    if(section == 1) {
        return self.myHIDServ.pairedPeripherals.count;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"DeviceCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:
                             indexPath];
    CBPeripheral* rowElement;
    if(indexPath.section == 0) {
        rowElement = [self.myHIDServ.foundPeripherals objectAtIndex:indexPath.row];
    }
    if(indexPath.section == 1) {
        rowElement = [self.myHIDServ.pairedPeripherals objectAtIndex:indexPath.row];
    }
    cell.textLabel.text = rowElement.name;
    return cell;
}

- (void)didFindNewPairedDevice:(NSArray *)peripherals {
    [self.tableView reloadData];
}

-(void)didFindNewScannedDevice:(NSArray *)peripherals {
    [self.tableView reloadData];
}

- (IBAction)cancelSelection:(id)sender {
    [self dismissViewControllerAnimated:true completion:nil];
}

/*
 * When a devices is chosen stop scanning and send the device data to the next screen and connect to
 * the device.
 */
- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    //find the selected device
    NSIndexPath *path = [self.tableView indexPathForSelectedRow];
    self.selectedIndex = path.row;
    printf("%d",self.selectedIndex);
    CBPeripheral *selected;
    if(path.section == 0) {
        selected = (CBPeripheral*)[self.myHIDServ.foundPeripherals objectAtIndex:self.
                                             selectedIndex];
    }
    if(path.section == 1) {
        selected = (CBPeripheral*)[self.myHIDServ.pairedPeripherals objectAtIndex:self.
                                   selectedIndex];
    }
    
    //send selected device to destination screen and send the central manager for bluetooth
    //consistency
    
    MainViewController *dest = (MainViewController*)[segue destinationViewController];
    dest.HIDServ = self.myHIDServ;
    
    [self.myHIDServ connectToPeripheral:selected];
}

@end