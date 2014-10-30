//
//  PostEventViewController.m
//  Roamer
//
//  Created by Mac Home on 6/6/14.
//
//

#import "PostEventViewController.h"
#import <EventKit/EventKit.h>
#import "DataSource.h"
#import "MyAppConstants.h"
#import "UserProfileHelper.h"
#import "AppDelegate.h"

#define TIME_SELECT                 1
#define TYPE_SELECT                    2

@interface PostEventViewController () {
    NSArray *typeArray;
    NSArray *timeArray;
    NSDateFormatter *monDateFormatter;
    int currentButton;
    int typeInt;
    int timeInt;

    CGRect  viewSelectRect;
    CGRect  viewSelectRectHidden;
    
    NSDate* selectedEventDate;
    NSString *savedEventId;
}

@end

@implementation PostEventViewController

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
    // Do any additional setup after loading the view.
    NSUserDefaults* pref = [NSUserDefaults standardUserDefaults];
    PFQuery *query = [PFQuery queryWithClassName:@"Cities"];
    [query whereKey:@"Name" equalTo:[pref stringForKey:PREF_CURRENT_LOC_STRING]];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error){
            
            PFObject *object  = (PFObject*)objects[0];
            NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
            
            PFGeoPoint *geoPoint = object[@"LatLong"];
            [prefs setDouble:geoPoint.latitude forKey:PREF_CURRENT_LOC_GEO_LAT];
            [prefs setDouble:geoPoint.longitude forKey:PREF_CURRENT_LOC_GEO_LONG];
            [prefs synchronize];
        }
        else{
            
        }
    }];
    
    
    typeArray = [[NSMutableArray alloc] init];
    timeArray = [[NSMutableArray alloc] init];

    typeArray = [DataSource EventPostingList];
    timeArray = [DataSource EventTimeList];

    if(monDateFormatter == nil) {
        monDateFormatter = [[NSDateFormatter alloc] init];
        [monDateFormatter setDateStyle:NSDateFormatterShortStyle];
        //        [monDateFormatter setDateFormat:@"mm/dd/yyyy"];
    }

    self.mTypeLabel.text = typeArray[0][@"name"];
    typeInt = [typeArray[0][@"value"] intValue] ;
    self.mTimeLabel.text = timeArray[0][@"name"];
    timeInt = [timeArray[0][@"value"] intValue];
    self.mDateLabel.text = [monDateFormatter stringFromDate:[NSDate date]];
    self.mAddressLabel.text = @"";
    selectedEventDate = [NSDate date];

    viewSelectRect = self.mSelectView.frame;
    viewSelectRectHidden = CGRectMake(0, viewSelectRect.origin.y + viewSelectRect.size.height + 30, viewSelectRect.size.width, viewSelectRect.size.height);
    self.mSelectView.frame = viewSelectRectHidden;

    self.mCommentText.delegate = self;

    UIToolbar* numberToolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, 320, 50)];
    numberToolbar.barStyle = UIBarStyleBlackTranslucent;
    numberToolbar.items = [NSArray arrayWithObjects:
                            [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                            [[UIBarButtonItem alloc]initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(doneWithNumberPad)],
                            
                            //                           [[UIBarButtonItem alloc]initWithTitle:@"" style:UIBarButtonItemStyleBordered target:self action:@selector(cancelNumberPad)],
                            nil];
    [numberToolbar sizeToFit];
    self.mCommentText.inputAccessoryView = numberToolbar;
}

-(void)doneWithNumberPad{
    [self.mCommentText resignFirstResponder];
    
    [self.mScrollView setContentOffset: CGPointMake(0, 0) animated:YES];
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

- (IBAction)onPostAction:(id)sender {
    if ([self.mAddressLabel.text isEqualToString:@""]) {
        [self showAlertMessage:@"Error!" message:@"Please select address."];
        return;
    }
    
    if ([self.mCommentText.text isEqualToString:@""]) {
        [self showAlertMessage:@"Error!" message:@"Please enter comment."];
        return;
    }

    
    [[AppDelegate sharedDelegate] showFetchAlert];
    savedEventId = @"";
    EKEventStore *store = [[EKEventStore alloc] init];
    [store requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error) {
        [[AppDelegate sharedDelegate] dissmissFetchAlert];
        if (!granted) {
            NSString *loginsaved = @"Your calendar did not grant you access!";
            NSLog(@"%@", loginsaved );
        } else {
            EKEvent *event = [EKEvent eventWithEventStore:store];
            event.title = @"Roamer Event";
            event.notes = self.mAddressLabel.text;
            NSArray* times = [self getStartEndTime:selectedEventDate];
            event.startDate = times[0]; //today
            event.endDate = times[1];  //set 1 hour meeting
            [event setCalendar:[store defaultCalendarForNewEvents]];
            NSError *err = nil;
            [store saveEvent:event span:EKSpanThisEvent commit:YES error:&err];
            savedEventId = event.eventIdentifier;  //this is so you can access this event later
        }
        [self saveEventToParse];
    }];
}

