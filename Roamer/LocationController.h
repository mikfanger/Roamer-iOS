//
//  LocationController.h
//  GroupJukeUnited
//
//  Created by Cosmin on 7/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
#import "SynthesizeSingleton.h" 
#import <CoreLocation/CoreLocation.h>

@interface LocationController : NSObject<CLLocationManagerDelegate>
{
    CLLocationManager *locationManager;
    CLLocation *currentLocation;
    //MKReverseGeocoder *reverseGeocoder;
    CLLocationCoordinate2D startingPoint;
    CLLocationCoordinate2D tempPoint;

    void (^updateCompletion)(CLLocation*);
    CLGeocoder *geoCoder;
}

@property (nonatomic, strong) CLLocation *currentLocation;
@property (nonatomic) BOOL updated;
@property (nonatomic) BOOL noGeoCoder;
@property (nonatomic, strong) NSString *country;
@property (nonatomic, strong) NSString *state;
@property (nonatomic, strong) NSString *city;

-(void) updateLocation;
-(void) updateCurrentLocationWithCompletion:(void (^) (CLLocation *place))completion;
-(void) getDistanceFromLocation:(CLLocation *)location completion:(void (^)(float distance)) completion;
-(void) uodateLocationWithAddress:(NSString *) address;
-(void) updateLocationWithAddress:(NSString *) address completion:(void (^)(BOOL finished, CLPlacemark *place))completion;
+(LocationController*) sharedLocationController;

- (BOOL) isLocationTrackingOn;


- (CLLocationCoordinate2D)getStartingPoint;
- (void) setStartingPoint:(CLLocationCoordinate2D)point;

- (CLLocationCoordinate2D)getTempPoint;
- (void) setTempPoint:(CLLocationCoordinate2D)point;
@end
