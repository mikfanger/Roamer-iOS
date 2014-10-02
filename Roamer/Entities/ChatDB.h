//
//  ChatDB.h
//  Roamer
//
//  Created by Rajesh Mehta on 6/26/14.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface ChatDB : NSManagedObject

@property (nonatomic, retain) NSString * username;
@property (nonatomic, retain) NSString * message;
@property (nonatomic, retain) NSNumber * type;
@property (nonatomic, retain) NSNumber * isViewed;
@property (nonatomic, retain) NSDate * dateReceived;
@property (nonatomic, retain) NSString * myusername;

@end
