//
//  MapViewController.m
//  My Last Weather App
//
//  Created by Akbar Nurlybayev on 2015-04-07.
//  Copyright (c) 2015 Akbar Nurlybayev. All rights reserved.
//

#import "MapViewController.h"

CLLocationDistance const searchRadius = 5000;

@interface MapViewController ()

@property (weak, nonatomic) IBOutlet MKMapView *mapView;

@end

@implementation MapViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self centerMapOnLocation:self.weather.location];
    [self.mapView addAnnotation:self.weather];
}

- (void)centerMapOnLocation:(CLLocation *)location
{
    MKCoordinateRegion coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, searchRadius * 2.0, searchRadius * 2.0);
    [self.mapView setRegion:coordinateRegion animated:YES];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
