//
//  AppDelegate.h
//  Roamer
//
//  Created by Mac Home on 2/21/14.
//
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate, MBProgressHUDDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (nonatomic, strong) MBProgressHUD *HUD;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

+ (AppDelegate *)sharedDelegate;

- (void) showFetchAlert;
- (void) dissmissFetchAlert;

@end
