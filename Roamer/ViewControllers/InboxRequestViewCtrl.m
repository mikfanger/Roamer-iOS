//
//  InboxRequestViewCtrl.m
//  Roamer
//
//  Created by Rajesh Mehta on 6/25/14.
//
//

#import "InboxRequestViewCtrl.h"
#import "MyAppConstants.h"
#import "DataSource.h"
#import "InboxTableViewCell.h"
#import "RoamerProfileViewCtrl.h"
#import "AppDelegate.h"
#import "ChatDB.h"

@interface InboxRequestViewCtrl () {
    NSMutableArray *inboxListArray;
    NSMutableArray *requestListArray;
    NSIndexPath *currentIndex;
    int currentEventType;
    NSMutableDictionary *imageToUsernameMap;

    CGRect  viewSelectRect;
    CGRect  viewSelectRectHidden;
    NSString* selectedUserName;
}

@end

@implementation InboxRequestViewCtrl

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationToRefresh:) name:kRefreshRequested object:nil];

    currentEventType = SHOW_INBOX;

    inboxListArray = [[NSMutableArray alloc] init];
    requestListArray = [[NSMutableArray alloc] init];
    imageToUsernameMap = [[NSMutableDictionary alloc] init];

    self.managedObjectContext = [[AppDelegate sharedDelegate] managedObjectContext];

    viewSelectRect = self.mSelectRoamerView.frame;
    viewSelectRectHidden = CGRectMake(0, viewSelectRect.origin.y + viewSelectRect.size.height + 30, viewSelectRect.size.width, viewSelectRect.size.height);
    self.mSelectRoamerView.frame = viewSelectRectHidden;
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if(currentEventType == SHOW_INBOX)
        [self showInbox];
    else
        [self showRequests];
        
}

- (void) notificationToRefresh: (NSNotification* )note
{
    if(currentEventType == SHOW_INBOX)
        [self fetchInboxData];
}

- (void) showInbox {
    currentEventType = SHOW_INBOX;
    self.mInboxLabel.textColor = [UIColor whiteColor];
    self.mInboxView.backgroundColor = [UIColor colorWithRed:49.0f/255.0f green:50.0f/255.0f blue:52.0f/255.0f alpha:1.0f];
    
    self.mRequestsLabel.textColor = [UIColor colorWithRed:99.0f/255.0f green:99.0f/255.0f blue:99.0f/255.0f alpha:1.0f];
    self.mRequestsView.backgroundColor = [UIColor colorWithRed:38.0f/255.0f green:38.0f/255.0f blue:38.0f/255.0f alpha:1.0f];
    
    [self fetchInboxData];
}

- (void) showRequests {
    currentEventType = SHOW_REQUESTS;
    self.mRequestsLabel.textColor = [UIColor whiteColor];
    self.mRequestsView.backgroundColor = [UIColor colorWithRed:49.0f/255.0f green:50.0f/255.0f blue:52.0f/255.0f alpha:1.0f];
    
    self.mInboxLabel.textColor = [UIColor colorWithRed:99.0f/255.0f green:99.0f/255.0f blue:99.0f/255.0f alpha:1.0f];
    self.mInboxView.backgroundColor = [UIColor colorWithRed:38.0f/255.0f green:38.0f/255.0f blue:38.0f/255.0f alpha:1.0f];
    
    [self fetchRequest];
}

- (void) fetchInboxData{
    [NSFetchedResultsController deleteCacheWithName:@"InboxList"];
    _fetchedResultsController = nil;
    [self.mTableView reloadData];
}

- (void) fetchRequest{
    NSMutableArray* requestArray = self.userRoamer[@"Requests"];
    if(requestArray == nil){
        [self.mTableView reloadData];
        return;
    }
    
    PFQuery *query = [PFQuery queryWithClassName:@"Roamer"];
    [query whereKey:@"Username" containedIn:requestArray];
    
	query.limit = 1000;
    
    [[AppDelegate sharedDelegate] showFetchAlert];
	[query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        [[AppDelegate sharedDelegate] dissmissFetchAlert];
		if (error) {
			NSLog(@"error in query!"); // todo why is this ever happening?
		} else {
            [requestListArray removeAllObjects];
            [requestListArray addObjectsFromArray:objects];
            [self.mTableView reloadData];
        }
    }];
}

- (void) slideInSelectRoamerViewAnimation {
    self.mSelectRoamerView.frame = viewSelectRectHidden;
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:0.6f];
    self.mSelectRoamerView.frame = viewSelectRect;
	[UIView commitAnimations];
}

- (void) slideOutSelectRoamerViewAnimation {
    self.mSelectRoamerView.frame = viewSelectRect;
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:0.6f];
    self.mSelectRoamerView.frame = viewSelectRectHidden;
	[UIView commitAnimations];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)onBackAction:(id)sender {
    [self.delegate backFromInboxRequestView:self];
}

- (IBAction)onInboxAction:(id)sender {
    [self.userRoamer refresh];
    [self showInbox];
}

- (IBAction)onRequestsAction:(id)sender {
    [self.userRoamer refresh];
    [self showRequests];
}

