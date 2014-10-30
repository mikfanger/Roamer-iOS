//
//  CreateAccount2ViewCtrl.h
//  Roamer
//
//  Created by Mac Home on 2/24/14.
//
//

#import <UIKit/UIKit.h>
#import "CreateAccountPicViewCtrl.h"

@class CreateAccount2ViewCtrl;

@protocol CreateAccount2ViewCtrlDelegate <NSObject>
- (void)performFinishedAction:(CreateAccount2ViewCtrl *)viewCtrl;
@end

@interface CreateAccount2ViewCtrl : UIViewController <UIImagePickerControllerDelegate, UITableViewDataSource, UITableViewDelegate, CreateAccountPicViewCtrlDelegate, UINavigationControllerDelegate>

@property (weak, nonatomic) IBOutlet UILabel *mLocationLabel;
@property (weak, nonatomic) IBOutlet UIImageView *mProfileImgView;
@property (weak, nonatomic) IBOutlet UILabel *mIndustryLabel;
@property (weak, nonatomic) IBOutlet UILabel *mJobLabel;

@property (weak, nonatomic) IBOutlet UIView *mLocTableView;
@property (weak, nonatomic) IBOutlet UILabel *mViewTitleLabel;
@property (weak, nonatomic) IBOutlet UITableView *mTableView;

@property (nonatomic, weak) id <CreateAccount2ViewCtrlDelegate> delegate;

- (IBAction)onNextAction:(id)sender;
- (IBAction)onSelectLocAction:(id)sender;
- (IBAction)onPrevAction:(id)sender;
- (IBAction)onSelectImgAction:(id)sender;
- (IBAction)onIndustrySelectAction:(id)sender;
- (IBAction)onJobSelectAction:(id)sender;

@end
