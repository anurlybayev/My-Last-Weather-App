//
//  OpenWeatherMapAPI.h
//  My Last Weather App
//
//  Created by Akbar Nurlybayev on 2015-04-06.
//  Copyright (c) 2015 Akbar Nurlybayev. All rights reserved.
//

@import UIKit;

FOUNDATION_EXPORT NSInteger const OpenWeatherMapInvalidInputCode;
FOUNDATION_EXPORT NSString *const OpenWeatherMapErrorDomain;

@interface OpenWeatherMapAPI : NSObject

- (void)currentWeatherForCity:(NSString *)city completion:(void(^)(id weather, NSError *error))completion;
- (void)downloadIcon:(NSString *)iconName withCompletion:(void(^)(UIImage *icon))completion;

@end
