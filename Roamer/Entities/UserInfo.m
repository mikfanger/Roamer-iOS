//
//  UserInfo.m
//  Roamer
//
//  Created by Mac Home on 3/3/14.
//
//

#import "UserInfo.h"


@implementation UserInfo

@dynamic userid;
@dynamic username;
@dynamic emailId;
@dynamic password;
@dynamic gender;
@dynamic origin;
@dynamic industry;
@dynamic job;
@dynamic airline;
@dynamic hotel;
@dynamic image;

+(NSNumber *)nextAvailble:(NSManagedObjectContext *)context{
    
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSManagedObjectContext *moc = context;
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"UserInfo" inManagedObjectContext:moc];
    
    [request setEntity:entity];
    // [request setFetchLimit:1];
    
    NSArray *propertiesArray = [[NSArray alloc] initWithObjects:@"userid", nil];
    [request setPropertiesToFetch:propertiesArray];
    
    NSSortDescriptor *indexSort = [[NSSortDescriptor alloc] initWithKey:@"userid" ascending:YES];
    NSArray *array = [[NSArray alloc] initWithObjects:indexSort, nil];
    [request setSortDescriptors:array];
    
    NSError *error = nil;
    NSArray *results = [moc executeFetchRequest:request error:&error];
    // NSSLog(@"Autoincrement fetch results: %@", results);
    NSManagedObject *maxIndexedObject = [results lastObject];
    if (error) {
        //        NSSLog(@"Error fetching index: %@\n%@", [error localizedDescription], [error userInfo]);
    }
    //NSAssert3(error == nil, @"Error fetching index: %@\n%@", [error localizedDescription], [error userInfo]);
    
    NSInteger myIndex = 1;
    if (maxIndexedObject) {
        myIndex = [[maxIndexedObject valueForKey:@"userid"] integerValue] + 1;
    }
    
    return [NSNumber numberWithInteger:myIndex];
}

@end
