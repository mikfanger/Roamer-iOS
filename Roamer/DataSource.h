//
//  DataSource.h
//
//  Created by Rajesh Mehta on 01/15/2014.
//

#import <Foundation/Foundation.h>

@interface DataSource : NSObject

+ (NSArray *) HotelList;
+ (NSArray *) AirlineList;
+ (NSArray *) IndustryList;
+ (NSArray *) ProfileLocList;
+ (NSArray *) CurrentLocList;
+ (NSArray *) EventPostingList;
+ (NSArray *) EventTimeList;
+ (NSArray *) PlacesList;
+ (NSArray *) TravelStatusList;


@end
