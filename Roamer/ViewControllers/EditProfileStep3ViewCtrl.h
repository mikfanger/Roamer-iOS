//
//  EditProfileStep3ViewCtrl.h
//  Roamer
//
//  Created by Rajesh Mehta on 6/18/14.
//
//

#import <UIKit/UIKit.h>

@class EditProfileStep3ViewCtrl;

@protocol EditProfileStep3ViewCtrlDelegate <NSObject>
- (void)returnFromEditProfileStep3:(EditProfileStep3ViewCtrl *)viewCtrl;
@end

@interface EditProfileStep3ViewCtrl : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, weak) id <EditProfileStep3ViewCtrlDelegate> delegate;
@property (strong, nonatomic) PFObject *userRoamer;
@property (strong, nonatomic) UIImage *profilePic;

@property (weak, nonatomic) IBOutlet UILabel *mTravelLabel;
@property (weak, nonatomic) IBOutlet UILabel *mAirlineLabel;
@property (weak, nonatomic) IBOutlet UILabel *mHotelLabel;

@property (weak, nonatomic) IBOutlet UILabel *mViewTitleLabel;
@property (weak, nonatomic) IBOutlet UIView *mSelectTableView;
@property (weak, nonatomic) IBOutlet UITableView *mTableView;

- (IBAction)onNextAction:(id)sender;
- (IBAction)onPrevAction:(id)sender;
- (IBAction)onTravelSelectAction:(id)sender;
- (IBAction)onAirlineSelectAction:(id)sender;
- (IBAction)onHotelSelectAction:(id)sender;

@end
