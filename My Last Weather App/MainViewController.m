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
#import "MapViewController.h"

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

@property (strong, nonatomic) CurrentWeather *currentWeather;

@property (strong, nonatomic) NSTimer *timer;
@property (strong, nonatomic) NSDateFormatter *dateTimeFormatter;
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
        fvc.weather = self.currentWeather;
    } else if ([segue.identifier isEqualToString:@"MapSegue"]) {
        MapViewController *mvc = (MapViewController *)segue.destinationViewController;
        mvc.weather = self.currentWeather;
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
    self.currentWeather.isFahrenheit = (sender.selectedSegmentIndex == 1);
    self.currentTemperatureLabel.text = [self.currentWeather.numberFormatter stringFromNumber:self.currentWeather.temperature];
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
    __weak __typeof__(self) wself = self;
    [self.weatherAPI currentWeatherForCity:city completion:^(CurrentWeather *weather, NSError *error) {
        if (error) {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil
                                                                           message:[error localizedDescription]
                                                                    preferredStyle:UIAlertControllerStyleAlert];
            [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil]];
            [wself presentViewController:alert animated:YES completion:nil];
        } else {
            wself.currentWeather = weather;
            wself.locationLabel.text = [weather locationDescription];
            wself.currentConditionLabel.text = [weather weatherDescription];
            
            [wself convertTemperature:wself.temperatureSegment];
            wself.humidityLabel.text = [weather humidityDescription];
            wself.windLabel.text = [weather windSpeedDescription];
            
            [wself.weatherAPI downloadIcon:[weather weatherIconName] withCompletion:^(UIImage *icon) {
                if (icon) {
                    wself.currentWeather.weatherIcon = icon;
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
    __weak __typeof__(self) wself = self;
    [self.weatherAPI currentWeatherForCoordinate:currentLocation.coordinate completion:^(CurrentWeather *weather, NSError *error) {
        if (error) {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil
                                                                           message:[error localizedDescription]
                                                                    preferredStyle:UIAlertControllerStyleAlert];
            [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil]];
            [wself presentViewController:alert animated:YES completion:nil];
        } else {
            wself.currentWeather = weather;
            wself.locationLabel.text = [weather locationDescription];
            wself.currentConditionLabel.text = [weather weatherDescription];
            
            [wself convertTemperature:wself.temperatureSegment];
            wself.humidityLabel.text = [weather humidityDescription];
            wself.windLabel.text = [weather windSpeedDescription];
            
            [wself.weatherAPI downloadIcon:[weather weatherIconName] withCompletion:^(UIImage *icon) {
                if (icon) {
                    wself.currentWeather.weatherIcon = icon;
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
