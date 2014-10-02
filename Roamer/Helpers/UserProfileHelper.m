//
//  UserProfileHelper.m
//  Roamer
//
//  Created by Mac Home on 3/3/14.
//
//

#import "UserProfileHelper.h"
#import "AppDelegate.h"
#import "UserInfo.h"
#import "MyAppConstants.h"
#import "DataSource.h"
#import "ChatDB.h"

@implementation UserProfileHelper

static UserProfileHelper *instanceOfUserProfileHelper;

+(id) alloc
{
	@synchronized(self)
	{
		NSAssert(instanceOfUserProfileHelper == nil, @"Attempted to allocate a second instance of the singleton: GameObject");
		instanceOfUserProfileHelper = [super alloc];
		return instanceOfUserProfileHelper;
	}
	
	// to avoid compiler warning
	return nil;
}

+(UserProfileHelper*) sharedUserProfileHelper
{
	@synchronized(self)
	{
		if (instanceOfUserProfileHelper == nil)
		{
			[[UserProfileHelper alloc] init];
		}
		
		return instanceOfUserProfileHelper;
	}
	
	// to avoid compiler warning
	return nil;
}

#pragma mark Init & Dealloc

-(id) init
{
	if ((self = [super init]))
	{
	}
	
	return self;
}

- (void) saveToDB:(UIImage *) img {
    NSUserDefaults* pref = [NSUserDefaults standardUserDefaults];

    int gender = [pref integerForKey:PREF_GENDER];
    
    NSManagedObjectContext *addingContext = [[NSManagedObjectContext alloc] init];
    [addingContext setPersistentStoreCoordinator:[AppDelegate sharedDelegate].persistentStoreCoordinator];
    UserInfo *info = [NSEntityDescription insertNewObjectForEntityForName:@"UserInfo" inManagedObjectContext:addingContext];
    info.userid = [UserInfo nextAvailble:addingContext];
    info.username = [pref objectForKey:PREF_USERNAME];
    info.emailId = [pref objectForKey:PREF_EMAIL];
    info.password = [pref objectForKey:PREF_PASSWORD];
    info.gender = [NSNumber numberWithInt:gender];
    info.origin = [pref objectForKey:PREF_REGION];
    info.industry = [pref objectForKey:PREF_INDUSTRY];
    info.job = [pref objectForKey:PREF_JOB];
    info.airline = [pref objectForKey:PREF_AIRLINE];
    info.hotel = [pref objectForKey:PREF_HOTEL];
    info.image = img;

    
    NSError *error;
    if (![info.managedObjectContext save:&error]) {
        NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
    }

}

+ (void) addChat:(NSString *) username message:(NSString *)message type:(int)type isViewed:(int)isViewed dateReceived:(NSDate *)dateReceived {
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];

    NSManagedObjectContext *addingContext = [[NSManagedObjectContext alloc] init];
    [addingContext setPersistentStoreCoordinator:[AppDelegate sharedDelegate].persistentStoreCoordinator];
    ChatDB *info = [NSEntityDescription insertNewObjectForEntityForName:@"ChatDB" inManagedObjectContext:addingContext];
    info.username = username;
    info.message = message;
    info.type = [NSNumber numberWithInt:type];
    info.isViewed = [NSNumber numberWithInt:isViewed];
    info.dateReceived = dateReceived;
    if([prefs objectForKey:PREF_USERNAME])
        info.myusername = [prefs objectForKey:PREF_USERNAME];
    else
        info.myusername = @"";
    
    NSError *error;
    if (![info.managedObjectContext save:&error]) {
        NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
    }

}

