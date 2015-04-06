//
//  ViewController.m
//  My Last Weather App
//
//  Created by Akbar Nurlybayev on 2015-04-06.
//  Copyright (c) 2015 Akbar Nurlybayev. All rights reserved.
//

#import "MainViewController.h"
#import "OpenWeatherMapAPI.h"

@interface MainViewController () <UITextFieldDelegate>

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

@property (strong, nonatomic) NSTimer *timer;
@property (strong, nonatomic) NSDateFormatter *dateTimeFormatter;
@property (strong, nonatomic) NSNumberFormatter *temperatureFormatter;
@property (strong, nonatomic) OpenWeatherMapAPI *weatherAPI;

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
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
//        NSNumber *cTemp = @([self.temp floatValue] - 273.15);
        self.currentTemperatureLabel.text = [self.temperatureFormatter stringFromNumber:self.temp];
    } else {
        NSNumber *kTemp = @(1.8 * [self.temp floatValue] + 32);
        self.currentTemperatureLabel.text = [self.temperatureFormatter stringFromNumber:kTemp];
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
    [self.weatherAPI currentWeatherForCity:city completion:^(id weather, NSError *error) {
        if (error) {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil
                                                                           message:[error localizedDescription]
                                                                    preferredStyle:UIAlertControllerStyleAlert];
            [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil]];
            [self presentViewController:alert animated:YES completion:nil];
        } else {
            NSLog(@"%@", weather);
            NSString *city = [weather objectForKey:@"name"];
            NSString *country = [weather valueForKeyPath:@"sys.country"];
            self.locationLabel.text = [NSString stringWithFormat:@"%@, %@", city, country];
            NSDictionary *currentCondition = [[weather objectForKey:@"weather"] lastObject];
            self.currentConditionLabel.text = [[currentCondition objectForKey:@"description"] capitalizedString];
            
            NSDictionary *main = [weather objectForKey:@"main"];
            self.temp = [main objectForKey:@"temp"];
            [self convertTemperature:self.temperatureSegment];
            self.humidityLabel.text = [NSString stringWithFormat:@"Humidity: %@%%", [main objectForKey:@"humidity"]];
            NSNumber *windSpeed = [weather valueForKeyPath:@"wind.speed"];
            windSpeed = @([windSpeed floatValue] * 3.6);
            self.windLabel.text = [NSString stringWithFormat:@"Wind: %@ km/h", [self.temperatureFormatter stringFromNumber:windSpeed]];
            
            __weak __typeof__(self) wself = self;
            [self.weatherAPI downloadIcon:[currentCondition objectForKey:@"icon"] withCompletion:^(UIImage *icon) {
                if (icon) {
                    self.currentConditionIcon.image = icon;
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

@end
