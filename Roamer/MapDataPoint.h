//
//  MapDataPoint.h
//  Roamer
//
//  Created by Mac Home on 6/16/14.
//
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface MapDataPoint : NSObject <MKAnnotation> {
    NSString *name;
    NSString *address;
    CLLocationCoordinate2D coordinate;
        
}
    
@property (copy) NSString *name;
@property (copy) NSString *address;
@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;
    
    
- (id)initWithName:(NSString*)name address:(NSString*)address coordinate:(CLLocationCoordinate2D)coordinate;

@end
