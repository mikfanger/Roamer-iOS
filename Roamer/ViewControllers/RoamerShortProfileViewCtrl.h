//
//  RoamerShortProfileViewCtrl.h
//  Roamer
//
//  Created by Mac Home on 3/7/14.
//
//

#import <UIKit/UIKit.h>
#import "Roamers.h"

@class RoamerShortProfileViewCtrl;

@protocol RoamerShortProfileViewCtrlDelegate <NSObject>
- (void)performBackAction:(RoamerShortProfileViewCtrl *)viewCtrl;
@end

@interface RoamerShortProfileViewCtrl : UIViewController

@property (strong, nonatomic) PFObject *currentRoamer;
@property (strong, nonatomic) PFObject *userRoamer;

@property (nonatomic, weak) id <RoamerShortProfileViewCtrlDelegate> delegate;

@property (weak, nonatomic) IBOutlet UIImageView *mProfileImage;
@property (weak, nonatomic) IBOutlet UILabel *mRoamSinceDateLabel;
@property (weak, nonatomic) IBOutlet UILabel *mNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *mGenderLabel;
@property (weak, nonatomic) IBOutlet UILabel *mJobPositionLabel;
@property (weak, nonatomic) IBOutlet UILabel *mLocationLabel;
@property (weak, nonatomic) IBOutlet UILabel *mHotelPrefLabel;
@property (weak, nonatomic) IBOutlet UILabel *mAirlineLabel;
@property (weak, nonatomic) IBOutlet UIView *extendedProfileView;
@property (weak, nonatomic) IBOutlet UIButton *mAddRemoveButton;

- (IBAction)onCloseAction:(id)sender;
- (IBAction)onAddRoamerAction:(id)sender;

- (NSString *) getStringFromInt:(int)val arrayList:(NSArray *)arrays;
@end
