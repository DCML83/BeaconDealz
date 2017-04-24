//
//  SecondViewController.h
//  Dealz
//
//  Created by Keir SM on 2017-03-28.
//  Copyright © 2017 Keir SM. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>


@interface MapViewController : UIViewController <MKMapViewDelegate>
@property (weak, nonatomic) IBOutlet UILabel *destinationLabel;

@property (weak, nonatomic) IBOutlet UILabel *distanceLabel;
@property (weak, nonatomic) IBOutlet UITextView *steps;

@property (strong, nonatomic) NSString *allSteps;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *clearBtn;

@end

