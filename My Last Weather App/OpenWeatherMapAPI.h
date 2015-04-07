//
//  OpenWeatherMapAPI.h
//  My Last Weather App
//
//  Created by Akbar Nurlybayev on 2015-04-06.
//  Copyright (c) 2015 Akbar Nurlybayev. All rights reserved.
//
@import CoreLocation;
@import UIKit;
#import "CurrentWeather.h"

FOUNDATION_EXPORT NSInteger const OpenWeatherMapInvalidInputCode;
FOUNDATION_EXPORT NSString *const OpenWeatherMapErrorDomain;

@interface OpenWeatherMapAPI : NSObject

- (void)currentWeatherForCity:(NSString *)city
                   completion:(void(^)(CurrentWeather *weather, NSError *error))completion;
- (void)currentWeatherForCoordinate:(CLLocationCoordinate2D)coordinate
                         completion:(void(^)(CurrentWeather *weather, NSError *error))completion;
- (void)weatherForecastForCity:(NSString *)city completion:(void(^)(id forecast, NSError *error))completion;
- (void)weatherForecastForCoordinate:(CLLocationCoordinate2D)coordinate completion:(void(^)(id forecast, NSError *error))completion;
- (void)downloadIcon:(NSString *)iconName withCompletion:(void(^)(UIImage *icon))completion;

@end
