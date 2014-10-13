//
//  ShowEventsViewCntrl.m
//  Roamer
//
//  Created by Mac Home on 4/10/14.
//
//

#import "ShowEventsViewCntrl.h"
#import "EventsCell.h"
#import "MyAppConstants.h"
#import "DataSource.h"
#import "AppDelegate.h"

#define  SORT_OPTION_TYPE       1
#define  SORT_OPTION_TIME       2
#define  SORT_OPTION_DATE       3


@interface ShowEventsViewCntrl () {
    NSMutableArray *origEventsArray;
    NSMutableArray *eventsArray;
    NSIndexPath *currentIndex;
    int currentEventType;
    NSArray *eventTypeArray;
    NSArray *eventTimeArray;

    CGRect  sortSelectRect;
    CGRect  sortSelectRectHidden;
    NSPredicate* currentPredicate;
    BOOL fromSelectSort;
    
    int timeSort;
    int typeSort;
    NSDate *sortStartDate;
    NSDate *sortEndDate;
}

@end

@implementation ShowEventsViewCntrl

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
    currentEventType = SHOW_ALL_EVENTS;
    eventTypeArray = [DataSource EventPostingList];
    eventTimeArray = [DataSource EventTimeList];

	// Do any additional setup after loading the view.

    [self.mMyEventsTitleLabel setFont:[UIFont fontWithName:@"Eurostile-Bold" size:18.0]];
    [self.mAllEventsTitleLabel setFont:[UIFont fontWithName:@"Eurostile-Bold" size:18.0]];

    eventsArray = [[NSMutableArray alloc] init];
    origEventsArray = [[NSMutableArray alloc] init];

    sortSelectRect = self.mSortSelectView.frame;
    sortSelectRectHidden = CGRectMake(0 - sortSelectRect.size.width - 5, sortSelectRect.origin.y, sortSelectRect.size.width, sortSelectRect.size.height);
    self.mSortSelectView.frame = sortSelectRectHidden;
    currentPredicate = nil;
    self.mSortDateLabel.text = @"";
    self.mSortTimeLabel.text = @"";
    self.mSortTypeLabel.text = @"";
    fromSelectSort = FALSE;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if(!fromSelectSort){
        currentPredicate = nil;
        self.mSortDateLabel.text = @"";
        self.mSortTimeLabel.text = @"";
        self.mSortTypeLabel.text = @"";
        timeSort = -1;
        typeSort = -1;
        sortStartDate = nil;
        sortEndDate = nil;

    if(currentEventType == SHOW_ALL_EVENTS)
        [self showAllEvents];
    else
        [self showMyEvents];
        
    }
}

- (void) fetchEventsFromDB{
    
    PFQuery *query = [PFQuery queryWithClassName:@"Event"];
    if(currentEventType == SHOW_MY_EVENTS){
//        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
//        NSString* objId =  [prefs objectForKey:PREF_USER_OBJECT_ID];
        [query whereKey:@"Attendees" equalTo:self.userRoamer[@"Username"]];
    } else {
        NSUserDefaults* pref = [NSUserDefaults standardUserDefaults];
        int locInt = (int)[pref integerForKey:PREF_CURRENT_LOC_INT];
        [query whereKey:@"Location" equalTo:[NSNumber numberWithInt:locInt]];
        
    }
    [query orderByAscending:@"Date"];
    [query whereKey:@"Date" greaterThan:[self getDateWithTime:[NSDate date] hour:0 min:0 second:0]];
    query.limit = 1000;
    [[AppDelegate sharedDelegate] showFetchAlert];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        [[AppDelegate sharedDelegate] dissmissFetchAlert];
        if (!error) {
            [origEventsArray removeAllObjects];
            [origEventsArray addObjectsFromArray:objects];
            NSLog(@"Successfully retrieved %d roamers.", (int)objects.count);
            [self performDataLoadComplete];
        } else {
            // Log details of the failure
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
        [self performDataLoadComplete];
    }];
    //    [NSFetchedResultsController deleteCacheWithName:@"FindRoamers"];
    //    _fetchedResultsController = nil;
    
}

- (void) performDataLoadComplete {
    if(currentPredicate != nil){
        [eventsArray removeAllObjects];
        [eventsArray addObjectsFromArray:[origEventsArray filteredArrayUsingPredicate:currentPredicate]];
    } else {
        [eventsArray removeAllObjects];
        [eventsArray addObjectsFromArray:origEventsArray];
    }
    [self.mTableView reloadData];
}

