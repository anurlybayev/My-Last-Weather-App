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
NSString *const kIMG_URL = @"http://openweathermap.org/img/w/";
NSString *const kWEATHER_ENDPOINT = @"weather";
NSString *const kFORECAST_ENDPOINT = @"forecast/daily";

NSInteger const OpenWeatherMapInvalidInputCode = -1000;
NSString *const OpenWeatherMapErrorDomain = @"ca.akaiconsulting.MyLastWeatherApp.OpenWeatherMapAPI";

@interface OpenWeatherMapAPI ()

@property (strong, nonatomic) NSCache *imageCache;

@end

@implementation OpenWeatherMapAPI

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.imageCache = [[NSCache alloc] init];
    }
    return self;
}

- (void)startLoadingIndicator
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

- (void)stopLoadingIndicator
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

- (NSString *)URLEncodedQueryStringForParameters:(NSDictionary *)parameters
{
    NSMutableArray *queryParams = [NSMutableArray array];
    [parameters enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSString *value, BOOL *stop) {
        NSString *encodedKey = [key stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        id encodedValue = value;
        if ([value isKindOfClass:[NSString class]]) {
            encodedValue = [value stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        }
        [queryParams addObject:[NSString stringWithFormat:@"%@=%@", encodedKey, encodedValue]];
    }];
    return [queryParams componentsJoinedByString:@"&"];
}

- (void)currentWeatherWithParams:(NSDictionary *)params completion:(void(^)(id weather, NSError *error))completion
{
    NSURLSession *session = [NSURLSession sharedSession];
    NSString *urlString = [NSString stringWithFormat:@"%@%@?%@", kAPI_URL, kWEATHER_ENDPOINT, [self URLEncodedQueryStringForParameters:params]];
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    __weak __typeof__(self) wself = self;
    [wself startLoadingIndicator];
    NSURLSessionTask *task = [session dataTaskWithRequest:request
                                        completionHandler:
                              ^(NSData *data, NSURLResponse *response, NSError *error) {
                                  [wself stopLoadingIndicator];
                                  if (error) {
                                      dispatch_async(dispatch_get_main_queue(), ^{
                                          completion(nil, error);
                                      });
                                  } else {
                                      NSError *jsonError = nil;
                                      NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data
                                                                                           options:NSJSONReadingMutableContainers
                                                                                             error:&jsonError];
                                      if (jsonError) {
                                          dispatch_async(dispatch_get_main_queue(), ^{
                                              completion(nil, jsonError);
                                          });
                                      } else {
                                          NSInteger errorCode = [[json objectForKey:@"cod"] integerValue];
                                          if (errorCode != 200) {
                                              dispatch_async(dispatch_get_main_queue(), ^{
                                                  completion(nil, [NSError errorWithDomain:OpenWeatherMapErrorDomain
                                                                                      code:errorCode
                                                                                  userInfo:@{NSLocalizedDescriptionKey : [json objectForKey:@"message"]}]);
                                              });
                                          } else {
                                              dispatch_async(dispatch_get_main_queue(), ^{
                                                  completion(json, nil);
                                              });
                                          }
                                      }
                                  }
                                  
                              }];
    [task resume];
}

- (void)currentWeatherForCity:(NSString *)city completion:(void(^)(id weather, NSError *error))completion
{
    if (!city || [city length] == 0) {
        completion(nil, [NSError errorWithDomain:OpenWeatherMapErrorDomain
                                            code:OpenWeatherMapInvalidInputCode
                                        userInfo:@{NSLocalizedDescriptionKey : @"City name is required"}]);
        return;
    }
    NSDictionary *params = @{ @"APPID" : kAPI_KEY, @"q" : city, @"units" : @"metric" };
    [self currentWeatherWithParams:params completion:completion];
}

