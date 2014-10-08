//
//  DataSource.m
//
//  Created by Rajesh Mehta on 01/15/2014.
//

#import "DataSource.h"

@implementation DataSource


+ (NSArray *)HotelList {
    NSString *path = [[NSBundle mainBundle] pathForResource:@"HotelList" ofType:@"plist"];
    return [[NSArray alloc] initWithContentsOfFile:path];
}

+ (NSArray *) AirlineList {
    NSString *path = [[NSBundle mainBundle] pathForResource:@"AirlineList" ofType:@"plist"];
    return [[NSArray alloc] initWithContentsOfFile:path];
}

+ (NSArray *) IndustryList {
    NSString *path = [[NSBundle mainBundle] pathForResource:@"IndustryList" ofType:@"plist"];
    return [[NSArray alloc] initWithContentsOfFile:path];
}

+ (NSArray *) ProfileLocList {
    NSString *path = [[NSBundle mainBundle] pathForResource:@"ProfileLocList" ofType:@"plist"];
    return [[NSArray alloc] initWithContentsOfFile:path];
}

+ (NSArray *) CurrentLocList {
    NSMutableArray* arrayList = [[NSMutableArray alloc] init];
    NSMutableDictionary* dic = [[NSMutableDictionary alloc] init];
    dic[@"name"] = @"Not Selected";
    dic[@"value"] = [NSString stringWithFormat:@"%d",0];
    dic[@"latlong"] = [PFGeoPoint geoPoint];
    [arrayList addObject:dic];

    PFQuery *query = [PFQuery queryWithClassName:@"Cities"];
    NSArray* cityList = [query findObjects];
    if(cityList != nil){
        for(PFObject* obj in cityList){
            NSMutableDictionary* dic = [[NSMutableDictionary alloc] init];
            dic[@"name"] = obj[@"Name"];
            dic[@"value"] = [NSString stringWithFormat:@"%d",[obj[@"Code"] intValue]];
            PFGeoPoint* geoPoint = obj[@"LatLong"];
            if(geoPoint == nil)
                continue;
            
            dic[@"latlong"] = geoPoint;
            [arrayList addObject:dic];
        }
    }

//    NSString *path = [[NSBundle mainBundle] pathForResource:@"CurrentLocList" ofType:@"plist"];
//    return [[NSArray alloc] initWithContentsOfFile:path];
    return arrayList;
}

+ (NSArray *) EventPostingList {
    NSString *path = [[NSBundle mainBundle] pathForResource:@"EventPostList" ofType:@"plist"];
    return [[NSArray alloc] initWithContentsOfFile:path];
}

+ (NSArray *) EventTimeList {
    NSString *path = [[NSBundle mainBundle] pathForResource:@"EventTime" ofType:@"plist"];
    return [[NSArray alloc] initWithContentsOfFile:path];
}

+ (NSArray *) PlacesList {
    NSString *path = [[NSBundle mainBundle] pathForResource:@"PlacesList" ofType:@"plist"];
    return [[NSArray alloc] initWithContentsOfFile:path];
}

+ (NSArray *) TravelStatusList {
    return @[@{@"name": @"0-10% Explorer",@"value":@"01"},@{@"name": @"10-30% Excursionist",@"value":@"02"},@{@"name": @"40-60% Wanderer",@"value":@"03"},@{@"name": @"60-80% Nomad",@"value":@"04"},@{@"name": @"80-100% Globetrotter",@"value":@"05"}];
}

@end
