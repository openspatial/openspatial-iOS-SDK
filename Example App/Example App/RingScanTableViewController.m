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

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    return self;
}

- (void)viewDidLoad
{
    [self loadInitialData];
    [super viewDidLoad];
}

/*
 * Called to start the bluetooth scan and initialize the central manager
 */
- (void) loadInitialData
{
    self.myHIDServ = [OpenSpatialBluetooth sharedBluetoothServ];
    self.myHIDServ.delegate = self;
    [self.myHIDServ scanForPeripherals];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.myHIDServ.foundPeripherals count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"DeviceCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:
                             indexPath];
    CBPeripheral *rowElement = [self.myHIDServ.foundPeripherals objectAtIndex:indexPath.row];
    cell.textLabel.text = rowElement.name;
    return cell;
}

- (void)didFindNewDevice:(CBPeripheral*) peripheral
{
    [self.tableView reloadData];
}

/*
 * When a devices is chosen stop scanning and send the device data to the next screen and connect to
 * the device.
 */
- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    //find the selected device
    NSIndexPath *path = [self.tableView indexPathForSelectedRow];
    self.selectedIndex = path.row;
    printf("%d",self.selectedIndex);
    CBPeripheral *selected = (CBPeripheral*)[self.myHIDServ.foundPeripherals objectAtIndex:self.
                                             selectedIndex];
    
    
    //send selected device to destination screen and send the central manager for bluetooth
    //consistency
    
    MainViewController *dest = (MainViewController*)[segue destinationViewController];
    dest.HIDServ = self.myHIDServ;
    
    [self.myHIDServ connectToPeripheral:selected];
}

@end