//
//  AppDelegate.m
//  Roamer
//
//  Created by Mac Home on 2/21/14.
//
//

#import "AppDelegate.h"
#import "FindRoamersHelper.h"
#import "UserProfileHelper.h"
#import "MyAppConstants.h"
#import "ChatDB.h"

static AppDelegate *sharedDelegate;

@implementation AppDelegate

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

+ (AppDelegate *)sharedDelegate {
    if (!sharedDelegate) {
        sharedDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    }
    
    return sharedDelegate;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
    
   
    //    [UserProfileHelper addChat:@"lou" message:@"Perfect!! I will be in town next week. Will be there for 2 weeks." type:NOT_MY_CHAT isViewed:MSG_IS_VIEWED dateReceived:[NSDate date]];
//    [UserProfileHelper addChat:@"mik100" message:@"Can you accept my invite!!" type:IT_IS_MY_CHAT isViewed:MSG_IS_VIEWED dateReceived:[NSDate date]];
//    [UserProfileHelper addChat:@"ylee413" message:@"What movire!!" type:NOT_MY_CHAT isViewed:MSG_IS_NOT_VIEWED dateReceived:[NSDate date]];
    
    [Parse setApplicationId:@"aK2KQsRgRhGl9HeQrmdQqsW1nNBtXqFSn8OIwgCV"
                  clientKey:@"mN9kJJF96z4Qg5ypejlIqbBplY1zcXMYHYACJEFp"];
    [[FindRoamersHelper sharedHelper] initializeDatabase];
    
    [PFImageView class];

    // Register for Push Notitications, if running iOS 8
    if ([application respondsToSelector:@selector(registerUserNotificationSettings:)]) {
        UIUserNotificationType userNotificationTypes = (UIUserNotificationTypeAlert |
                                                        UIUserNotificationTypeBadge |
                                                        UIUserNotificationTypeSound);
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:userNotificationTypes
                                                                                 categories:nil];
        [application registerUserNotificationSettings:settings];
        [application registerForRemoteNotifications];
    } else {
        // Register for Push Notifications before iOS 8
        [application registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge |
                                                         UIRemoteNotificationTypeAlert |
                                                         UIRemoteNotificationTypeSound)];
    }
    NSDictionary *notificationPayload = launchOptions[UIApplicationLaunchOptionsRemoteNotificationKey];
    
    if(notificationPayload != nil){
        NSString *msgText = [notificationPayload objectForKey:@"alert"];
        NSString *fromUser = [notificationPayload objectForKey:@"from"];
        [self showNotification:msgText from:fromUser];
    }

//    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
//    self.window.backgroundColor = [UIColor whiteColor];
//    [self.window makeKeyAndVisible];
    
     NSLog(@"Hello Mike Infanger, app has started");
    
    return YES;
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)newDeviceToken {
    // Store the deviceToken in the current installation and save it to Parse.
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation setDeviceTokenFromData:newDeviceToken];
    
    [currentInstallation saveInBackground];
    
}

//- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))handler {
    if(userInfo != nil){
        NSString *msgText = [[userInfo valueForKey:@"aps"] valueForKey:@"alert"];
//        NSString *msgText = [userInfo objectForKey:@"alert"];
        NSString *fromUser = [userInfo objectForKey:@"from"];
        [self showNotification:msgText from:fromUser];
        
        NSLog(@"Received notification: %@", fromUser);
    }
    //    [PFPush handlePush:userInfo];
}

