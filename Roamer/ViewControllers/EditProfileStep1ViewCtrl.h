//
//  EditProfileStep1ViewCtrl.h
//  Roamer
//
//  Created by Rajesh Mehta on 6/18/14.
//
//

#import <UIKit/UIKit.h>
#import "EditProfileStep2ViewCtrl.h"

@class EditProfileStep1ViewCtrl;

@protocol EditProfileStep1ViewCtrlDelegate <NSObject>
- (void)returnFromEditProfileStep1:(EditProfileStep1ViewCtrl *)viewCtrl;
@end

@interface EditProfileStep1ViewCtrl : UIViewController <UIAlertViewDelegate, UITextFieldDelegate, EditProfileStep2ViewCtrlDelegate>

@property (nonatomic, weak) id <EditProfileStep1ViewCtrlDelegate> delegate;
@property (strong, nonatomic) PFObject *userRoamer;
@property (strong, nonatomic) UIImage *profilePic;

@property (weak, nonatomic) IBOutlet UILabel *mEmailTextField;
@property (weak, nonatomic) IBOutlet UITextField *mPasswordTextField;
@property (weak, nonatomic) IBOutlet UITextField *mConfirmPwdTextField;
@property (weak, nonatomic) IBOutlet UIScrollView *mScrollView;

- (IBAction)onNextAction:(id)sender;
- (IBAction)onPrevAction:(id)sender;
- (IBAction)onEditEmailAction:(id)sender;

@end
