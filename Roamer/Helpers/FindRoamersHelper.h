//
//  FindRoamersHelper.h
//  Roamer
//
//  Created by Mac Home on 3/4/14.
//
//

#import <Foundation/Foundation.h>

@interface FindRoamersHelper : NSObject

+(FindRoamersHelper*) sharedHelper;

- (NSArray *) findRoamersFor:(NSString *)city;

- (void) initializeDatabase;

@end
