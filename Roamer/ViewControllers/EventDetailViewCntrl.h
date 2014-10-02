//
//  EventDetailViewCntrl.h
//  Roamer
//
//  Created by Mac Home on 4/15/14.
//
//

#import <UIKit/UIKit.h>

@class EventDetailViewCntrl;

@protocol EventDetailViewCntrlDelegate <NSObject>
- (void)backFromEventsDetailView:(EventDetailViewCntrl *)viewCtrl;
@end

@interface EventDetailViewCntrl : UIViewController 

@property (nonatomic, weak) id <EventDetailViewCntrlDelegate> delegate;

@property (weak, nonatomic) IBOutlet UILabel *mNoAttendingLabel;
@property (weak, nonatomic) IBOutlet UILabel *mHostNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *mDateLabel;
@property (weak, nonatomic) IBOutlet UILabel *mTypeLabel;
@property (weak, nonatomic) IBOutlet UILabel *mLocationLabel;
@property (weak, nonatomic) IBOutlet UITextView *mDescTextView;
@property (weak, nonatomic) IBOutlet UIButton *mJoinUnattendButton;
@property (weak, nonatomic) IBOutlet UIImageView *mProfileImg;
@property (weak, nonatomic) IBOutlet UILabel *mTimeLabel;

@property (strong, nonatomic) PFObject *userRoamer;

@property (strong, nonatomic) PFObject *currentEvent;
@property (nonatomic, assign) int currentEventType;


- (IBAction)onCloseAction:(id)sender;
- (IBAction)onJoinUnAttendAction:(id)sender;
@end
