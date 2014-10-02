//
//  UserInfo.h
//  Roamer
//
//  Created by Mac Home on 3/3/14.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface UserInfo : NSManagedObject

@property (nonatomic, retain) NSNumber * userid;
@property (nonatomic, retain) NSString * username;
@property (nonatomic, retain) NSString * emailId;
@property (nonatomic, retain) NSString * password;
@property (nonatomic, retain) NSNumber * gender;
@property (nonatomic, retain) NSString * origin;
@property (nonatomic, retain) NSString * industry;
@property (nonatomic, retain) NSString * job;
@property (nonatomic, retain) NSString * airline;
@property (nonatomic, retain) NSString * hotel;
@property (nonatomic, retain) id image;

+(NSNumber *)nextAvailble:(NSManagedObjectContext *)context;

@end
