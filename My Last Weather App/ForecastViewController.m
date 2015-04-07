//
//  ForecastViewController.m
//  My Last Weather App
//
//  Created by Akbar Nurlybayev on 2015-04-06.
//  Copyright (c) 2015 Akbar Nurlybayev. All rights reserved.
//

#import "ForecastViewController.h"
#import "ForecastCell.h"
#import "OpenWeatherMapAPI.h"

@interface ForecastViewController ()

@property (strong, nonatomic) NSArray *forecast;
@property (strong, nonatomic) NSDateFormatter *dateTimeFormatter;
@property (strong, nonatomic) NSNumberFormatter *temperatureFormatter;
@property (strong, nonatomic) OpenWeatherMapAPI *weatherAPI;

@end

@implementation ForecastViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    __weak __typeof__(self) wself = self;
    [self.weatherAPI weatherForecastForCoordinate:self.weather.location.coordinate completion:^(id forecast, NSError *error) {
        if (error) {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil
                                                                           message:[error localizedDescription]
                                                                    preferredStyle:UIAlertControllerStyleAlert];
            [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil]];
            [wself presentViewController:alert animated:YES completion:nil];
        } else {
            wself.forecast = [forecast objectForKey:@"list"];
            [wself.tableView reloadData];
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSDateFormatter *)dateTimeFormatter
{
    if (!_dateTimeFormatter) {
        _dateTimeFormatter = [[NSDateFormatter alloc] init];
        [_dateTimeFormatter setDateFormat:@"EEEE, MMM dd"];
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

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.forecast count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ForecastCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([ForecastCell class]) forIndexPath:indexPath];
    
    NSDictionary *forecast = [self.forecast objectAtIndex:indexPath.row];
    cell.dayTemperatureLabel.text = [NSString stringWithFormat:@"%@º", [self.temperatureFormatter stringFromNumber:[forecast valueForKeyPath:@"temp.day"]]];
    cell.nightTemperatureLabel.text = [NSString stringWithFormat:@"%@º", [self.temperatureFormatter stringFromNumber:[forecast valueForKeyPath:@"temp.night"]]];
    NSString *iconName = [[[forecast objectForKey:@"weather"] lastObject] objectForKey:@"icon"];
    [self.weatherAPI downloadIcon:iconName withCompletion:^(UIImage *icon) {
        if (icon) {
            cell.forecastIcon.image = icon;
        }
    }];
    
    NSDateComponents *components = [[NSDateComponents alloc] init];
    components.day = indexPath.row + 1;
    NSDate *nextDate = [[NSCalendar currentCalendar] dateByAddingComponents:components toDate:[NSDate date] options:0];
    cell.weekDayLabel.text = [self.dateTimeFormatter stringFromDate:nextDate];
    
    return cell;
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
