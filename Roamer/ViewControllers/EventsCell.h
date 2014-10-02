//
//  EventsCell.h
//  Roamer
//
//  Created by Mac Home on 4/11/14.
//
//

#import <UIKit/UIKit.h>

@interface EventsCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIView *mBkgView;
@property (weak, nonatomic) IBOutlet UIImageView *mProfileImgView;
@property (weak, nonatomic) IBOutlet UILabel *mEventNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *mEventDateLabel;
@property (weak, nonatomic) IBOutlet UILabel *mUserNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *mEventAttendeeCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *mEventLocationLabel;
@property (weak, nonatomic) IBOutlet UILabel *mEventDescriptionLabel;
@property (weak, nonatomic) IBOutlet UILabel *mAttendingTitle;
@property (weak, nonatomic) IBOutlet UILabel *mLocationTitle;
@end
