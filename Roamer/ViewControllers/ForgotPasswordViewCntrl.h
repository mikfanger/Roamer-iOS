//
//  ForgotPasswordViewCntrl.h
//  Roamer
//
//  Created by Mac Home on 5/23/14.
//
//

#import <UIKit/UIKit.h>

@class ForgotPasswordViewCntrl;

@protocol ForgotPasswordViewCntrlDelegate <NSObject>
- (void)fromForgotPassword:(ForgotPasswordViewCntrl *)viewCtrl;
@end

@interface ForgotPasswordViewCntrl : UIViewController

@property (weak, nonatomic) IBOutlet UIScrollView *mScrollView;
@property (weak, nonatomic) IBOutlet UITextField *mEmailText;
@property (nonatomic, weak) id <ForgotPasswordViewCntrlDelegate> delegate;

- (IBAction)onSubmitAction:(id)sender;
- (IBAction)onBackAction:(id)sender;
@end
