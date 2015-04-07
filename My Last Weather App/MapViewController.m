//
//  MapViewController.m
//  My Last Weather App
//
//  Created by Akbar Nurlybayev on 2015-04-07.
//  Copyright (c) 2015 Akbar Nurlybayev. All rights reserved.
//

#import "MapViewController.h"

CLLocationDistance const searchRadius = 5000;

@interface MapViewController () <MKMapViewDelegate>

@property (weak, nonatomic) IBOutlet MKMapView *mapView;

@end

@implementation MapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.mapView setDelegate:self];
    [self centerMapOnLocation:self.weather.location];
    [self.mapView addAnnotation:self.weather];
    [self.mapView selectAnnotation:self.weather animated:YES];
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
