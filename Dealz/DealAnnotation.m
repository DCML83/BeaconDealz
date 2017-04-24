//
//  DealAnnotation.m
//  Dealz
//
//  Created by Keir SM on 2017-04-06.
//  Copyright © 2017 Keir SM. All rights reserved.
//

#import "DealAnnotation.h"
#import <MapKit/MapKit.h>

@implementation DealAnnotation

@synthesize coordinate;

- (id)initWithTitle:(NSString *)newTitle Location:(CLLocationCoordinate2D)coord Url:(NSString *)theUrl{
    self = [super init];
    if (self) {
        _title = newTitle;
        coordinate = coord;
        _url = theUrl;
        
    }
    return self;
}

-(MKAnnotationView *)annotationView{
    MKAnnotationView *annotationView = [[MKAnnotationView alloc] initWithAnnotation:self reuseIdentifier:@"DealAnnotation"];
    annotationView.enabled = YES;
    annotationView.canShowCallout = YES;
    annotationView.image = [UIImage imageNamed:@"dz.jpeg"];
    //UIButton *but = [UIButton buttonWithType:UIButtonTypeSystem];
    //[but setTitle:@"Directions" forState:UIControlStateNormal];
    //annotationView.leftCalloutAccessoryView = but;
    annotationView.leftCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeContactAdd];
    annotationView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    
    return annotationView;
}

@end
