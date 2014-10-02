//
//  CreateAccountViewCntrl.h
//  Roamer
//
//  Created by Mac Home on 2/24/14.
//
//

#import <UIKit/UIKit.h>
#import "CreateAccount2ViewCtrl.h"

@class CreateAccountViewCntrl;

@protocol CreateAccountViewCntrlDelegate <NSObject>
- (void)performFinishedAction:(CreateAccountViewCntrl *)viewCtrl;
@end

@interface CreateAccountViewCntrl : UIViewController <UITextFieldDelegate, CreateAccount2ViewCtrlDelegate>

@property (weak, nonatomic) IBOutlet UITextField *mUserNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *mEmailTextField;
@property (weak, nonatomic) IBOutlet UITextField *mPasswordTextField;
@property (weak, nonatomic) IBOutlet UITextField *mConfirmPwdTextField;
@property (weak, nonatomic) IBOutlet UISegmentedControl *mGenderSegCtrl;
@property (weak, nonatomic) IBOutlet UISwitch *mTermsSwitch;
@property (weak, nonatomic) IBOutlet UIScrollView *mScrollView;

@property (nonatomic, weak) id <CreateAccountViewCntrlDelegate> delegate;

- (IBAction)onNextAction:(id)sender;
- (IBAction)onPrevAction:(id)sender;
- (IBAction)onToCAction:(id)sender;

@end