- (void) showMyEvents {
    currentEventType = SHOW_MY_EVENTS;
    self.mMyEventsTitleLabel.textColor = [UIColor whiteColor];
    self.mMyEventsView.backgroundColor = [UIColor colorWithRed:49.0f/255.0f green:50.0f/255.0f blue:52.0f/255.0f alpha:1.0f];
    
    self.mAllEventsTitleLabel.textColor = [UIColor colorWithRed:99.0f/255.0f green:99.0f/255.0f blue:99.0f/255.0f alpha:1.0f];
    self.mAllEventsView.backgroundColor = [UIColor colorWithRed:38.0f/255.0f green:38.0f/255.0f blue:38.0f/255.0f alpha:1.0f];

    [self fetchEventsFromDB];
}

- (void) showAllEvents {
    currentEventType = SHOW_ALL_EVENTS;
    self.mAllEventsTitleLabel.textColor = [UIColor whiteColor];
    self.mAllEventsView.backgroundColor = [UIColor colorWithRed:49.0f/255.0f green:50.0f/255.0f blue:52.0f/255.0f alpha:1.0f];
    
    self.mMyEventsTitleLabel.textColor = [UIColor colorWithRed:99.0f/255.0f green:99.0f/255.0f blue:99.0f/255.0f alpha:1.0f];
    self.mMyEventsView.backgroundColor = [UIColor colorWithRed:38.0f/255.0f green:38.0f/255.0f blue:38.0f/255.0f alpha:1.0f];
    
    [self fetchEventsFromDB];
}

- (IBAction)onMyEventsAction:(id)sender {
    currentPredicate = nil;
    [self showMyEvents];
}

- (IBAction)onAllEventsAction:(id)sender {
    currentPredicate = nil;
    [self showAllEvents];
}

- (IBAction)onBackAction:(id)sender {
    [self.delegate backFromShowEventsView:self];
}

- (IBAction)onSortAction:(id)sender {
    self.mSortDateLabel.text = @"";
    self.mSortTimeLabel.text = @"";
    self.mSortTypeLabel.text = @"";
    timeSort = -1;
    typeSort = -1;
    sortStartDate = nil;
    sortEndDate = nil;
    currentPredicate = nil;
    [self slideInLocViewAnimation];
}

- (IBAction)onBackFromSortAction:(id)sender {
    self.mSortDateLabel.text = @"";
    self.mSortTimeLabel.text = @"";
    self.mSortTypeLabel.text = @"";
    timeSort = -1;
    typeSort = -1;
    sortStartDate = nil;
    sortEndDate = nil;
    currentPredicate = nil;
    [self slideOutLocViewAnimation];
}
- (IBAction)onSortByDateAction:(id)sender {
    fromSelectSort = TRUE;
    [self performSegueWithIdentifier:@"performSortDateSelector" sender:self];
}

- (IBAction)onSortByTimeAction:(id)sender {
    UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                  initWithTitle:@"Select Time"
                                  delegate:self
                                  cancelButtonTitle:nil
                                  destructiveButtonTitle:nil
                                  otherButtonTitles:nil];
    

//    UIActionSheet *alertView = [[UIActionSheet alloc] initWithTitle:
//                                                        message:@""
//                                                       delegate:self
//                                              cancelButtonTitle:
//                                              otherButtonTitles:nil];
    actionSheet.tag = SORT_OPTION_TIME;
    for(NSDictionary* dict in eventTimeArray) {
        NSString *str = dict[@"name"];
        [actionSheet addButtonWithTitle:str];
    }
    [actionSheet addButtonWithTitle:@"Cancel"];
    actionSheet.cancelButtonIndex = [eventTimeArray count];

    [actionSheet showInView:self.view];
}

- (IBAction)onSortByTypeAction:(id)sender {
    UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                  initWithTitle:@"Select Time"
                                  delegate:self
                                  cancelButtonTitle:nil
                                  destructiveButtonTitle:nil
                                  otherButtonTitles:nil];
//    UIActionSheet *alertView = [[UIAlertView alloc] initWithTitle:@"Select Type"
//                                                        message:@""
//                                                       delegate:self
//                                              cancelButtonTitle:@"Cancel"
//                                              otherButtonTitles:nil];
    actionSheet.tag = SORT_OPTION_TYPE;
    for(NSDictionary* dict in eventTypeArray) {
        NSString *str = dict[@"name"];
        [actionSheet addButtonWithTitle:str];
    }
    [actionSheet addButtonWithTitle:@"Cancel"];
    actionSheet.cancelButtonIndex = [eventTypeArray count];
    [actionSheet showInView:self.view];
}

//- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
-(void)actionSheet:(UIActionSheet *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(alertView.tag == SORT_OPTION_TYPE) {
        if (buttonIndex != alertView.cancelButtonIndex) {
            int index = (int)buttonIndex + 1;
            [self performTypeSort:index];
        }
    } else if(alertView.tag == SORT_OPTION_TIME) {
        if (buttonIndex != alertView.cancelButtonIndex) {
            int index = (int)buttonIndex + 1;
            [self performTimeSort:index];
        }
    }
}

