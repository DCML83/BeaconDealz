//
//  SecondViewController.m
//  Dealz
//
//  Created by Keir SM on 2017-03-28.
//  Copyright © 2017 Keir SM. All rights reserved.
//

#import "MapViewController.h"
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import "DealAnnotation.h"
#import "PopupViewController.h"
#import "DatabaseManager.h"


@interface MapViewController (){
    CLLocationManager *myLocationManager;
    Boolean didUpdateLocation;
    NSString *cTitle;
    NSString *cUrl;
    MKMapView *mView;
    MKRoute *routeDetails;
    CGRect screen;
    BOOL trackActive;
    

    NSMutableArray *arrays;
    
    MKDirectionsRequest *request;
    MKPlacemark *destination;
    MKDirections *directions;
    
}

@end

@implementation MapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //allocating the arrays needed

    arrays = [[NSMutableArray alloc] init];

    [self loadData:nil];
    

    
    didUpdateLocation = false;
    //Create Location Manager
    myLocationManager = [[CLLocationManager alloc] init];
    //Request authorization to use location
    if ([myLocationManager respondsToSelector: @selector(requestWhenInUseAuthorization)]) {
        [myLocationManager requestWhenInUseAuthorization];
    }
    
    //Getting bounds of screen and setting the frame of the mapView to their values
    screen = [[UIScreen mainScreen] bounds];
    mView = [[MKMapView alloc] initWithFrame:screen ];
    
    //Choosing map type
    mView.mapType = MKMapTypeStandard;
    //Enabling user location, scroll, and zoom.
    mView.showsUserLocation = YES;
    mView.scrollEnabled = YES;
    mView.zoomEnabled = YES;
    //Set map delegate
    mView.delegate = self;
    //disables the clear button if it's not needed
    _clearBtn.enabled = NO;
    //variable to check whenever the user is asking for directions to reach a placemark
    trackActive = NO;

    NSMutableDictionary *pointC = [arrays firstObject];

    for (pointC in arrays){
        float lat = [pointC[@"lat"] floatValue];
        float lon = [[pointC valueForKey:@"long"] floatValue];

        NSString *named = [pointC valueForKey:@"name"];

        CLLocationCoordinate2D coords = CLLocationCoordinate2DMake(lat, lon);
        DealAnnotation *dann = [[DealAnnotation alloc] initWithTitle:named Location:coords Url:[pointC valueForKey:@"url"]];
        [mView addAnnotation:dann];
        
    }

    
    [self.view addSubview:mView];
    
}
//function that displays what happens when an annotation is clicked
-(MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation{
    if ([annotation isKindOfClass:[DealAnnotation class]]){
        DealAnnotation *customAnnotation = (DealAnnotation *)annotation;
        MKAnnotationView *annotationView = [mapView dequeueReusableAnnotationViewWithIdentifier:@"DealAnnotation"];
        if (annotationView == nil){
            annotationView = customAnnotation.annotationView;
        } else {
            annotationView.annotation = annotation;
        }
        return annotationView;
    } else {
        return nil;
    }
}


-(void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    if (!didUpdateLocation){
        
        MKCoordinateRegion mapRegion;
        //Center on userLocation
        mapRegion.center = mapView.userLocation.coordinate;
        //How much to zoom
        mapRegion.span.latitudeDelta = 0.1;
        mapRegion.span.longitudeDelta = 0.1;
        
        [mapView setRegion:mapRegion animated: YES];
        didUpdateLocation = true;
    }
    // if the user is currently following directions to reach a deal location, then this is going to constantly update the steps and the distance
    else if(trackActive){
        [directions calculateDirectionsWithCompletionHandler:^(MKDirectionsResponse *response, NSError *error) {
            if (error) {
                NSLog(@"Error %@", error.description);
            } else {
                routeDetails = response.routes.lastObject;
                [mapView addOverlay:routeDetails.polyline];
                self.distanceLabel.text = [NSString stringWithFormat:@"%0.1f Miles", routeDetails.distance/1609.344];
                
                self.allSteps = @"";
                for (int i = 0; i < routeDetails.steps.count; i++) {
                    MKRouteStep *step = [routeDetails.steps objectAtIndex:i];
                    NSString *newStep = step.instructions;
                    self.allSteps = [self.allSteps stringByAppendingString:newStep];
                    self.allSteps = [self.allSteps stringByAppendingString:@"\n\n"];
                    self.steps.text = self.allSteps;
                }
            }
        }];

    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
    //Clears all overlays
    [mView removeOverlays:mView.overlays];
    
    trackActive = YES;
    _clearBtn.enabled = YES;
    
    //draws a polyline from the user location to the deal
    DealAnnotation *da = (DealAnnotation *)view.annotation;
    if (control == view.rightCalloutAccessoryView){
        cTitle =  da.title;
        cUrl = da.url;
        [self performSegueWithIdentifier:@"move" sender:self];
    } else if (control == view.leftCalloutAccessoryView){
        screen = [[UIScreen mainScreen] bounds];
        screen.size.height = 300;
        
        mView.frame = screen;
        
        request = [[MKDirectionsRequest alloc] init];
        [request setSource:[MKMapItem mapItemForCurrentLocation]];
        
        destination = [[MKPlacemark alloc]initWithCoordinate:da.coordinate addressDictionary:[NSDictionary dictionaryWithObjectsAndKeys:@"",@"", nil] ];
        
        MKMapItem *destMapItem = [[MKMapItem alloc]initWithPlacemark:destination];
        
        [request setDestination:destMapItem];
        //Set's the transport type to display the directions
        [request setTransportType:MKDirectionsTransportTypeAutomobile];
        
        MKDirections *direction = [[MKDirections alloc] initWithRequest:request];
        
        [direction calculateDirectionsWithCompletionHandler:^(MKDirectionsResponse *response, NSError *error) {
            
            NSArray *arrRoutes = [response routes];
            [arrRoutes enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                
                MKRoute *rout = obj;
                
                MKPolyline *line = [rout polyline];
                [mapView addOverlay:line];
            }];
        }];
        
        
        //request directions for the placemark and displays the main information about the route
        
        [request setSource:[MKMapItem mapItemForCurrentLocation]];
        [request setDestination:[[MKMapItem alloc] initWithPlacemark:destination]];
        request.transportType = MKDirectionsTransportTypeAutomobile;
        directions = [[MKDirections alloc] initWithRequest:request];
        [directions calculateDirectionsWithCompletionHandler:^(MKDirectionsResponse *response, NSError *error) {
            if (error) {
                NSLog(@"Error %@", error.description);
            } else {
                routeDetails = response.routes.lastObject;
                [mapView addOverlay:routeDetails.polyline];
                self.distanceLabel.text = [NSString stringWithFormat:@"%0.1f Miles", routeDetails.distance/1609.344];

                self.allSteps = @"";
                for (int i = 0; i < routeDetails.steps.count; i++) {
                    MKRouteStep *step = [routeDetails.steps objectAtIndex:i];
                    NSString *newStep = step.instructions;
                    self.allSteps = [self.allSteps stringByAppendingString:newStep];
                    self.allSteps = [self.allSteps stringByAppendingString:@"\n\n"];
                    self.steps.text = self.allSteps;
                }
            }
        }];

    }
}

- (MKPolylineRenderer *)mapView:(MKMapView *)mapView viewForOverlay:(id <MKOverlay>)overlay {
    //Sets the color and width of the polyline and returns it to be rendered

    MKPolylineRenderer *polylineRenderer = [[MKPolylineRenderer alloc] initWithPolyline:overlay];
    
    polylineRenderer.strokeColor = [UIColor blueColor];
    polylineRenderer.lineWidth = 6.0f;
    return polylineRenderer;

}
//clears every variable needed for the directions, disables the clear button and restores the map original size
- (IBAction)ClearButton:(UIBarButtonItem *)sender {
    trackActive = NO;
    _clearBtn.enabled = NO;
    self.distanceLabel.text = @"";
    self.allSteps = @"";

    //Clears all overlays
    [mView removeOverlays:mView.overlays];
    
    screen = [[UIScreen mainScreen] bounds];
    mView.frame = screen;
    
}

//sets the segue to open the web view
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"move"]){
        PopupViewController *vc = [segue destinationViewController];
        
        [vc navTitle:cTitle];
        [vc pageUrl:cUrl];
    }
}


