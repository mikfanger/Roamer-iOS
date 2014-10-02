//
//  Events.h
//  Roamer
//
//  Created by Mac Home on 3/3/14.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Events : NSManagedObject

@property (nonatomic, retain) NSNumber * rowId;
@property (nonatomic, retain) NSString * type;
@property (nonatomic, retain) NSString * location;
@property (nonatomic, retain) NSString * time;
@property (nonatomic, retain) NSString * host;
@property (nonatomic, retain) id hostimage;
@property (nonatomic, retain) NSString * blurb;
@property (nonatomic, retain) NSString * attend;

+(NSNumber *)nextAvailble:(NSManagedObjectContext *)context;

@end