- (IBAction)onSendAction:(id)sender {
    [self slideInSelectRoamerViewAnimation];
}

- (IBAction)onCancelSelectRoamerAction:(id)sender {
    [self slideOutSelectRoamerViewAnimation];
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if(tableView == self.mSelectRoamerTableView)
        return 1;
        
    if(currentEventType == SHOW_INBOX)
        return [[self.fetchedResultsController sections] count];
    else
        return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(tableView == self.mSelectRoamerTableView)
        return [self.userRoamer[@"MyRoamers"] count];

    if(currentEventType == SHOW_INBOX) {
        id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][section];
        NSInteger count = [sectionInfo numberOfObjects];
        if(count > 0)
            return 1;
        return count;
//        return [inboxListArray count];
    } else
        return [requestListArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(tableView == self.mSelectRoamerTableView) {
        static NSString *CellIdentifier = @"DataCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        NSArray* list = self.userRoamer[@"MyRoamers"];
        cell.textLabel.text = list[indexPath.row];
        
        return cell;
    }
    if(currentEventType == SHOW_INBOX) {
        NSString *CellIdentifier = @"InboxTableViewCell";
        InboxTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        ChatDB *chat = (ChatDB *)[self.fetchedResultsController objectAtIndexPath:indexPath];
        
        cell.mProfileImg.layer.masksToBounds = YES;
        cell.mProfileImg.layer.cornerRadius = 8.0;
        cell.mNameLabel.text = chat.username; //roamers.name;
        cell.mMsgLabel.text = chat.message;
        int newMail = [chat.isViewed intValue];
        if(newMail == MSG_IS_NOT_VIEWED)
            cell.mNewMailImg.hidden = false;
        else
            cell.mNewMailImg.hidden = true;
        
        [self fetchImageFor:chat.username imageView:(PFImageView*)cell.mProfileImg];
        
        return cell;
    } else {
        NSString *CellIdentifier = @"RequestTableViewCell";
        RequestTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        PFObject *roamers = requestListArray[indexPath.row];
    
        cell.mProfileImg.layer.masksToBounds = YES;
        cell.mProfileImg.layer.cornerRadius = 8.0;
        cell.mNameLabel.text = roamers[@"Username"]; //roamers.name;
    
        cell.delegate = self;
        cell.mRowIndex = (int)indexPath.row;
        
        PFFile *userImageFile = roamers[@"Pic"];
        PFImageView *thumbnailImageView = (PFImageView*)cell.mProfileImg;
        thumbnailImageView.file = userImageFile;
        [thumbnailImageView loadInBackground];

        return cell;
    }
}

- (void) fetchImageFor:(NSString *) userName imageView:(PFImageView *)iView {
    UIImage* proImg = imageToUsernameMap[userName];
    if(proImg != nil) {
        iView.image = proImg;
        return;
    }
    
    PFQuery *query = [PFQuery queryWithClassName:@"Roamer"];
    [query whereKey:@"Username" equalTo:userName];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            if([objects count] > 0){
                PFObject *roamers = objects[0];
                PFFile *userImageFile = roamers[@"Pic"];
                [userImageFile getDataInBackgroundWithBlock:^(NSData *imageData, NSError *error) {
                    if (!error) {
                        imageToUsernameMap[userName] = [UIImage imageWithData:imageData];
                        iView.image = imageToUsernameMap[userName];
                    }
                }];
            }
        } else {
            // Log details of the failure
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];

}

- (id) checkForNull:(id)obj {
    if([obj isKindOfClass:[NSNull class]])
        return nil;
    
    return obj;
}

- (BOOL)tableView:(UITableView *) tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    currentIndex = indexPath;
    if(tableView == self.mSelectRoamerTableView) {
        [self slideOutSelectRoamerViewAnimation];
        NSArray* list = self.userRoamer[@"MyRoamers"];
        selectedUserName = list[indexPath.row];
        [self performSegueWithIdentifier:@"performChatDetail" sender:self];
        return;
    }

    if(currentEventType == SHOW_INBOX) {
        ChatDB *chat = (ChatDB *)[self.fetchedResultsController objectAtIndexPath:currentIndex];

        selectedUserName = chat.username;
        [self performSegueWithIdentifier:@"performChatDetail" sender:self];
    } else {
        [self performSegueWithIdentifier:@"performShowRoamerDetail" sender:self];
    }
}

//allow for delete of row and delete if it is selected
-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    if (editingStyle == UITableViewCellEditingStyleDelete){
        ChatDB *chat = [self.fetchedResultsController objectAtIndexPath:indexPath];
        NSString *stringName = chat.username;
        
        NSManagedObjectContext *moc = [self managedObjectContext];
        NSEntityDescription *entityDescription = [NSEntityDescription
                                                  entityForName:@"ChatDB" inManagedObjectContext:moc];
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        [request setEntity:entityDescription];
        
        // Set example predicate and sort orderings...
        NSPredicate *predicate = [NSPredicate predicateWithFormat:
                                  @"(username LIKE[c] %@)",stringName];
        [request setPredicate:predicate];
        NSError *error;
        NSArray *array = [moc executeFetchRequest:request error:&error];
        
        if (array == nil)
        {
            // Deal with error...
        }
        else
        {
            for (ChatDB * chatty in array) {
                [self.managedObjectContext deleteObject:chatty];
            }
        }
        
        //[[self managedObjectContext] deleteObject:chat];
        //[[self managedObjectContext] save:nil];
        [self fetchInboxData];
    }
    
}
#pragma mark - Fetched results controller

