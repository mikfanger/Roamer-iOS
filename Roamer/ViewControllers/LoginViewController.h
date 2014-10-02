//
//  LoginViewController.h
//  Roamer
//
//  Created by Mac Home on 2/23/14.
//
//

#import <UIKit/UIKit.h>
#import "ExplanationViewCntrl.h"
#import "ForgotPasswordViewCntrl.h"

@interface LoginViewController : UIViewController <UITextFieldDelegate, ExplanationViewCntrlDelegate, ForgotPasswordViewCntrlDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *mScrollView;
@property (weak, nonatomic) IBOutlet UITextField *mEmailTextField;
@property (weak, nonatomic) IBOutlet UITextField *mPasswordTextField;
@property (weak, nonatomic) IBOutlet UISwitch *mSaveLoginSwitch;

@property (strong, nonatomic) PFObject *userRoamer;


- (IBAction)onLoginAction:(id)sender;
- (IBAction)onForgotPassword:(id)sender;

- (IBAction)onCreateAccountAction:(id)sender;
@end
