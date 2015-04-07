//
//  CurrentWeather.m
//  My Last Weather App
//
//  Created by Akbar Nurlybayev on 2015-04-07.
//  Copyright (c) 2015 Akbar Nurlybayev. All rights reserved.
//

#import "CurrentWeather.h"

@implementation CurrentWeather

+ (instancetype)currentWeatherFromJSON:(NSDictionary *)json
{
    if ([[json objectForKey:@"cod"] integerValue] != 200) {
        return nil;
    }
    CurrentWeather *weather = [[CurrentWeather alloc] init];
    weather.city = [json objectForKey:@"name"];
    weather.country = [json valueForKeyPath:@"sys.country"];
    NSDictionary *currentCondition = [[json objectForKey:@"weather"] lastObject];
    weather.weatherDescription = [[currentCondition objectForKey:@"description"] capitalizedString];
    weather.weatherIconName = [currentCondition objectForKey:@"icon"];
    weather.temperature = [json valueForKeyPath:@"main.temp"];
    weather.humidity = [json valueForKeyPath:@"main.humidity"];
    weather.windSpeed = [json valueForKeyPath:@"wind.speed"];
    weather.location = [[CLLocation alloc] initWithLatitude:[[json valueForKeyPath:@"coord.lat"] doubleValue]
                                                  longitude:[[json valueForKeyPath:@"coord.lon"] doubleValue]];
    
    return weather;
}

- (NSString *)locationDescription
{
    return [NSString stringWithFormat:@"%@, %@", self.city, self.country];
}

- (NSString *)humidityDescription
{
    return [NSString stringWithFormat:@"Humidity: %@%%", self.humidity];
}

- (NSString *)windSpeedDescription
{
    NSNumber *windSpeed = @([self.windSpeed floatValue] * 3.6);
   return [NSString stringWithFormat:@"Wind: %@ km/h", [self.numberFormatter stringFromNumber:windSpeed]];
}

- (NSNumber *)temperature
{
    if (self.isFahrenheit) {
        NSNumber *kTemp = @(1.8 * [_temperature floatValue] + 32);
        return kTemp;
    } else {
        return _temperature;
    }
}

- (NSNumberFormatter *)numberFormatter
{
    if (!_numberFormatter) {
        _numberFormatter = [[NSNumberFormatter alloc] init];
        _numberFormatter.maximumFractionDigits = 1;
    }
    return _numberFormatter;
}


#pragma mark - MKAnnotation

- (CLLocationCoordinate2D)coordinate
{
    return self.location.coordinate;
}

- (NSString *)title
{
    if (self.isFahrenheit) {
        return [NSString stringWithFormat:@"%@ ℉", [self.numberFormatter stringFromNumber:self.temperature]];        
    } else {
        return [NSString stringWithFormat:@"%@ ℃", [self.numberFormatter stringFromNumber:self.temperature]];
    }
}

- (NSString *)subtitle
{
    return self.weatherDescription;
}

@end
