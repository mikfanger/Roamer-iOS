//
//  FindRoamersHelper.m
//  Roamer
//
//  Created by Mac Home on 3/4/14.
//
//

#import "FindRoamersHelper.h"
#import "AppDelegate.h"
#import "MyAppConstants.h"
#import "Roamers.h"

@implementation FindRoamersHelper

static FindRoamersHelper *instanceOfHelper;

+(id) alloc
{
	@synchronized(self)
	{
		NSAssert(instanceOfHelper == nil, @"Attempted to allocate a second instance of the singleton: GameObject");
		instanceOfHelper = [super alloc];
		return instanceOfHelper;
	}
	
	// to avoid compiler warning
	return nil;
}

+(FindRoamersHelper*) sharedHelper
{
	@synchronized(self)
	{
		if (instanceOfHelper == nil)
		{
			[[FindRoamersHelper alloc] init];
		}
		
		return instanceOfHelper;
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

- (void) initializeDatabase {
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSManagedObjectContext *addingContext = [[NSManagedObjectContext alloc] init];
    [addingContext setPersistentStoreCoordinator:[AppDelegate sharedDelegate].persistentStoreCoordinator];

	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Roamers" inManagedObjectContext:addingContext];
	[request setEntity:entity];
    
	// Ignore property values for maximum performance
	[request setIncludesPropertyValues:NO];
    
    NSDateFormatter* monDateFormatter = [[NSDateFormatter alloc] init];
    [monDateFormatter setDateFormat:@"MM/dd/yyyy"];
	// Execute the count request
	NSError *error = nil;
	NSArray *fetchResults = [addingContext executeFetchRequest:request error:&error];
    if([fetchResults count] == 0){
        NSArray *values = @[
                            @{@"pic": @"pic1", @"name": @"Nancy", @"location": @"Boston", @"gender": @GENDER_FEMALE, @"roamdate":@"02/16/2013", @"job":@"Manager", @"hotel":@"Hilton", @"airline":@"Ameircan" }
                            , @{@"pic": @"pic2.png", @"name": @"Steve", @"location": @"Dallas", @"gender": @GENDER_MALE, @"roamdate":@"06/26/2013", @"job":@"Consultant", @"hotel":@"Mariott", @"airline":@"United"}
                            , @{@"pic": @"pic3.png", @"name": @"Sandy", @"location": @"Boston", @"gender": @GENDER_FEMALE, @"roamdate":@"08/01/2013", @"job":@"Accountant", @"hotel":@"Starwood", @"airline":@"Delta"}
                            , @{@"pic": @"pic4.png", @"name": @"Roy", @"location": @"Boston", @"gender": @GENDER_MALE, @"roamdate":@"08/11/2012", @"job":@"Executive", @"hotel":@"Westin", @"airline":@"Ameircan"}
                            , @{@"pic": @"pic5.png", @"name": @"Chris", @"location": @"Miami", @"gender": @GENDER_MALE, @"roamdate":@"04/28/2012", @"job":@"Manager", @"hotel":@"Hilton", @"airline":@"Delta"}
                            , @{@"pic": @"pic4.png", @"name": @"Steve", @"location": @"Boston", @"gender": @GENDER_MALE, @"roamdate":@"01/15/2013", @"job":@"Consultant", @"hotel":@"Mariott", @"airline":@"United"}
                            , @{@"pic": @"pic3.png", @"name": @"Stacy", @"location": @"Dallas", @"gender": @GENDER_FEMALE, @"roamdate":@"09/22/2013", @"job":@"Accountant", @"hotel":@"Starwood", @"airline":@"Jet Blue"}
                            , @{@"pic": @"pic1.png", @"name": @"Jim", @"location": @"Boston", @"gender": @GENDER_MALE, @"roamdate":@"06/07/2012", @"job":@"Executive", @"hotel":@"Westin", @"airline":@"Ameircan"}
                            , @{@"pic": @"pic3.png", @"name": @"Rachel", @"location": @"Boston", @"gender": @GENDER_FEMALE, @"roamdate":@"02/12/2011", @"job":@"Manager", @"hotel":@"Starwood", @"airline":@"Jet Blue"}
                            , @{@"pic": @"pic5.png", @"name": @"John", @"location": @"Boston", @"gender": @GENDER_MALE, @"roamdate":@"03/06/2012", @"job":@"Consultant", @"hotel":@"Hilton", @"airline":@"United"}
                            , @{@"pic": @"pic1.png", @"name": @"Jen", @"location": @"Miam", @"gender": @GENDER_FEMALE, @"roamdate":@"07/26/2013", @"job":@"Accountant", @"hotel":@"Mariott", @"airline":@"United"}
                            , @{@"pic": @"pic2.png", @"name": @"Matt", @"location": @"Boston", @"gender": @GENDER_MALE, @"roamdate":@"03/19/2013", @"job":@"Manager", @"hotel":@"Starwood", @"airline":@"Ameircan"}
                            ];

        for(int i = 0; i < [values count]; i++){
            Roamers *roamer = [NSEntityDescription insertNewObjectForEntityForName:@"Roamers"
                                                                  inManagedObjectContext:addingContext];
            NSDictionary* dict = values[i];
            roamer.name = dict[@"name"];
            roamer.location = dict[@"location"];
            NSString* imageName = dict[@"pic"];
            UIImage* image = [UIImage imageNamed:imageName];
            roamer.image = image;
            roamer.gender = dict[@"gender"];
            roamer.roamsincedate = [monDateFormatter dateFromString:dict[@"roamdate"]];
            roamer.jobposition = dict[@"job"];
            roamer.hotelpref = dict[@"hotel"];
            roamer.airlinepref = dict[@"airline"];
            roamer.ismyroamer = @NOT_IN_MY_ROAMER;
            NSError *error;
            if (![roamer.managedObjectContext save:&error]) {
                NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
            }
        }

    }

}

- (NSArray *) findRoamersFor:(NSString *)city {
    NSMutableArray* returnVal = [[NSMutableArray alloc] init];
    return returnVal;
}

- (NSArray *) findRoamersForDB:(NSString *)city {
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSManagedObjectContext *addingContext = [[NSManagedObjectContext alloc] init];
    [addingContext setPersistentStoreCoordinator:[AppDelegate sharedDelegate].persistentStoreCoordinator];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Roamers" inManagedObjectContext:addingContext];
    [request setEntity:entity];

    if(![city isEqualToString:@"All"]){
        NSPredicate* predicate = [NSPredicate predicateWithFormat:@"location like %@", city];
        [request setPredicate:predicate];
    }
    
    NSMutableArray* returnVal = [[NSMutableArray alloc] init];
    // Execute the fetch.
    NSError *error = nil;
    NSArray *objects = [addingContext executeFetchRequest:request error:&error];
    if (objects == nil) {
        // Handle the error.
    }
    else {
        int count = [objects count];
        for (int i = 0; i < count; i++) {
            [returnVal addObject:[objects objectAtIndex:i]];
        }
    }
    return returnVal;
}




@end
