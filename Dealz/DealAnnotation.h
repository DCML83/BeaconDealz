//
//  DealAnnotation.h
//  Dealz
//
//  Created by Keir SM on 2017-04-06.
//  Copyright © 2017 Keir SM. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>


@interface DealAnnotation : NSObject <MKAnnotation> {
    CLLocationCoordinate2D coordinate;
}
@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *url;
- (id)initWithTitle:(NSString *)newTitle Location:(CLLocationCoordinate2D)coord Url:(NSString *)theUrl;
- (MKAnnotationView *)annotationView;

@end
