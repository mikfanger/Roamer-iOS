//
//  ChatDetailViewController.m
//  Roamer
//
//  Created by Rajesh Mehta on 6/26/14.
//
//

#import "ChatDetailViewController.h"
#import "AppDelegate.h"
#import "ChatDB.h"
#import "ChatTextTableViewCell.h"
#import "MyAppConstants.h"
#import "UserProfileHelper.h"

@interface ChatDetailViewController ()

@end

@implementation ChatDetailViewController

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

    self.managedObjectContext = [[AppDelegate sharedDelegate] managedObjectContext];

    UIToolbar* numberToolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, 320, 50)];
    numberToolbar.barStyle = UIBarStyleBlackTranslucent;
    numberToolbar.items = [NSArray arrayWithObjects:
                            [[UIBarButtonItem alloc]initWithTitle:@"Close" style:UIBarButtonItemStyleDone target:self action:@selector(doneWithNumberPad)],
                            [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                            //                           [[UIBarButtonItem alloc]initWithTitle:@"" style:UIBarButtonItemStyleBordered target:self action:@selector(cancelNumberPad)],
                            nil];
    [numberToolbar sizeToFit];
    
    self.mMsgTextField.delegate = self;

    self.mMsgTextField.inputAccessoryView = numberToolbar;
    
    [UserProfileHelper setChatToAllRead:self.userName];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self showAllChats];
    
}

- (void) notificationToRefresh: (NSNotification* )note
{
    NSDictionary *dict = [note userInfo];
    NSString* fromUser = [dict valueForKey:@"from"];
    
    if([self.userName isEqualToString:fromUser]) {
        [UserProfileHelper setChatToAllRead:self.userName];
        [self fetchChatData];
    }
}

-(void)doneWithNumberPad{
    [self.mMsgTextField resignFirstResponder];

    [self.mScrollView  setContentOffset: CGPointMake(0, 0) animated:YES];
}

- (void) showAllChats {
    [self fetchChatData];
}

- (void) fetchChatData{
    [NSFetchedResultsController deleteCacheWithName:@"ChatList"];
    _fetchedResultsController = nil;
    [self.mTableView reloadData];
    
    id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][0];
    NSInteger count = [sectionInfo numberOfObjects];
    if(count > 0){
        [self.mTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:count-1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
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

- (IBAction)onSendAction:(id)sender {
    NSString* msg = self.mMsgTextField.text;
    if([msg isEqualToString:@""])
        return;
    
    self.mMsgTextField.text = @"";
    [UserProfileHelper addChat:self.userName message:msg type:IT_IS_MY_CHAT isViewed:MSG_IS_VIEWED dateReceived:[NSDate date]];
    [self sendNotification:msg];
    [self.mMsgTextField resignFirstResponder];
    [self.mScrollView  setContentOffset: CGPointMake(0, 0) animated:YES];
    [self fetchChatData];
}

- (void) sendNotification:(NSString *)message {
    NSInteger length = [message length];
    if(length < 150){
        NSDictionary *data = [NSDictionary dictionaryWithObjectsAndKeys:
                              message, @"alert",
                              self.userRoamer[@"Username"], @"from",
                              @"Increment", @"badge",
                              @"UPDATE_STATUS", @"action",
                              nil];
        
        PFPush *push = [[PFPush alloc] init];
        [push setChannel:self.userName];
        [push setData:data];
        [push sendPushInBackground];
    } else {
        NSString* newMessage = message;
        BOOL done = false;
        do {
            NSString* shortMessage = @"";
            if([newMessage length] > 150) {
                shortMessage = [newMessage substringToIndex:150];
                newMessage = [newMessage substringFromIndex:150];
            } else {
                shortMessage = newMessage;
                done = true;
            }
            NSDictionary *data = [NSDictionary dictionaryWithObjectsAndKeys:
                                  shortMessage, @"alert",
                                  self.userRoamer[@"Username"], @"from",
                                  @"Increment", @"badge",
                                  @"UPDATE_STATUS", @"action",
                                  nil];
            
            PFPush *push = [[PFPush alloc] init];
            [push setChannel:self.userName];
            [push setData:data];
            [push sendPushInBackground];
        } while(!done);
    }
}

- (IBAction)onBackAction:(id)sender {
    [self.delegate backFromChatDetailView:self];
}

-(float) getTextHeigth:(NSString *) text{
    if (text.length==0) {
        return 46.0f;
    }
/*    CGSize constSize=CGSizeMake(280, MAXFLOAT);
    NSData *data = [text dataUsingEncoding:NSUTF8StringEncoding];
    NSString *goodValue = [[NSString alloc] initWithData:data encoding:NSNonLossyASCIIStringEncoding];
    //    CGSize size=[goodValue sizeWithFont:[UIFont fontWithName:@"Arial" size:12] constrainedToSize:constSize lineBreakMode:UILineBreakModeWordWrap];
    UILabel *calculationView = [[UILabel alloc] init];
    [calculationView setText:goodValue];
    CGSize size = [calculationView sizeThatFits:constSize]; */

    CGSize constSize=CGSizeMake(280, MAXFLOAT);
    NSData *data = [text dataUsingEncoding:NSUTF8StringEncoding];
    NSString *goodValue = [[NSString alloc] initWithData:data encoding:NSNonLossyASCIIStringEncoding];
    CGSize size=[goodValue sizeWithFont:[UIFont fontWithName:@"Arial" size:16] constrainedToSize:constSize lineBreakMode:  NSLineBreakByWordWrapping];
    
    return size.height+28;
    
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [[self.fetchedResultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][section];
    NSInteger count = [sectionInfo numberOfObjects];
    return count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    ChatDB *chat = (ChatDB *)[self.fetchedResultsController objectAtIndexPath:indexPath];
    return [self getTextHeigth:chat.message];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *CellIdentifier = @"ChatTextTableViewCell";
    ChatTextTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    ChatDB *chat = (ChatDB *)[self.fetchedResultsController objectAtIndexPath:indexPath];

    [cell initWithMessage:chat.message];
    
    int chatType = [chat.type intValue];
    if(chatType == IT_IS_MY_CHAT){
        cell.mUserNameLabel.text = @"ME:"; //roamers.name;
        cell.mUserNameLabel.textColor = [UIColor colorWithRed:236.0f/255.0f green:61.0f/255.0f blue:53.0f/255.0f alpha:1.0f];
    } else {
        cell.mUserNameLabel.text = chat.username; //roamers.name;
    }
    
    cell.mMsgLabel.text = chat.message;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - Fetched results controller

- (NSFetchedResultsController *)fetchedResultsController
{
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    } else {
        [NSFetchedResultsController deleteCacheWithName:@"ChatList"];
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"ChatDB" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    
    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDateDescriptor = [[NSSortDescriptor alloc] initWithKey:@"dateReceived" ascending:YES];
    NSArray *sortDescriptors = @[sortDateDescriptor];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"username = %@ AND myusername = %@", self.userName, [prefs objectForKey:PREF_USERNAME] ];
    [fetchRequest setPredicate:predicate];

    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
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

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    
    if (textField == self.mMsgTextField) {
        [self.mScrollView setContentOffset: CGPointMake(0, 300) animated:YES];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    [self.mScrollView setContentOffset: CGPointMake(0, 0) animated:YES];
    return YES;
}

@end