- (void) performTimeSort:(int) index {
    timeSort = index;
//    self.mSortDateLabel.text = @"";
    self.mSortTimeLabel.text = [self getEventTimeFromInt:index];
//    self.mSortTypeLabel.text = @"";
    currentPredicate = [NSPredicate predicateWithFormat:@"(Time = %d)", index];
}

- (void) performTypeSort:(int) index {
    typeSort = index;
//    self.mSortDateLabel.text = @"";
//    self.mSortTimeLabel.text = @"";
    self.mSortTypeLabel.text = [self getEventFromInt:index];
    currentPredicate = [NSPredicate predicateWithFormat:@"(Type = %d)", index];
}

- (IBAction)onPerformSortAction:(id)sender {
    [self slideOutLocViewAnimation];
    if((timeSort != -1) && (typeSort != -1) && (sortStartDate != nil)){
        currentPredicate = [NSPredicate predicateWithFormat:@"(Time = %d) AND (Type = %d) AND (Date >= %@) AND (Date =< %@)", timeSort, typeSort, sortStartDate, sortEndDate];
    } else if((timeSort != -1) && (typeSort != -1) && (sortStartDate == nil)){
        currentPredicate = [NSPredicate predicateWithFormat:@"(Time = %d) AND (Type = %d)", timeSort, typeSort];
    } else if((timeSort != -1) && (typeSort == -1) && (sortStartDate != nil)){
        currentPredicate = [NSPredicate predicateWithFormat:@"(Time = %d) AND (Date >= %@) AND (Date =< %@)", timeSort, sortStartDate, sortEndDate];
    } else if((timeSort == -1) && (typeSort != -1) && (sortStartDate != nil)){
        currentPredicate = [NSPredicate predicateWithFormat:@"(Type = %d) AND (Date >= %@) AND (Date =< %@)", typeSort, sortStartDate, sortEndDate];
    } else if((timeSort != -1) && (typeSort == -1) && (sortStartDate == nil)){
        currentPredicate = [NSPredicate predicateWithFormat:@"(Time = %d)", timeSort];
    } else if((timeSort == -1) && (typeSort != -1) && (sortStartDate == nil)){
        currentPredicate = [NSPredicate predicateWithFormat:@"(Type = %d)", typeSort];
    } else if((timeSort == -1) && (typeSort == -1) && (sortStartDate != nil)){
        currentPredicate = [NSPredicate predicateWithFormat:@"(Date >= %@) AND (Date =< %@)", sortStartDate, sortEndDate];
    } else if((timeSort == -1) && (typeSort == -1) && (sortStartDate == nil)){
        currentPredicate = nil;
    }
    
    
    [self performDataLoadComplete];
}

- (void) slideInLocViewAnimation {
    self.mSortSelectView.frame = sortSelectRectHidden;
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:0.6f];
    self.mSortSelectView.frame = sortSelectRect;
	[UIView commitAnimations];
}

- (void) slideOutLocViewAnimation {
    self.mSortSelectView.frame = sortSelectRect;
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:0.6f];
    self.mSortSelectView.frame = sortSelectRectHidden;
	[UIView commitAnimations];
}

- (NSString *) getEventTimeFromInt:(int)val {
    NSString* str = @"";
    for(NSDictionary* dict in eventTimeArray) {
        if(val == [dict[@"value"] intValue]){
            str = dict[@"name"];
            break;
        }
    }
    return str;
}