-(void) showNotification:(NSString*)msgText from:(NSString *)fromUser {
    
    
    [UserProfileHelper addChat:fromUser message:msgText type:NOT_MY_CHAT isViewed:MSG_IS_NOT_VIEWED dateReceived:[NSDate date]];
    
    
    //Load all chats that we did not previously have loaded
    NSUserDefaults* pref = [NSUserDefaults standardUserDefaults];
    
    NSLog(@"Successfully retrieved userName: %@",[pref objectForKey:PREF_USERNAME]);
    
    PFQuery *query = [PFQuery queryWithClassName:@"Chat"];
    [query whereKey:@"toName" equalTo:[pref objectForKey:PREF_USERNAME]];
    [query whereKey:@"read" equalTo:[NSNumber numberWithBool:(NO)]];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            // The find succeeded.
            NSLog(@"Successfully retrieved %lu chats.", (unsigned long)objects.count);
            // Do something with the found objects
            for (PFObject *object in objects) {
                NSLog(@"%@", object.objectId);
                /*
                [UserProfileHelper addChat:object[@"fromName"] message:object[@"message"] type:NOT_MY_CHAT isViewed:MSG_IS_NOT_VIEWED dateReceived:[NSDate date]];
                */
                //Set the chat to READ
                PFObject *newChat = object;
                
                [newChat deleteInBackground];
            }
        } else {
            // Log details of the failure
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];

    
    NSDictionary *userInfo = [NSDictionary dictionaryWithObject:fromUser forKey:@"from"];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kRefreshRequested object:nil userInfo:userInfo];
    //    [GeneralHelper ShowMessageBoxWithTitle:@"Check In!" Body:msgText tag:-1 andDelegate:nil];
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    if (currentInstallation.badge != 0) {
        currentInstallation.badge = 0;
        [currentInstallation save];
    }
    
    //Load all chats that we did not previously have loaded
    NSUserDefaults* pref = [NSUserDefaults standardUserDefaults];
    
    NSLog(@"Successfully retrieved userName: %@",[pref objectForKey:PREF_USERNAME]);
    
    if ([[pref objectForKey:PREF_USERNAME]length] > 0){
        PFQuery *query = [PFQuery queryWithClassName:@"Chat"];
        [query whereKey:@"toName" equalTo:[pref objectForKey:PREF_USERNAME]];
        [query whereKey:@"read" equalTo:[NSNumber numberWithBool:(NO)]];
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (!error) {
                // The find succeeded.
                NSLog(@"Successfully retrieved %lu chats.", (unsigned long)objects.count);
                // Do something with the found objects
                for (PFObject *object in objects) {
                    NSLog(@"%@", object.objectId);
                    
                    [UserProfileHelper addChat:object[@"fromName"] message:object[@"message"] type:NOT_MY_CHAT isViewed:MSG_IS_NOT_VIEWED dateReceived:[NSDate date]];
                    
                    //Set the chat to READ
                    PFObject *newChat = object;
                    
                    [newChat deleteInBackground];
                }
            } else {
                // Log details of the failure
                NSLog(@"Error: %@ %@", error, [error userInfo]);
            }
        }];
    }
    
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
}

- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
             // Replace this implementation with code to handle the error appropriately.
             // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        } 
    }
}

#pragma mark - Core Data stack

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Roamer" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"Roamer.sqlite"];
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        
        //[[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil];
        
        //@{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES};
        
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
         @{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES}
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }    
    
    return _persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (void) showFetchAlert {
    self.HUD = [[MBProgressHUD alloc] initWithView:self.window];
	[self.window addSubview:self.HUD];
	// Regiser for HUD callbacks so we can remove it from the window at the right time
	self.HUD.delegate = self;
	
    [self.HUD show:YES];
    
	// Show the HUD while the provided method executes in a new thread
    //	[self.HUD showWhileExecuting:@selector(myTask) onTarget:self withObject:nil animated:YES];
    
    /*    if(self.loadingAlert == nil){
     self.loadingAlert=[[UIAlertView alloc] initWithTitle:@"Please wait..." message:@"" delegate:nil cancelButtonTitle:nil otherButtonTitles:nil, nil];
     UIActivityIndicatorView *loadingWeel=[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
     [loadingWeel setFrame:CGRectMake(120, 50, loadingWeel.frame.size.width, loadingWeel.frame.size.height)];
     [loadingWeel startAnimating];
     [self.loadingAlert addSubview:loadingWeel];
     }
     if (!self.loadingAlert.isVisible) {
     [self.loadingAlert show];
     } */
}

- (void)myTask {
	// Do something usefull in here instead of sleeping ...
}

#pragma mark MBProgressHUDDelegate methods

- (void)hudWasHidden:(MBProgressHUD *)hud {
    
	// Remove HUD from screen when the HUD was hidded
	[self.HUD removeFromSuperview];
	self.HUD = nil;
}

- (void) dissmissFetchAlert {
    [self.HUD hide:YES];
    /*    if (self.loadingAlert.isVisible) {
     [self.loadingAlert dismissWithClickedButtonIndex:0 animated:YES];
     } */
}


@end