- (void)currentWeatherForCoordinate:(CLLocationCoordinate2D)coordinate completion:(void(^)(id weather, NSError *error))completion
{
    NSDictionary *params = @{
                             @"APPID" : kAPI_KEY,
                             @"lon" : [@(coordinate.longitude) description],
                             @"lat" : [@(coordinate.latitude) description],
                             @"units" : @"metric"
                             };
    [self currentWeatherWithParams:params completion:completion];
}

- (void)weatherForecastWithParams:(NSDictionary *)params completion:(void(^)(id forecast, NSError *error))completion
{
    NSURLSession *session = [NSURLSession sharedSession];
    NSString *urlString = [NSString stringWithFormat:@"%@%@?%@", kAPI_URL, kFORECAST_ENDPOINT, [self URLEncodedQueryStringForParameters:params]];
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    __weak __typeof__(self) wself = self;
    [wself startLoadingIndicator];
    NSURLSessionTask *task = [session dataTaskWithRequest:request
                                        completionHandler:
                              ^(NSData *data, NSURLResponse *response, NSError *error) {
                                  [wself stopLoadingIndicator];
                                  if (error) {
                                      dispatch_async(dispatch_get_main_queue(), ^{
                                          completion(nil, error);
                                      });
                                  } else {
                                      NSError *jsonError = nil;
                                      NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data
                                                                                           options:NSJSONReadingMutableContainers
                                                                                             error:&jsonError];
                                      if (jsonError) {
                                          dispatch_async(dispatch_get_main_queue(), ^{
                                              completion(nil, jsonError);
                                          });
                                      } else {
                                          NSInteger errorCode = [[json objectForKey:@"cod"] integerValue];
                                          if (errorCode != 200) {
                                              dispatch_async(dispatch_get_main_queue(), ^{
                                                  completion(nil, [NSError errorWithDomain:OpenWeatherMapErrorDomain
                                                                                      code:errorCode
                                                                                  userInfo:@{NSLocalizedDescriptionKey : [json objectForKey:@"message"]}]);
                                              });
                                          } else {
                                              dispatch_async(dispatch_get_main_queue(), ^{
                                                  completion(json, nil);
                                              });
                                          }
                                      }
                                  }
                                  
                              }];
    [task resume];
}

- (void)weatherForecastForCity:(NSString *)city completion:(void (^)(id, NSError *))completion
{
    if (!city || [city length] == 0) {
        completion(nil, [NSError errorWithDomain:OpenWeatherMapErrorDomain
                                            code:OpenWeatherMapInvalidInputCode
                                        userInfo:@{NSLocalizedDescriptionKey : @"City name is required"}]);
        return;
    }
    NSDictionary *params = @{ @"APPID" : kAPI_KEY, @"q" : city, @"units" : @"metric" };
    [self weatherForecastWithParams:params completion:completion];
}

- (void)weatherForecastForCoordinate:(CLLocationCoordinate2D)coordinate completion:(void (^)(id, NSError *))completion
{
    NSDictionary *params = @{
                             @"APPID" : kAPI_KEY,
                             @"lon" : [@(coordinate.longitude) description],
                             @"lat" : [@(coordinate.latitude) description],
                             @"units" : @"metric",
                             @"cnt" : @14
                             };
    [self weatherForecastWithParams:params completion:completion];
}

- (void)downloadIcon:(NSString *)iconName withCompletion:(void(^)(UIImage *icon))completion
{
    if (!iconName) {
        completion(nil);
        return;
    }
    UIImage *cachedIcon = [self.imageCache objectForKey:iconName];
    if (cachedIcon) {
        completion(cachedIcon);
    } else {
        __weak __typeof__(self) wself = self;
        [wself startLoadingIndicator];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSURL *iconURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@.png", kIMG_URL, iconName]];
            UIImage *icon = [UIImage imageWithData:[NSData dataWithContentsOfURL:iconURL]];
            dispatch_async(dispatch_get_main_queue(), ^{
                [wself stopLoadingIndicator];
                if (icon) {
                    [wself.imageCache setObject:icon forKey:iconName];
                    completion(icon);
                } else {
                    completion(nil);
                }
            });
        });
    }
}

@end