- (NSFetchedResultsController *)fetchedResultsController
{
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    } else {
        [NSFetchedResultsController deleteCacheWithName:@"InboxList"];
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"ChatDB" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    
    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"username" ascending:YES];
    NSSortDescriptor *sortDateDescriptor = [[NSSortDescriptor alloc] initWithKey:@"dateReceived" ascending:NO];
    NSArray *sortDescriptors = @[sortDescriptor, sortDateDescriptor];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"myusername = %@", [prefs objectForKey:PREF_USERNAME] ];
    [fetchRequest setPredicate:predicate];
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:@"username" cacheName:nil];
    aFetchedResultsController.delegate = self;
    self.fetchedResultsController = aFetchedResultsController;
    
	NSError *error = nil;
	if (![self.fetchedResultsController performFetch:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
	    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
	    abort();
	}
    
    return _fetchedResultsController;
}

#pragma mark - RequestCellDelegate

- (void)performAcceptRequest:(int)rowIndex {
    PFObject *roamersToBeAdded = requestListArray[rowIndex];
    
    // Add to my roamer
    NSMutableArray* myRoamerArray = self.userRoamer[@"MyRoamers"];
    if(myRoamerArray == nil){
        myRoamerArray = [[NSMutableArray alloc] init];
    }
    [myRoamerArray addObject:roamersToBeAdded[@"Username"]];
    self.userRoamer[@"MyRoamers"] = myRoamerArray;
    [self.userRoamer saveInBackground];
    
    // Add to requestor my roamer
    NSMutableArray* reqMyRoamerArray = roamersToBeAdded[@"MyRoamers"];
    if(reqMyRoamerArray == nil){
        reqMyRoamerArray = [[NSMutableArray alloc] init];
    }
    [reqMyRoamerArray addObject:self.userRoamer[@"Username"]];
    roamersToBeAdded[@"MyRoamers"] = reqMyRoamerArray;
    [roamersToBeAdded saveInBackground];

    NSMutableArray* requestArray = self.userRoamer[@"Requests"];
    if(requestArray == nil){
        requestArray = [[NSMutableArray alloc] init];
    }
    [requestArray removeObject:roamersToBeAdded[@"Username"]];
    self.userRoamer[@"Requests"] = requestArray;
    [self.userRoamer saveInBackground];
    
    [self fetchRequest];
    [self.mTableView reloadData];
}

- (void)performDeclineRequest:(int)rowIndex {
    PFObject *roamersToBeDeclined = requestListArray[rowIndex];

    // Add to my roamer
    NSMutableArray* myRoamerHoldArray = self.userRoamer[@"Hold"];
    if(myRoamerHoldArray == nil){
        myRoamerHoldArray = [[NSMutableArray alloc] init];
    }
    [myRoamerHoldArray addObject:roamersToBeDeclined[@"Username"]];
    self.userRoamer[@"Hold"] = myRoamerHoldArray;
    [self.userRoamer saveInBackground];

    NSMutableArray* requestArray = self.userRoamer[@"Requests"];
    if(requestArray == nil){
        requestArray = [[NSMutableArray alloc] init];
    }
    [requestArray removeObject:roamersToBeDeclined[@"Username"]];
    self.userRoamer[@"Requests"] = requestArray;
    [self.userRoamer saveInBackground];
    
    [self fetchRequest];
    [self.mTableView reloadData];
}

#pragma mark - ChatDetailViewControllerDelegate
- (void)backFromChatDetailView:(ChatDetailViewController *)viewCtrl {
    [self dismissViewControllerAnimated:YES completion:^{
        [self fetchInboxData];
    }];
}

#pragma mark - RoamerShortProfileViewCtrlDelegate

- (void)performBackAction:(RoamerShortProfileViewCtrl *)viewCtrl {
    [self dismissViewControllerAnimated:YES completion:^{
    }];
}

#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"performChatDetail"]) {
//        ChatDB *chat = (ChatDB *)[self.fetchedResultsController objectAtIndexPath:currentIndex];
        ChatDetailViewController *detailVC = segue.destinationViewController;
        detailVC.userRoamer = self.userRoamer;
        detailVC.userName = selectedUserName;
        detailVC.delegate = self;
    } else if ([segue.identifier isEqualToString:@"performShowRoamerDetail"]) {
        PFObject *roamers = requestListArray[currentIndex.row];
        RoamerProfileViewCtrl *detailVC = segue.destinationViewController;
        detailVC.currentRoamer = roamers;
        detailVC.hideAddRemoveButton = TRUE;
        detailVC.delegate = self;
    }
}

@end
