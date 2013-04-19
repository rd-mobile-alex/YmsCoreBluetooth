//
// Copyright 2013 Yummy Melon Software LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
//  Author: Charles Y. Choi <charles.choi@yummymelon.com>
//


#import "DEASensorTagViewController.h"
#import "DEACBAppService.h"
#import "DEATemperatureViewCell.h"
#import "DEAAccelerometerViewCell.h"
#import "DEAHumidityViewCell.h"
#import "DEASimpleKeysViewCell.h"
#import "DEAGyroscopeViewCell.h"
#import "DEASensorTag.h"

@interface DEASensorTagViewController ()

@end

@implementation DEASensorTagViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _cbServiceCells = @[@"simplekeys"
                            , @"temperature"
                            , @"accelerometer"
                            , @"magnetometer"
                            , @"gyroscope"
                            , @"humidity"
                            , @"barometer"
                            ];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = self.sensorTag.cbPeripheral.name;
    
    self.rssiButton = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    
    UIBarButtonItem *flexSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];

    self.toolbarItems = @[flexSpace, self.rssiButton];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    
    if ([keyPath isEqualToString:@"RSSI"]) {
        self.rssiButton.title = [NSString stringWithFormat:@"%@ db", change[@"new"]];
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setSensorTableView:nil];
    [self setRssiButton:nil];
    
    for (NSString *prefix in self.cbServiceCells) {
        NSString *key = [[NSString alloc] initWithFormat:@"%@ViewCell", prefix];
        [self setValue:nil forKey:key];
    }

    [super viewDidUnload];
}


- (void)viewWillAppear:(BOOL)animated {
    
    DEACBAppService *cbAppService = [DEACBAppService sharedService];
    cbAppService.delegate = self;
    
    for (NSString *prefix in self.cbServiceCells) {
        NSString *key = [[NSString alloc] initWithFormat:@"%@ViewCell", prefix];
        UITableViewCell *cell = (UITableViewCell *)[self valueForKey:key];
        
        if ([cell respondsToSelector:@selector(configureWithSensorTag:)]) {
            [cell performSelector:@selector(configureWithSensorTag:) withObject:self.sensorTag];
        }
    }
    
    [self.sensorTag.cbPeripheral addObserver:self
                                  forKeyPath:@"RSSI"
                                     options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld)
                                     context:NULL];

}


- (void)viewWillDisappear:(BOOL)animated {
    
    [self.sensorTag.cbPeripheral removeObserver:self forKeyPath:@"RSSI"];
    
    for (NSString *prefix in self.cbServiceCells) {
        NSString *key = [[NSString alloc] initWithFormat:@"%@ViewCell", prefix];
        UITableViewCell *cell = (UITableViewCell *)[self valueForKey:key];
        if ([cell respondsToSelector:@selector(deconfigure)]) {
            [cell performSelector:@selector(deconfigure)];
        }
    }
}


#pragma mark - UITableViewDelegate & UITableViewDataSource Methods

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell;
    
    NSString *prefix = (NSString *)[self.cbServiceCells objectAtIndex:indexPath.section];
    NSString *key = [[NSString alloc] initWithFormat:@"%@ViewCell", prefix];
    cell = (UITableViewCell *)[self valueForKey:key];
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self.cbServiceCells count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSString *result;
    
    result = [self.cbServiceCells objectAtIndex:section];
    
    return result;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat result = 44.0;
    
    NSString *prefix = (NSString *)[self.cbServiceCells objectAtIndex:indexPath.section];
    NSString *key = [[NSString alloc] initWithFormat:@"%@ViewCell", prefix];
    UITableViewCell *cell = (UITableViewCell *)[self valueForKey:key];
    result = cell.bounds.size.height;
    
    return result;
}


#pragma mark - CBCentralManagerDelegate Methods

- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Disconnected"
                                                    message:@"This peripheral has been disconnected."
                                                   delegate:nil
                                          cancelButtonTitle:@"Dismiss"
                                          otherButtonTitles:nil];
    
    [alert show];
}





@end
