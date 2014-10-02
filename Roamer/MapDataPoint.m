//
//  MapDataPoint.m
//  Roamer
//
//  Created by Mac Home on 6/16/14.
//
//

#import "MapDataPoint.h"

@implementation MapDataPoint
@synthesize name, address, coordinate;

-(id)initWithName:(NSString*)iName address:(NSString*)iAddress coordinate:(CLLocationCoordinate2D)iCoordinate  {
    if ((self = [super init])) {
        name = [iName copy];
        address = [iAddress copy];
        coordinate = iCoordinate;
        
    }
    return self;
}

-(NSString *)title {
    if ([name isKindOfClass:[NSNull class]])
        return @"Unknown charge";
    else
        return name;
}

-(NSString *)subtitle {
    return address;
}
@end