- (NSString *) getEventFromInt:(int)val {
    NSString* str = @"";
    for(NSDictionary* dict in eventTypeArray) {
        if(val == [dict[@"value"] intValue]){
            str = dict[@"name"];
            break;
        }
    }
    return str;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [eventsArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *CellIdentifier = @"EventsCell";
    EventsCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    PFObject *roamers = eventsArray[indexPath.row];
    
    cell.mBkgView.layer.cornerRadius = 8.0; // half height & width
/*    [cell.mEventNameLabel setFont:[UIFont fontWithName:@"Eurostile-Bold" size:14.0]];
    [cell.mEventDescriptionLabel setFont:[UIFont fontWithName:@"CenturyGothic" size:8.0]];
    [cell.mEventDateLabel setFont:[UIFont fontWithName:@"Eurostile-Bold" size:13.0]];
    [cell.mUserNameLabel setFont:[UIFont fontWithName:@"Eurostile-Bold" size:13.0]];
    [cell.mEventAttendeeCountLabel setFont:[UIFont fontWithName:@"Eurostile-Bold" size:13.0]];
    [cell.mEventLocationLabel setFont:[UIFont fontWithName:@"Eurostile-Bold" size:20.0]];
    [cell.mEventDescriptionLabel setFont:[UIFont fontWithName:@"Eurostile-Bold" size:13.0]];
    [cell.mAttendingTitle setFont:[UIFont fontWithName:@"Eurostile-Bold" size:14.0]];
    [cell.mLocationTitle setFont:[UIFont fontWithName:@"Eurostile-Bold" size:14.0]]; */
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateStyle:NSDateFormatterShortStyle];
    [dateFormat setTimeStyle:NSDateFormatterNoStyle];

    cell.mEventNameLabel.text = [self getEventFromInt:[roamers[@"Type"] intValue]]; //roamers.location;
    cell.mEventDateLabel.text = [dateFormat stringFromDate:roamers[@"Date"]]; //roamers.name;
    cell.mUserNameLabel.text = roamers[@"Host"]; //roamers.name;
    cell.mEventAttendeeCountLabel.text = [roamers[@"Attend"] stringValue]; //roamers.name;
    cell.mEventLocationLabel.text = roamers[@"Place"]; //roamers.name;
    cell.mEventDescriptionLabel.text = roamers[@"Desc"]; //roamers.name;

    //    cell.mProfileImg.image = roamers.image;
    cell.mProfileImgView.layer.masksToBounds = YES;
    cell.mProfileImgView.layer.cornerRadius = 8.0; // half height & width
    
    
    PFFile *userImageFile = roamers[@"Pic"];
    if([self checkForNull:userImageFile] == nil) {
        cell.mProfileImgView.image = [UIImage imageNamed:@"default_userpic.png"];
    } else {
        [userImageFile getDataInBackgroundWithBlock:^(NSData *imageData, NSError *error) {
            if (!error) {
                UIImage *image = [UIImage imageWithData:imageData];
                cell.mProfileImgView.image = image;
            }
        }];
    }
    return cell;
}

- (id) checkForNull:(id)obj {
    if([obj isKindOfClass:[NSNull class]])
        return nil;
    
    return obj;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    currentIndex = indexPath;
    [self performSegueWithIdentifier:@"performEventDetail" sender:self];
}

#pragma mark- SortDateSelectorViewCtrlDelegate

- (void)cancelSortDateSelectorView:(SortDateSelectorViewCtrl *)viewCtrl {
    [self dismissViewControllerAnimated:NO completion:^{
        fromSelectSort = FALSE;
    }];
}

- (void)selectSortDateSelectorView:(SortDateSelectorViewCtrl *)viewCtrl startDate:(NSDate *)startDate endDate:(NSDate *)endDate {
    [self dismissViewControllerAnimated:NO completion:^{
        fromSelectSort = FALSE;
        NSDate * newstartDate = [self getDateWithTime:startDate hour:0 min:0 second:0];
        NSDate * newEndDate = [self getDateWithTime:endDate hour:23 min:59 second:59];
        
        NSDateFormatter *monDateFormatter = [[NSDateFormatter alloc] init];
        [monDateFormatter setDateStyle:NSDateFormatterShortStyle];
        
        self.mSortDateLabel.text = [NSString stringWithFormat:@"Start:%@ to End:%@",[monDateFormatter stringFromDate:newstartDate],[monDateFormatter stringFromDate:newEndDate]];
//        self.mSortTimeLabel.text = @"";
//        self.mSortTypeLabel.text = @"";
        sortStartDate = newstartDate;
        sortEndDate = newEndDate;
//        currentPredicate = [NSPredicate predicateWithFormat:@"(date >= %@) AND (date =< %@)", newstartDate, newEndDate];
    }];
}

- (NSDate *) getDateWithTime:(NSDate *)nowDt hour:(int)hour min:(int)min second:(int)second {
    //gather current calendar
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    //gather date components from date
    NSDateComponents *dateComponents = [calendar components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) fromDate:nowDt];
    
    //set date components
    [dateComponents setHour:hour];
    [dateComponents setMinute:min];
    [dateComponents setSecond:second];
    
    //return date relative from date
    return [calendar dateFromComponents:dateComponents];
}

#pragma mark- EventDetailViewCntrlDelegate

- (void)backFromEventsDetailView:(EventDetailViewCntrl *)viewCtrl {
    [self dismissViewControllerAnimated:NO completion:^{
        [[AppDelegate sharedDelegate] dissmissFetchAlert];
        [self fetchEventsFromDB];
    }];
}

#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"peformSetting"]) {
    } else if ([segue.identifier isEqualToString:@"performSortDateSelector"]) {
        SortDateSelectorViewCtrl *detailVC = segue.destinationViewController;
        detailVC.delegate = self;
    } else if ([segue.identifier isEqualToString:@"performEventDetail"]) {
        PFObject *event = eventsArray[currentIndex.row];
        EventDetailViewCntrl *detailVC = segue.destinationViewController;
        detailVC.currentEvent = event;
        detailVC.userRoamer = self.userRoamer;
        detailVC.delegate = self;
        detailVC.currentEventType = currentEventType;
    }
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

@end
