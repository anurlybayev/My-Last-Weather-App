//
//  CurrentWeather.h
//  My Last Weather App
//
//  Created by Akbar Nurlybayev on 2015-04-07.
//  Copyright (c) 2015 Akbar Nurlybayev. All rights reserved.
//

@import UIKit;
@import MapKit;

@interface CurrentWeather : NSObject <MKAnnotation>

@property (strong, nonatomic) NSString *city;
@property (strong, nonatomic) NSString *country;
@property (strong, nonatomic) NSString *weatherDescription;
@property (strong, nonatomic) NSString *weatherIconName;
@property (strong, nonatomic) UIImage  *weatherIcon;
@property (strong, nonatomic) NSNumber *temperature;
@property (strong, nonatomic) NSNumber *humidity;
@property (strong, nonatomic) NSNumber *windSpeed;
@property (strong, nonatomic) CLLocation *location;

@property (strong, nonatomic) NSNumberFormatter *numberFormatter;
@property (nonatomic) BOOL isFahrenheit;

+ (instancetype)currentWeatherFromJSON:(NSDictionary *)json;

- (NSString *)locationDescription;
- (NSString *)humidityDescription;
- (NSString *)windSpeedDescription;

@end
