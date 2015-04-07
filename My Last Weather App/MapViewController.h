//
//  MapViewController.h
//  My Last Weather App
//
//  Created by Akbar Nurlybayev on 2015-04-07.
//  Copyright (c) 2015 Akbar Nurlybayev. All rights reserved.
//

@import UIKit;
@import MapKit;
#import "CurrentWeather.h"

@interface MapViewController : UIViewController

@property (nonatomic, strong) CurrentWeather *weather;

@end
