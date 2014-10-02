//
//  UserProfileHelper.h
//  Roamer
//
//  Created by Mac Home on 3/3/14.
//
//

#import <Foundation/Foundation.h>

@interface UserProfileHelper : NSObject

- (void) saveToDB:(UIImage *) img;
- (void) saveToParse:(UIImage *) img;
- (PFObject*) checkIfUserExist:(NSString *) emailId  password:(NSString *)pwd;

- (BOOL) checkIfEmailExist:(NSString *) emailId userId:(NSString *)userId;
- (BOOL) checkIfEmailOnlyExist:(NSString *) emailId;

+ (void) cacheAddEvent:(NSString *)eventId objectId:(NSString *)objectID;
+ (NSString *) getAndRemoveEventFromCache:(NSString *)objectID;
- (NSString *) getCurrentLocString:(int) loc;

+(UserProfileHelper*) sharedUserProfileHelper;

+ (void) addChat:(NSString *) username message:(NSString *)message type:(int)type isViewed:(int)isViewed dateReceived:(NSDate *)dateReceived;
+ (void) setChatToAllRead:(NSString *) username;

@end
