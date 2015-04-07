//
//  ViewController.m
//  My Last Weather App
//
//  Created by Akbar Nurlybayev on 2015-04-06.
//  Copyright (c) 2015 Akbar Nurlybayev. All rights reserved.
//

@import CoreLocation;

#import "MainViewController.h"
#import "OpenWeatherMapAPI.h"
#import "ForecastViewController.h"

@interface MainViewController () <UITextFieldDelegate, CLLocationManagerDelegate>

@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *locationLabel;
@property (weak, nonatomic) IBOutlet UILabel *currentConditionLabel;
@property (weak, nonatomic) IBOutlet UIImageView *currentConditionIcon;
@property (weak, nonatomic) IBOutlet UILabel *currentTemperatureLabel;
@property (weak, nonatomic) IBOutlet UISegmentedControl *temperatureSegment;
@property (weak, nonatomic) IBOutlet UILabel *humidityLabel;
@property (weak, nonatomic) IBOutlet UILabel *windLabel;
@property (weak, nonatomic) IBOutlet UITextField *inputField;

@property (strong, nonatomic) NSNumber *temp;
@property (strong, nonatomic) CLLocation *location;

@property (strong, nonatomic) NSTimer *timer;
@property (strong, nonatomic) NSDateFormatter *dateTimeFormatter;
@property (strong, nonatomic) NSNumberFormatter *temperatureFormatter;
@property (strong, nonatomic) OpenWeatherMapAPI *weatherAPI;
@property (strong, nonatomic) CLLocationManager *locationManager;

@end

@implementation MainViewController

- (void)dealloc
{
    [self.timer invalidate];
    self.timer = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self updateTime:nil];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateTime:) userInfo:nil repeats:YES];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
    [self.view addGestureRecognizer:tap];
    
    self.locationLabel.alpha = 0.0;
    self.currentConditionLabel.alpha = 0.0;
    self.currentConditionIcon.alpha = 0.0;
    self.currentTemperatureLabel.alpha = 0.0;
    self.temperatureSegment.alpha = 0.0;
    self.humidityLabel.alpha = 0.0;
    self.windLabel.alpha = 0.0;
    
    UIButton *currentLocationButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    currentLocationButton.frame = CGRectMake(0.0, 0.0, 30.0, 30.0);
    [currentLocationButton setImage:[UIImage imageNamed:@"map_location_service"] forState:UIControlStateNormal];
    [currentLocationButton addTarget:self action:@selector(findCurrentLocation:) forControlEvents:UIControlEventTouchUpInside];
    self.inputField.rightViewMode = UITextFieldViewModeAlways;
    self.inputField.rightView = currentLocationButton;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"ForecastSegue"]) {
        ForecastViewController *fvc = (ForecastViewController *)segue.destinationViewController;
        fvc.location = self.location;
    }
}

- (NSDateFormatter *)dateTimeFormatter
{
    if (!_dateTimeFormatter) {
        _dateTimeFormatter = [[NSDateFormatter alloc] init];
        [_dateTimeFormatter setDateFormat:@"EEEE HH:mm:ss"];
    }
    return _dateTimeFormatter;
}

- (NSNumberFormatter *)temperatureFormatter
{
    if (!_temperatureFormatter) {
        _temperatureFormatter = [[NSNumberFormatter alloc] init];
        _temperatureFormatter.maximumFractionDigits = 1;
    }
    return _temperatureFormatter;
}

- (OpenWeatherMapAPI *)weatherAPI
{
    if (!_weatherAPI) {
        _weatherAPI = [[OpenWeatherMapAPI alloc] init];
    }
    return _weatherAPI;
}

- (CLLocationManager *)locationManager
{
    if (!_locationManager) {
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.delegate = self;
        _locationManager.desiredAccuracy = kCLLocationAccuracyKilometer;
    }
    return _locationManager;
}

- (void)updateTime:(NSTimer *)timer
{
    NSDate *currentTime = [NSDate date];
    self.dateLabel.text = [self.dateTimeFormatter stringFromDate:currentTime];
}

- (void)tap:(UITapGestureRecognizer *)sender
{
    [self.view endEditing:YES];
}

- (IBAction)convertTemperature:(UISegmentedControl *)sender
{
    if (sender.selectedSegmentIndex == 0) {
        self.currentTemperatureLabel.text = [self.temperatureFormatter stringFromNumber:self.temp];
    } else {
        NSNumber *kTemp = @(1.8 * [self.temp floatValue] + 32);
        self.currentTemperatureLabel.text = [self.temperatureFormatter stringFromNumber:kTemp];
    }
}