+ (void) setChatToAllRead:(NSString *) username {
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSManagedObjectContext *addingContext = [[NSManagedObjectContext alloc] init];
    [addingContext setPersistentStoreCoordinator:[AppDelegate sharedDelegate].persistentStoreCoordinator];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"ChatDB" inManagedObjectContext:addingContext];
    
    [request setEntity:entity];
    // [request setFetchLimit:1];
    
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"myusername = %@ AND username = %@ AND isViewed = %d", [prefs objectForKey:PREF_USERNAME], username, MSG_IS_NOT_VIEWED];
    [request setPredicate:predicate];
    
    
    NSError *error = nil;
    NSArray *results = [addingContext executeFetchRequest:request error:&error];
    if(error) {
    } else {
        for (int i = 0; i < [results count]; i++){
            ChatDB *info = (ChatDB *)results[i];
            info.isViewed = [NSNumber numberWithInt:MSG_IS_VIEWED];
            if (![info.managedObjectContext save:&error]) {
                NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
            }
        }
    }
}

- (void) saveToParse:(UIImage *) img {
    NSUserDefaults* pref = [NSUserDefaults standardUserDefaults];
    
    int gender = [pref integerForKey:PREF_GENDER];
    
    PFObject *roamers = [PFObject objectWithClassName:@"Roamer"];
    roamers[@"Air"] = [pref objectForKey:PREF_AIRLINE];
    roamers[@"Airline"] = [pref objectForKey:PREF_AIRLINE];
//    roamers[@"CurrentLocation"] = [pref objectForKey:PREF_REGION];
    roamers[@"Email"] = [pref objectForKey:PREF_EMAIL];
    roamers[@"Hotel"] = [pref objectForKey:PREF_HOTEL];
    roamers[@"Industry"] = [pref objectForKey:PREF_INDUSTRY];
//    roamers[@"Job"] = [pref objectForKey:PREF_JOB];
    roamers[@"Location"] = [pref objectForKey:PREF_REGION];
    if(gender == 0)
        roamers[@"Male"] = [NSNumber numberWithBool:true];
    else
        roamers[@"Male"] = [NSNumber numberWithBool:false];
    roamers[@"Password"] = [pref objectForKey:PREF_PASSWORD];
    roamers[@"Travel"] = [pref objectForKey:PREF_TRAVEL_LEVEL];
    roamers[@"Username"] = [pref objectForKey:PREF_USERNAME];

    NSData *imageData = UIImagePNGRepresentation(img);
    NSString* fileName = [NSString stringWithFormat:@"%@.png",[pref objectForKey:PREF_USERNAME]];
    PFFile *imageFile = [PFFile fileWithName:fileName data:imageData];
    roamers[@"Pic"] = imageFile;
    [[AppDelegate sharedDelegate] showFetchAlert];
    [roamers saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        [[AppDelegate sharedDelegate] dissmissFetchAlert];
    }];
}

- (PFObject* ) checkIfUserExist:(NSString *) emailId  password:(NSString *)pwd {
    PFObject* returnValue = nil;
    PFQuery *query = [PFQuery queryWithClassName:@"Roamer"];
    [query whereKey:@"Email" equalTo:emailId];
    [query whereKey:@"Password" equalTo:pwd];
    [[AppDelegate sharedDelegate] showFetchAlert];
    NSArray* userList = [query findObjects];
    [[AppDelegate sharedDelegate] dissmissFetchAlert];
    if(userList != nil){
        if([userList count] > 0){
            PFObject* obj = userList[0];
            
            NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
            
            [prefs setObject:[obj objectId] forKey:PREF_USER_OBJECT_ID];
            int loc = [obj[@"CurrentLocation"] intValue];
            [prefs setInteger:loc forKey:PREF_CURRENT_LOC_INT];
            NSDictionary* dict = [self getCurrentLocDictionary:loc];
//            [prefs setObject:[self getCurrentLocString:loc] forKey:PREF_CURRENT_LOC_STRING];
            
            [prefs setObject:dict[@"name"] forKey:PREF_CURRENT_LOC_STRING];
            PFGeoPoint* geoPoint = dict[@"latlong"];
            [prefs setDouble:geoPoint.latitude forKey:PREF_CURRENT_LOC_GEO_LAT];
            [prefs setDouble:geoPoint.longitude forKey:PREF_CURRENT_LOC_GEO_LONG];
            [prefs setObject:obj[@"Username"] forKey:PREF_USERNAME];

            [prefs synchronize];

            
            [prefs synchronize];
            returnValue = obj;
        }
    }
    return returnValue;
}