- (void) saveEventToParse {
    NSUserDefaults* pref = [NSUserDefaults standardUserDefaults];
    
    PFObject *event = [PFObject objectWithClassName:@"Event"];
    event[@"Date"] = selectedEventDate;
    event[@"Time"] = [NSNumber numberWithInt:timeInt];
    event[@"Location"] = [NSNumber numberWithInt:(int)[pref integerForKey:PREF_CURRENT_LOC_INT]];
    event[@"Host"] = self.userRoamer[@"Username"];
    event[@"Place"] = self.mAddressLabel.text;
    event[@"Attend"] = [NSNumber numberWithInt:1];
    NSMutableArray *array = [[NSMutableArray alloc] init];
    [array addObject:self.userRoamer[@"Username"]];
    event[@"Attendees"] = array;
    event[@"Desc"] = self.mCommentText.text;
    event[@"Type"] = [NSNumber numberWithInt:typeInt];
    if([self checkForNull:self.userRoamer[@"Pic"]] != nil)
        event[@"Pic"] = self.userRoamer[@"Pic"];
    
    [[AppDelegate sharedDelegate] showFetchAlert];
    [event saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        [[AppDelegate sharedDelegate] dissmissFetchAlert];
        if (!error) {
            [UserProfileHelper cacheAddEvent:savedEventId objectId:event.objectId ];
            UIAlertView *anAlert=[[UIAlertView alloc] initWithTitle:@"All done!" message:@"Event created successfully." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [anAlert setTag:100];
            [anAlert show];
            
        } else {
            [self showAlertMessage:@"Error!" message:@"Error Creating User."];
        }
    }];
}


- (id) checkForNull:(id)obj {
    if([obj isKindOfClass:[NSNull class]])
        return nil;
    
    return obj;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    [self.delegate backFromPostEventsView:self];
}

- (NSArray *) getStartEndTime:(NSDate *)nowDate {
    NSCalendar * calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    unsigned unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit;
    NSDateComponents *comps = [calendar components:unitFlags fromDate:nowDate];
    
    int hour, min, sec;
    if(timeInt == 1){
        hour = 6; min = 0; sec = 0;
    } else if(timeInt == 2){
        hour = 11; min = 30; sec = 0;
    } else if(timeInt == 3){
        hour = 17; min = 30; sec = 0;
    } else if(timeInt == 4){
        hour = 20; min = 30; sec = 0;
    } else {
        hour = 22; min = 30; sec = 0;
    }
    NSDate * startTime = [self getDateWithTime:nowDate hour:hour min:min second:sec];
    

    int timeInterval;
    if(timeInt == 1){
        timeInterval = 60 * (60 + 60 + 60 + 60 + 60 + 30);
    } else if(timeInt == 2){
        timeInterval = 60 * (60 + 60);
    } else if(timeInt == 3){
        timeInterval = 60 * (60 + 60);
    } else if(timeInt == 4){
        timeInterval = 60 * (60 + 60);
    } else {
        timeInterval = 60 * (30 + 60 + 60 + 60 + 60 + 60 + 60 + 60);
    }
    NSDate * endTime = [nowDate dateByAddingTimeInterval:timeInterval];
    
    NSArray* returnArray = @[startTime, endTime];
    return returnArray;
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

- (void) showAlertMessage:(NSString *)title message:(NSString *)msg {
    UIAlertView *errorAlert = [[UIAlertView alloc]
                               initWithTitle:title message:msg delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [errorAlert show];
}

- (IBAction)onBackAction:(id)sender {
    [self.delegate backFromPostEventsView:self];
}

- (IBAction)onSelectTypeAction:(id)sender {
    currentButton = TYPE_SELECT;
    [self.mSelectViewTable reloadData];
    [self slideInLocViewAnimation];
}

- (IBAction)onSelectDateAction:(id)sender {
    [self performSegueWithIdentifier:@"selectEventDate" sender:self];
}

- (IBAction)onSelectTimeAction:(id)sender {
    currentButton = TIME_SELECT;
    [self.mSelectViewTable reloadData];
    [self slideInLocViewAnimation];
}

- (IBAction)onSelectMapAction:(id)sender {
    [self performSegueWithIdentifier:@"showMapView" sender:self];
}

- (void) slideInLocViewAnimation {
    if(currentButton == TIME_SELECT){
        self.mSelectViewLabel.text = @"Select Time";
    } else if(currentButton == TYPE_SELECT){
        self.mSelectViewLabel.text = @"Select Type";
    }
    self.mSelectView.frame = viewSelectRectHidden;
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:0.6f];
    self.mSelectView.frame = viewSelectRect;
	[UIView commitAnimations];
}

- (void) slideOutLocViewAnimation {
    self.mSelectView.frame = viewSelectRect;
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:0.6f];
    self.mSelectView.frame = viewSelectRectHidden;
	[UIView commitAnimations];
}


