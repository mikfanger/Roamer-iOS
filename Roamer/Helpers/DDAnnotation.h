//
//  DDAnnotation.h
//  Roamer
//
//  Created by Rajesh Mehta on 9/19/14.
//
//

#import <MapKit/MapKit.h>

@interface DDAnnotation : MKPointAnnotation {
    CLLocation * _location;
    //	NSString *name;
    MKPlacemark *_placemark;
    CLGeocoder* geocoder;
    //    CLLocationCoordinate2D coordinate;
}

//@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;

- (id)initWithCoordinate:(CLLocation *)coordinate title:(NSString*)title;
- (void)changeCoordinate:(CLLocation *)coordinate;

@end
