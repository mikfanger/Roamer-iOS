//
//  EditProfileStep2ViewCtrl.h
//  Roamer
//
//  Created by Rajesh Mehta on 6/18/14.
//
//

#import <UIKit/UIKit.h>
#import "EditProfileStep3ViewCtrl.h"

@class EditProfileStep2ViewCtrl;

@protocol EditProfileStep2ViewCtrlDelegate <NSObject>
- (void)returnFromEditProfileStep2:(EditProfileStep2ViewCtrl *)viewCtrl;
@end

@interface EditProfileStep2ViewCtrl : UIViewController <EditProfileStep3ViewCtrlDelegate, UIImagePickerControllerDelegate, UITableViewDataSource, UITableViewDelegate,  UINavigationControllerDelegate>

@property (nonatomic, weak) id <EditProfileStep2ViewCtrlDelegate> delegate;
@property (strong, nonatomic) PFObject *userRoamer;
@property (strong, nonatomic) UIImage *profilePic;

@property (weak, nonatomic) IBOutlet UILabel *mLocationLabel;
@property (weak, nonatomic) IBOutlet UIImageView *mProfileImgView;
@property (weak, nonatomic) IBOutlet UILabel *mIndustryLabel;

@property (weak, nonatomic) IBOutlet UIView *mLocTableView;
@property (weak, nonatomic) IBOutlet UILabel *mViewTitleLabel;
@property (weak, nonatomic) IBOutlet UITableView *mTableView;

- (IBAction)onNextAction:(id)sender;
- (IBAction)onSelectLocAction:(id)sender;
- (IBAction)onPrevAction:(id)sender;
- (IBAction)onSelectImgAction:(id)sender;
- (IBAction)onIndustrySelectAction:(id)sender;

@end