#pragma mark - UITextFieldDelegate
-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    if (textField==self.mCommentText) {
        if (textField.text.length==40) {
            if (string.length!=0) {
                return NO;
            }
        }
        return YES;
    }
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    if (textField == self.mCommentText) {
        [self.mScrollView setContentOffset: CGPointMake(0, 100) animated:YES];
    }
    
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    [self.mScrollView setContentOffset: CGPointMake(0, 0) animated:YES];
    return YES;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if(currentButton == TIME_SELECT){
        return [timeArray count];
    } else if(currentButton == TYPE_SELECT) {
        return [typeArray count];
    }
    return [typeArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"DataCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    if(currentButton == TIME_SELECT){
        cell.textLabel.text = timeArray[indexPath.row][@"name"];
    } else if(currentButton == TYPE_SELECT) {
        cell.textLabel.text = typeArray[indexPath.row][@"name"];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if(currentButton == TIME_SELECT){
        self.mTimeLabel.text = timeArray[indexPath.row][@"name"];
        timeInt = [timeArray[indexPath.row][@"value"] intValue];
    } else if(currentButton == TYPE_SELECT) {
        self.mTypeLabel.text = typeArray[indexPath.row][@"name"];
        typeInt = [typeArray[indexPath.row][@"value"] intValue];
    }
    [self slideOutLocViewAnimation];
}

#pragma mark - PostEventViewControllerDelegate
- (void)cancelMyMapViewSelectorView:(MyMapViewController *)viewCtrl {
    [self dismissViewControllerAnimated:YES completion:^{
    }];
}

- (void)selectMyMapViewSelectorView:(MyMapViewController *)viewCtrl name:(NSString *)name address:(NSString *)address{
    [self dismissViewControllerAnimated:YES completion:^{
        self.mAddressLabel.text = [NSString stringWithFormat:@"%@ : %@", name, address];
    }];    
}

#pragma mark - EventDateSelectorViewCtrlDelegate
- (void)cancelEventDateSelectorView:(EventDateSelectorViewCtrl *)viewCtrl {
    [self dismissViewControllerAnimated:YES completion:^{
    }];
}

- (void)selectEventDateSelectorView:(EventDateSelectorViewCtrl *)viewCtrl eventDate:(NSDate *)eventDate {
    [self dismissViewControllerAnimated:YES completion:^{
        if(monDateFormatter == nil) {
            monDateFormatter = [[NSDateFormatter alloc] init];
            [monDateFormatter setDateStyle:NSDateFormatterShortStyle];
            //        [monDateFormatter setDateFormat:@"mm/dd/yyyy"];
        }
        selectedEventDate = eventDate;
        self.mDateLabel.text = [monDateFormatter stringFromDate:eventDate];
    }];
}

#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"selectEventDate"]) {
        EventDateSelectorViewCtrl *detailVC = segue.destinationViewController;
        detailVC.delegate = self;
    } else if ([segue.identifier isEqualToString:@"showMapView"]) {
        MyMapViewController *detailVC = segue.destinationViewController;
        detailVC.delegate = self;
    }
}

@end
