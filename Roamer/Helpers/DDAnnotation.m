//
//  DDAnnotation.m
//  Roamer
//
//  Created by Rajesh Mehta on 9/19/14.
//
//

#import "DDAnnotation.h"

@interface DDAnnotation ()
@property (nonatomic, retain) MKPlacemark *placemark;
- (void)notifyCalloutInfo:(MKPlacemark *)placemark;
@end

@implementation DDAnnotation

@synthesize placemark = _placemark;

- (id)initWithCoordinate:(CLLocation *)location title:(NSString*)title {
    if (self = [super init]) {
        [self changeCoordinate:location];
        self.coordinate = location.coordinate;
        self.title = title;
        _placemark = nil;
    }
    return self;
}

#pragma mark -
#pragma mark MKAnnotation Methods


#pragma mark -
#pragma mark Change coordinate

- (void)changeCoordinate:(CLLocation *)currentLocation {
    _location = currentLocation;
    self.coordinate = _location.coordinate;
    
    if (!geocoder)
        geocoder = [[CLGeocoder alloc] init];
    
    [geocoder reverseGeocodeLocation:currentLocation completionHandler:
     ^(NSArray* placemarks, NSError* error){
         if ([placemarks count] > 0)
         {
             MKPlacemark *placemark = [placemarks objectAtIndex:0];
             [self notifyCalloutInfo:placemark];
         } else {
             [self notifyCalloutInfo:nil];
         }
     }];
}

#pragma mark -
#pragma mark MKAnnotationView Notification

- (void)notifyCalloutInfo:(MKPlacemark *)newPlacemark {
    [self willChangeValueForKey:@"subtitle"]; // Workaround for SDK 3.0, otherwise callout info won't update.
    self.placemark = newPlacemark;
    [self didChangeValueForKey:@"subtitle"]; // Workaround for SDK 3.0, otherwise callout info won't update.
    
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"MKAnnotationCalloutInfoDidChangeNotification" object:self]];
}

#pragma mark -

@end
