//
//  EventDetailViewCntrl.m
//  Roamer
//
//  Created by Mac Home on 4/15/14.
//
//

#import "EventDetailViewCntrl.h"
#import <EventKit/EventKit.h>
#import "MyAppConstants.h"
#import "DataSource.h"
#import "UserProfileHelper.h"
#import "AppDelegate.h"

@interface EventDetailViewCntrl () {
    int eventType;
    NSArray *eventTypeArray;
    NSArray *timeArray;
}

@end

@implementation EventDetailViewCntrl

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
    eventTypeArray = [DataSource EventPostingList];
    timeArray = [[NSMutableArray alloc] init];
    timeArray = [DataSource EventTimeList];

    
	// Do any additional setup after loading the view.
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
//    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
//    NSString* objId =  [prefs objectForKey:PREF_USER_OBJECT_ID];
    NSArray* array = self.currentEvent[@"Attendees"];
    if([array containsObject:self.userRoamer[@"Username"]]){
        [self.mJoinUnattendButton setBackgroundImage:[UIImage imageNamed:@"unattend"] forState:UIControlStateNormal];
        eventType = SHOW_MY_EVENTS;
    } else {
        [self.mJoinUnattendButton setBackgroundImage:[UIImage imageNamed:@"join"] forState:UIControlStateNormal];
        eventType = SHOW_ALL_EVENTS;
    }
    
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

    
    self.mTypeLabel.text = [self getEventFromInt:[self.currentEvent[@"Type"] intValue]]; //roamers.location;
    self.mTimeLabel.text = [self getTimeFromInt:[self.currentEvent[@"Time"] intValue]]; //roamers.location;
    self.mDateLabel.text = [dateFormat stringFromDate:self.currentEvent[@"Date"]]; //roamers.name;
    self.mHostNameLabel.text = self.currentEvent[@"Host"]; //roamers.name;
    self.mNoAttendingLabel.text = [self.currentEvent[@"Attend"] stringValue]; //roamers.name;
    self.mDescTextView.text = self.currentEvent[@"Desc"]; //roamers.name;
    [self.mDescTextView setTextColor:[UIColor whiteColor]];
    
    //    cell.mProfileImg.image = roamers.image;
    self.mProfileImg.layer.masksToBounds = YES;
    self.mProfileImg.layer.cornerRadius = 8.0; // half height & width
    
    self.mLocationLabel.numberOfLines = 0;
    int locWidth = self.mLocationLabel.frame.size.width;
    self.mLocationLabel.preferredMaxLayoutWidth = locWidth;
    self.mLocationLabel.text = self.currentEvent[@"Place"]; //roamers.name;
    [self.mLocationLabel sizeToFit];

    
    PFFile *userImageFile = self.currentEvent[@"Pic"];
    if([self checkForNull:userImageFile] == nil) {
        self.mProfileImg.image = [UIImage imageNamed:@"default_userpic.png"];
    } else {
        [userImageFile getDataInBackgroundWithBlock:^(NSData *imageData, NSError *error) {
            if (!error) {
                UIImage *image = [UIImage imageWithData:imageData];
                self.mProfileImg.image = image;
            }
        }];
    }
}

- (id) checkForNull:(id)obj {
    if([obj isKindOfClass:[NSNull class]])
        return nil;
    
    return obj;
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

- (NSString *) getTimeFromInt:(int)val {
    NSString* str = @"";
    for(NSDictionary* dict in timeArray) {
        if(val == [dict[@"value"] intValue]){
            str = dict[@"name"];
            break;
        }
    }
    return str;
}

- (IBAction)onCloseAction:(id)sender {
    [self.delegate backFromEventsDetailView:self];
}

- (IBAction)onJoinUnAttendAction:(id)sender {
//    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
//    NSString* objId =  [prefs objectForKey:PREF_USER_OBJECT_ID];
    NSMutableArray* array = self.currentEvent[@"Attendees"];
    if(eventType == SHOW_MY_EVENTS){
        [self removeFromCalendar];
        [array removeObject:self.userRoamer[@"Username"]];
        [self.currentEvent incrementKey:@"Attend" byAmount:[NSNumber numberWithInt:-1]];
    } else {
        if(array != nil)
            [array addObject:self.userRoamer[@"Username"]];
        else {
            array = [[NSMutableArray alloc] init];
            [array addObject:self.userRoamer[@"Username"]];
            self.currentEvent[@"Attendees"] = array;
        }
        [self.currentEvent incrementKey:@"Attend" byAmount:[NSNumber numberWithInt:1]];
        [self addToCalendar];
    }
    [[AppDelegate sharedDelegate] showFetchAlert];
    [self.currentEvent save];
    [[AppDelegate sharedDelegate] dissmissFetchAlert];
    [self.delegate backFromEventsDetailView:self];
}

- (void) removeFromCalendar {
    NSString* eventId = [UserProfileHelper getAndRemoveEventFromCache:self.currentEvent.objectId];
    EKEventStore* store = [[EKEventStore alloc] init];
    [store requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error) {
        if (!granted) { return; }
        EKEvent* eventToRemove = [store eventWithIdentifier:eventId];
        if (eventToRemove) {
            NSError* error = nil;
            [store removeEvent:eventToRemove span:EKSpanThisEvent commit:YES error:&error];
        }
    }];
}

- (void) addToCalendar {
    EKEventStore *store = [[EKEventStore alloc] init];
    [store requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error) {
        if (!granted) {
        } else {
            EKEvent *event = [EKEvent eventWithEventStore:store];
            event.title = @"Roamer Event";
            event.notes = self.currentEvent[@"Desc"];
            NSArray* times = [self getStartEndTime:self.currentEvent[@"Date"]];
            event.startDate = times[0]; //today
            event.endDate = times[1];  //set 1 hour meeting
            [event setCalendar:[store defaultCalendarForNewEvents]];
            NSError *err = nil;
            [store saveEvent:event span:EKSpanThisEvent commit:YES error:&err];
            NSString *savedEventId = event.eventIdentifier;  //this is so you can access this event later
            [UserProfileHelper cacheAddEvent:savedEventId objectId:self.currentEvent.objectId ];
        }
    }];
}

- (NSArray *) getStartEndTime:(NSDate *)nowDate {
//    NSCalendar * calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
//    unsigned unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit;
//    NSDateComponents *comps = [calendar components:unitFlags fromDate:nowDate];
    
    int timeInt = [self.currentEvent[@"Time"] intValue];
    
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


@end