- (NSDictionary *) getCurrentLocDictionary:(int) loc {
    NSArray *locationArray = [DataSource CurrentLocList];
    NSDictionary* str = nil;
    for(NSDictionary* dict in locationArray) {
        if(loc == [dict[@"value"] intValue]){
            str = dict;
            break;
        }
    }
    if(str == nil)
        return locationArray[0];
    return str;
}

- (NSString *) getCurrentLocString:(int) loc {
    NSArray *locationArray = [DataSource CurrentLocList];
    NSString* str = nil;
    for(NSDictionary* dict in locationArray) {
        if(loc == [dict[@"value"] intValue]){
            str = dict[@"name"];
            break;
        }
    }
    if(str == nil)
        return locationArray[0][@"name"];
    return str;
}

- (BOOL) checkIfUserExistDB:(NSString *) emailId  password:(NSString *)pwd {
    NSManagedObjectContext *addingContext = [[NSManagedObjectContext alloc] init];
    [addingContext setPersistentStoreCoordinator:[AppDelegate sharedDelegate].persistentStoreCoordinator];

    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"UserInfo" inManagedObjectContext:addingContext];
    
    [request setEntity:entity];
    // [request setFetchLimit:1];
    
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"emailId = %@ AND password = %@", emailId, pwd];
    [request setPredicate:predicate];
    
    
    NSError *error = nil;
    NSArray *results = [addingContext executeFetchRequest:request error:&error];
    if(error) {
        return false;
    } else {
        if([results count] > 0)
            return true;
    }
    return false;
}

- (BOOL) checkIfEmailOnlyExist:(NSString *) emailId {
    BOOL returnValue = false;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:
                              @"Email = %@", emailId];
    PFQuery *query = [PFQuery queryWithClassName:@"Roamer" predicate:predicate];
    
    //    PFQuery *query = [PFQuery queryWithClassName:@"Roamer"];
    //    [query whereKey:@"Email" equalTo:emailId];
    //    [query whereKey:@"Username" equalTo:userId];
    [[AppDelegate sharedDelegate] showFetchAlert];
    NSArray* userList = [query findObjects];
    [[AppDelegate sharedDelegate] dissmissFetchAlert];
    if(userList != nil){
        if([userList count] > 0)
            returnValue = true;
    }
    return returnValue;
}


- (BOOL) checkIfEmailExist:(NSString *) emailId userId:(NSString *)userId{
    BOOL returnValue = false;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:
                              @"Email = %@ OR Username = %@", emailId, userId];
    PFQuery *query = [PFQuery queryWithClassName:@"Roamer" predicate:predicate];

//    PFQuery *query = [PFQuery queryWithClassName:@"Roamer"];
//    [query whereKey:@"Email" equalTo:emailId];
//    [query whereKey:@"Username" equalTo:userId];
    NSArray* userList = [query findObjects];
    if(userList != nil){
        if([userList count] > 0)
            returnValue = true;
    }
    return returnValue;
}

+ (void) cacheAddEvent:(NSString *)eventId objectId:(NSString *)objectID {
    if(eventId == nil)
        return;
    NSUserDefaults* pref = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary* dict = [[pref objectForKey:@"EVENT_ID_LIST"] mutableCopy];
    if(dict == nil){
        dict = [[NSMutableDictionary alloc] init];
    }
    [dict setObject:eventId forKey:objectID];
    [pref setObject:dict forKey:@"EVENT_ID_LIST"];
    [pref synchronize];
}

+ (NSString *) getAndRemoveEventFromCache:(NSString *)objectID {
    NSString* eventId = @"";
    NSUserDefaults* pref = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary* dict = [[pref objectForKey:@"EVENT_ID_LIST"] mutableCopy];
    if(dict == nil){
        dict = [[NSMutableDictionary alloc] init];
    }
    eventId = [dict objectForKey:objectID];
    [dict removeObjectForKey:objectID];
    [pref setObject:dict forKey:@"EVENT_ID_LIST"];
    [pref synchronize];
    return eventId;
}


@end