- (void)loadData:(NSArray*)sender
{
    
    //open database
    const char *dbpath = [[DatabaseManager getPath] UTF8String];
    sqlite3_stmt    *statement;
    sqlite3* beaconDatabase = [DatabaseManager getDatabase];
    //start query
    if (sqlite3_open(dbpath, &beaconDatabase) == SQLITE_OK)
    {
        
    
        NSString *querySQL = [NSString stringWithFormat:
                              @"SELECT * FROM beacons"];
        
        //if query is successful load data into memory
        const char *query_stmt = [querySQL UTF8String];
        
        if (sqlite3_prepare_v2(beaconDatabase,
                               query_stmt, -1, &statement, NULL) == SQLITE_OK)
        {
            while(sqlite3_step(statement) == SQLITE_ROW)
                
            {
                NSMutableDictionary *_dataDictionary=[[NSMutableDictionary alloc] init];
                NSString *currentLong = [[NSString alloc]
                                         initWithUTF8String:
                                         (const char *) sqlite3_column_text(statement,6)];
                
                
                
                
                NSString *currentLat = [[NSString alloc]
                                        initWithUTF8String:
                                        (const char *) sqlite3_column_text(statement, 5)];
 
                
                NSString *currentURL = [[NSString alloc]
                                        initWithUTF8String:
                                        (const char *) sqlite3_column_text(statement, 4)];

                
                NSString *currentName = [[NSString alloc]
                                        initWithUTF8String:
                                        (const char *) sqlite3_column_text(statement, 2)];

         
               
           
                [_dataDictionary setObject:[NSString stringWithFormat:@"%@",currentLat] forKey:@"lat"];
                [_dataDictionary setObject:[NSString stringWithFormat:@"%@",currentLong] forKey:@"long"];
                [_dataDictionary setObject:[NSString stringWithFormat:@"%@",currentURL] forKey:@"url"];
                [_dataDictionary setObject:[NSString stringWithFormat:@"%@",currentName] forKey:@"name"];

                
                [arrays addObject: _dataDictionary];
                
            
            }
            sqlite3_finalize(statement);
        }
        
    }
    
    
 
    
    sqlite3_close(beaconDatabase);
}



@end
