//
//  LocationController.m
//  GroupJukeUnited
//
//  Created by Cosmin on 7/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "LocationController.h"

@implementation LocationController
@synthesize country,state,city,updated;
@synthesize currentLocation;
@synthesize noGeoCoder;

SYNTHESIZE_SINGLETON_FOR_CLASS(LocationController)

- (id)init
{
    self = [super init];
    if (self) {
        locationManager = [[CLLocationManager alloc] init];
        locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        locationManager.delegate = self;
        geoCoder=[[CLGeocoder alloc] init];
        updated=FALSE;

    }
    return self;
}

- (BOOL) isLocationTrackingOn {
    if(CLLocationManager.authorizationStatus == kCLAuthorizationStatusAuthorized)
        return TRUE;
    else
        return FALSE;
}

-(void)updateLocation{
    [locationManager startUpdatingLocation];
    
}
-(void) updateCurrentLocationWithCompletion:(void (^) (CLLocation *place))completion{
    self->updateCompletion=completion;
    [locationManager startUpdatingLocation];
}

#pragma mark -
#pragma mark Internal Methods

- (void)startReverseGeocodingWithCurrentLocation
{
	[locationManager stopUpdatingLocation];
    
	if (currentLocation) 
	{
		[geoCoder reverseGeocodeLocation:currentLocation completionHandler:^(NSArray *placemarks, NSError *error) {

            if (placemarks.count>0) {
                CLPlacemark *place=[placemarks objectAtIndex:0];
                
                self.country = place.country;
                self.state = place.administrativeArea;
                self.city = place.locality;
                self.updated=TRUE;
                
                
            }
         
            
        }];
	}
    
    
}

-(void) getDistanceFromLocation:(CLLocation *)location completion:(void (^)(float distance)) completion{
    
    if (noGeoCoder==FALSE) {
        
        float distance=([currentLocation distanceFromLocation:location]/1000)*0.621371192;
        
        completion(distance);
        return;
    }
    completion(-1);
}

-(void) uodateLocationWithAddress:(NSString *) address{
    [geoCoder geocodeAddressString:address completionHandler:^(NSArray *placemarks, NSError *error) {
        
    }];
}

-(void) updateLocationWithAddress:(NSString *) address completion:(void (^)(BOOL finished, CLPlacemark *place))completion{
    [geoCoder geocodeAddressString:address completionHandler:^(NSArray *placemarks, NSError *error) {
        
        if (placemarks.count==0) {
            completion(FALSE,nil);
        }
        else
        {
        CLPlacemark *place=[placemarks objectAtIndex:0];
            completion(TRUE, place);
        }
        
        
        
    }];

}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    NSLog(@"Location manager FAIL %@: ", error.debugDescription);
    noGeoCoder=TRUE;
    updated=FALSE;
    
    if (updateCompletion!=nil) {
        updateCompletion(currentLocation);
        updateCompletion=nil;
    }
}

#pragma mark -
#pragma mark CLLocationManagerDelegate
#define MINIMUM_DISTANCE 200

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    
	noGeoCoder=FALSE;
	currentLocation = newLocation;
    if (updateCompletion!=nil) {
        updateCompletion(currentLocation);
        updateCompletion=nil;
    }
    
    [locationManager stopUpdatingLocation];
    
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
	noGeoCoder=FALSE;
	currentLocation = locations[[locations count] - 1];
    if (updateCompletion!=nil) {
        updateCompletion(currentLocation);
        updateCompletion=nil;
    }
    
    [locationManager stopUpdatingLocation];
    
}

-(void)setStartingPoint:(CLLocationCoordinate2D)point
{
    startingPoint = point;
    
}

- (CLLocationCoordinate2D)getStartingPoint
{
    return startingPoint;
}

-(void)setTempPoint:(CLLocationCoordinate2D)point
{
    tempPoint = point; 
}

- (CLLocationCoordinate2D)getTempPoint
{
    return tempPoint;
}

@end
