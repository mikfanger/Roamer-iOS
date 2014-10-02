//
//  Roamers.m
//  Roamer
//
//  Created by Mac Home on 3/3/14.
//
//

#import "Roamers.h"


@implementation Roamers

@dynamic rowId;
@dynamic name;
@dynamic image;
@dynamic location;
@dynamic gender;
@dynamic roamsincedate;
@dynamic jobposition;
@dynamic hotelpref;
@dynamic airlinepref;

+(NSNumber *)nextAvailble:(NSManagedObjectContext *)context{
    
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSManagedObjectContext *moc = context;
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Roamers" inManagedObjectContext:moc];
    
    [request setEntity:entity];
    // [request setFetchLimit:1];
    
    NSArray *propertiesArray = [[NSArray alloc] initWithObjects:@"rowId", nil];
    [request setPropertiesToFetch:propertiesArray];
    
    NSSortDescriptor *indexSort = [[NSSortDescriptor alloc] initWithKey:@"rowId" ascending:YES];
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
        myIndex = [[maxIndexedObject valueForKey:@"rowId"] integerValue] + 1;
    }
    
    return [NSNumber numberWithInteger:myIndex];
}

@end
