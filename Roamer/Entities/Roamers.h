//
//  Roamers.h
//  Roamer
//
//  Created by Mac Home on 3/3/14.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Roamers : NSManagedObject

@property (nonatomic, retain) NSNumber * rowId;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) id image;
@property (nonatomic, retain) NSString * location;
@property (nonatomic, retain) NSNumber * gender;
@property (nonatomic, retain) NSDate* roamsincedate;
@property (nonatomic, retain) NSString * jobposition;
@property (nonatomic, retain) NSString * hotelpref;
@property (nonatomic, retain) NSString * airlinepref;
@property (nonatomic, retain) NSNumber * ismyroamer;

+(NSNumber *)nextAvailble:(NSManagedObjectContext *)context;

@end
