//
//  ForecastViewController.h
//  My Last Weather App
//
//  Created by Akbar Nurlybayev on 2015-04-06.
//  Copyright (c) 2015 Akbar Nurlybayev. All rights reserved.
//

@import UIKit;
@import CoreLocation;

@interface ForecastViewController : UITableViewController

@property(nonatomic, strong) CLLocation *location;

@end
