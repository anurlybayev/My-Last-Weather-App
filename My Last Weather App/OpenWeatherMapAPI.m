//
//  OpenWeatherMapAPI.m
//  My Last Weather App
//
//  Created by Akbar Nurlybayev on 2015-04-06.
//  Copyright (c) 2015 Akbar Nurlybayev. All rights reserved.
//

#import "OpenWeatherMapAPI.h"

NSString *const kAPI_KEY = @"979dbed9d1bc20baf5c3a646ab8b2fc8";
NSString *const kAPI_URL = @"http://api.openweathermap.org/data/2.5/";
NSString *const kWEATHER_ENDPOINT = @"weather";

NSInteger const OpenWeatherMapInvalidInputCode = -1000;
NSString *const OpenWeatherMapErrorDomain = @"ca.akaiconsulting.MyLastWeatherApp.OpenWeatherMapAPI";

@implementation OpenWeatherMapAPI

- (instancetype)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (NSString *)URLEncodedQueryStringForParameters:(NSDictionary *)parameters
{
    NSMutableArray *queryParams = [NSMutableArray array];
    [parameters enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSString *value, BOOL *stop) {
        NSString *encodedKey = [key stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSString *encodedValue = [value stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        [queryParams addObject:[NSString stringWithFormat:@"%@=%@", encodedKey, encodedValue]];
    }];
    return [queryParams componentsJoinedByString:@"&"];
}

- (void)currentWeatherForCity:(NSString *)city completion:(void(^)(id weather, NSError *error))completion
{
    if (!city || [city length] == 0) {
        completion(nil, [NSError errorWithDomain:OpenWeatherMapErrorDomain
                                            code:OpenWeatherMapInvalidInputCode
                                        userInfo:@{NSLocalizedDescriptionKey : @"City name is required"}]);
        return;
    }
    NSURLSession *session = [NSURLSession sharedSession];
    NSDictionary *params = @{ @"APPID" : kAPI_KEY, @"q" : city };
    NSString *urlString = [NSString stringWithFormat:@"%@%@?%@", kAPI_URL, kWEATHER_ENDPOINT, [self URLEncodedQueryStringForParameters:params]];
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    NSURLSessionTask *task = [session dataTaskWithRequest:request
                                        completionHandler:
                              ^(NSData *data, NSURLResponse *response, NSError *error) {
                                  if (error) {
                                      completion(nil, error);
                                  } else {
                                      NSError *jsonError = nil;
                                      NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data
                                                                                           options:NSJSONReadingMutableContainers
                                                                                             error:&jsonError];
                                      if (jsonError) {
                                          completion(nil, jsonError);
                                      } else {
                                          completion(json, nil);
                                      }
                                  }
                                  
    }];
    [task resume];
}

@end
