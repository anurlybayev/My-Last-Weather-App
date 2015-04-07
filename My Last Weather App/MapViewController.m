//
//  MapViewController.m
//  My Last Weather App
//
//  Created by Akbar Nurlybayev on 2015-04-07.
//  Copyright (c) 2015 Akbar Nurlybayev. All rights reserved.
//

#import "MapViewController.h"
#import "OpenWeatherMapAPI.h"

CLLocationDistance const searchRadius = 5000;

@interface MapViewController () <MKMapViewDelegate>

@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (strong, nonatomic) OpenWeatherMapAPI *weatherAPI;

@end

@implementation MapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.mapView setDelegate:self];
    [self centerMapOnLocation:self.weather.location];
    [self.mapView addAnnotation:self.weather];
    [self.mapView selectAnnotation:self.weather animated:YES];
    
    UILongPressGestureRecognizer *lpgr = [[UILongPressGestureRecognizer alloc] initWithTarget:self
                                                                                       action:@selector(handleLongPress:)];
    lpgr.minimumPressDuration = 2.0;
    [self.mapView addGestureRecognizer:lpgr];
}

- (void)handleLongPress:(UIGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer.state != UIGestureRecognizerStateBegan) {
        return;
    }
    
    CGPoint touchPoint = [gestureRecognizer locationInView:self.mapView];
    CLLocationCoordinate2D touchMapCoordinate = [self.mapView convertPoint:touchPoint toCoordinateFromView:self.mapView];
    
    __weak __typeof__(self) wself = self;
    [self.weatherAPI currentWeatherForCoordinate:touchMapCoordinate completion:^(CurrentWeather *weather, NSError *error) {
        [wself.weatherAPI downloadIcon:weather.weatherIconName withCompletion:^(UIImage *icon) {
            if (icon) {
                weather.weatherIcon = icon;
            }
            [wself.mapView removeAnnotation:wself.weather];
            wself.weather = weather;
            [wself.mapView addAnnotation:weather];
            [wself.mapView selectAnnotation:weather animated:YES];
        }];
    }];
}

- (OpenWeatherMapAPI *)weatherAPI
{
    if (!_weatherAPI) {
        _weatherAPI = [[OpenWeatherMapAPI alloc] init];
    }
    return _weatherAPI;
}


- (void)centerMapOnLocation:(CLLocation *)location
{
    MKCoordinateRegion coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, searchRadius * 2.0, searchRadius * 2.0);
    [self.mapView setRegion:coordinateRegion animated:YES];
}

#pragma mark - MKMapViewDelegate

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    if ([annotation isKindOfClass:[CurrentWeather class]])
    {
        static NSString *const identifier = @"Map Annotation";
        
        MKAnnotationView *annotationView = [mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
        if (annotationView) {
            annotationView.annotation = annotation;
        } else {
            annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
        }
        annotationView.canShowCallout = YES;
        annotationView.image = self.weather.weatherIcon;
        
        return annotationView;
    }
    else {
        return nil;
    }
}

@end