- (void)findCurrentLocation:(id)sender
{
    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
    if (status == kCLAuthorizationStatusRestricted || status == kCLAuthorizationStatusDenied)
    {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Location Services Disabled"
                                                                       message:@"In order to update weather for current location, please enable location services for this app in settings menu."
                                                                preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
        [alert addAction:[UIAlertAction actionWithTitle:@"Open Settings"
                                                  style:UIAlertActionStyleDefault
                                                handler:^(UIAlertAction *action) {
                                                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
        }]];
        [self presentViewController:alert animated:YES completion:nil];
    }
    else if (status == kCLAuthorizationStatusNotDetermined)
    {
        [self.locationManager requestWhenInUseAuthorization];
    }
    else
    {
        [self.locationManager startUpdatingLocation];
    }
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    NSLog(@"User entered: %@", textField.text);
    
    NSString *city = [textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    self.location = nil;
    __weak __typeof__(self) wself = self;
    [self.weatherAPI currentWeatherForCity:city completion:^(id weather, NSError *error) {
        if (error) {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil
                                                                           message:[error localizedDescription]
                                                                    preferredStyle:UIAlertControllerStyleAlert];
            [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil]];
            [wself presentViewController:alert animated:YES completion:nil];
        } else {
            NSLog(@"%@", weather);
            NSString *city = [weather objectForKey:@"name"];
            NSString *country = [weather valueForKeyPath:@"sys.country"];
            wself.locationLabel.text = [NSString stringWithFormat:@"%@, %@", city, country];
            NSDictionary *currentCondition = [[weather objectForKey:@"weather"] lastObject];
            wself.currentConditionLabel.text = [[currentCondition objectForKey:@"description"] capitalizedString];
            
            NSDictionary *main = [weather objectForKey:@"main"];
            wself.temp = [main objectForKey:@"temp"];
            [wself convertTemperature:wself.temperatureSegment];
            wself.humidityLabel.text = [NSString stringWithFormat:@"Humidity: %@%%", [main objectForKey:@"humidity"]];
            NSNumber *windSpeed = [weather valueForKeyPath:@"wind.speed"];
            windSpeed = @([windSpeed floatValue] * 3.6);
            wself.windLabel.text = [NSString stringWithFormat:@"Wind: %@ km/h", [wself.temperatureFormatter stringFromNumber:windSpeed]];
            
            CLLocationDegrees lat = [[weather valueForKeyPath:@"coord.lat"] doubleValue];
            CLLocationDegrees lon = [[weather valueForKeyPath:@"coord.lon"] doubleValue];
            wself.location = [[CLLocation alloc] initWithLatitude:lat longitude:lon];
            
            [wself.weatherAPI downloadIcon:[currentCondition objectForKey:@"icon"] withCompletion:^(UIImage *icon) {
                if (icon) {
                    wself.currentConditionIcon.image = icon;
                    [UIView animateWithDuration:1.0 animations:^{
                        wself.currentConditionIcon.alpha = 1.0;
                    }];
                }
            }];
            [UIView animateWithDuration:1.0 animations:^{
                wself.locationLabel.alpha = 1.0;
                wself.currentConditionLabel.alpha = 1.0;

                wself.currentTemperatureLabel.alpha = 1.0;
                wself.temperatureSegment.alpha = 1.0;
                wself.humidityLabel.alpha = 1.0;
                wself.windLabel.alpha = 1.0;
            }];
        }
    }];
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    if (status == kCLAuthorizationStatusAuthorizedWhenInUse) {
        [self.locationManager startUpdatingLocation];
    }
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    CLLocation *currentLocation = [locations lastObject];
    [self.locationManager stopUpdatingLocation];
    self.location = currentLocation;
    __weak __typeof__(self) wself = self;
    [self.weatherAPI currentWeatherForCoordinate:currentLocation.coordinate completion:^(id weather, NSError *error) {
        if (error) {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil
                                                                           message:[error localizedDescription]
                                                                    preferredStyle:UIAlertControllerStyleAlert];
            [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil]];
            [wself presentViewController:alert animated:YES completion:nil];
        } else {
            NSLog(@"%@", weather);
            NSString *city = [weather objectForKey:@"name"];
            NSString *country = [weather valueForKeyPath:@"sys.country"];
            wself.locationLabel.text = [NSString stringWithFormat:@"%@, %@", city, country];
            NSDictionary *currentCondition = [[weather objectForKey:@"weather"] lastObject];
            wself.currentConditionLabel.text = [[currentCondition objectForKey:@"description"] capitalizedString];
            
            NSDictionary *main = [weather objectForKey:@"main"];
            wself.temp = [main objectForKey:@"temp"];
            [wself convertTemperature:wself.temperatureSegment];
            wself.humidityLabel.text = [NSString stringWithFormat:@"Humidity: %@%%", [main objectForKey:@"humidity"]];
            NSNumber *windSpeed = [weather valueForKeyPath:@"wind.speed"];
            windSpeed = @([windSpeed floatValue] * 3.6);
            wself.windLabel.text = [NSString stringWithFormat:@"Wind: %@ km/h", [wself.temperatureFormatter stringFromNumber:windSpeed]];
            
            CLLocationDegrees lat = [[weather valueForKeyPath:@"coord.lat"] doubleValue];
            CLLocationDegrees lon = [[weather valueForKeyPath:@"coord.lon"] doubleValue];
            wself.location = [[CLLocation alloc] initWithLatitude:lat longitude:lon];
            
            [wself.weatherAPI downloadIcon:[currentCondition objectForKey:@"icon"] withCompletion:^(UIImage *icon) {
                if (icon) {
                    wself.currentConditionIcon.image = icon;
                    [UIView animateWithDuration:1.0 animations:^{
                        wself.currentConditionIcon.alpha = 1.0;
                    }];
                }
            }];
            [UIView animateWithDuration:1.0 animations:^{
                wself.locationLabel.alpha = 1.0;
                wself.currentConditionLabel.alpha = 1.0;
                
                wself.currentTemperatureLabel.alpha = 1.0;
                wself.temperatureSegment.alpha = 1.0;
                wself.humidityLabel.alpha = 1.0;
                wself.windLabel.alpha = 1.0;
            }];
        }
    }];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    if (error.code == kCLErrorDenied) {
        [self.locationManager stopUpdatingLocation];
    } else {
        // Keep waiting
    }
}

@end
