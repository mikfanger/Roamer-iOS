//
//  HomeViewController.h
//  Roamer
//
//  Created by Mac Home on 3/4/14.
//
//

#import <UIKit/UIKit.h>
#import "FindRoamersViewCntrl.h"
#import "MyRoamersViewCntrl.h"
#import "ShowEventsViewCntrl.h"
#import "PostEventViewController.h"
#import "EditProfileStep1ViewCtrl.h"
#import "InboxRequestViewCtrl.h"


@interface HomeViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, FindRoamersViewCntrlDelegate, MyRoamersViewCntrlDelegate, ShowEventsViewCntrlDelegate, PostEventViewControllerDelegate, InboxRequestViewCtrlDelegate, EditProfileStep1ViewCtrlDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *mBkgImage;
@property (weak, nonatomic) IBOutlet UILabel *mCurrentLocation;

@property (weak, nonatomic) IBOutlet UIView *mLocTableView;
@property (weak, nonatomic) IBOutlet UILabel *mViewTitleLabel;
@property (weak, nonatomic) IBOutlet UITableView *mTableView;

@property (strong, nonatomic) PFObject *userRoamer;

- (IBAction)onLogoutAction:(id)sender;
- (IBAction)onFindRoamers:(id)sender;
- (IBAction)onMyRoamers:(id)sender;
- (IBAction)onShowEvents:(id)sender;
- (IBAction)onChangeLocationAction:(id)sender;
- (IBAction)onPostEventAction:(id)sender;
- (IBAction)onEditProfileAction:(id)sender;
- (IBAction)onShowInboxAction:(id)sender;

@end
