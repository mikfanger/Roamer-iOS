//
//  ForgotPasswordViewCntrl.m
//  Roamer
//
//  Created by Mac Home on 5/23/14.
//
//

#import "ForgotPasswordViewCntrl.h"
#import "AppDelegate.h"

@interface ForgotPasswordViewCntrl ()

@end

@implementation ForgotPasswordViewCntrl

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onSubmitAction:(id)sender {
    if ([self.mEmailText.text isEqualToString:@""]) {
        [self showAlertMessage:@"Error!!!" message:@"Enter a valid email address"];
        return;
    }
    [[AppDelegate sharedDelegate] showFetchAlert];
    [PFUser requestPasswordResetForEmailInBackground:[self.mEmailText.text lowercaseString]
            block:^(BOOL succeeded, NSError *error) {
                [[AppDelegate sharedDelegate] dissmissFetchAlert];
                if(succeeded) {
                    [self showAlertMessage:@"Confirmation!!!" message:@"Please check your email and follow the steps to reset your password."];
                    [self.delegate fromForgotPassword:self];
                } else {
                    if((error != nil) && (error.code == 205)){
                        [self showAlertMessage:@"Error!!!" message:@"No user found."];
                    } else
                        [self showAlertMessage:@"Error!!!" message:@"Error resetting your password. Please try again..."];
                }
            }];
    
}

- (void) showAlertMessage:(NSString *)title message:(NSString *)msg {
    UIAlertView *errorAlert = [[UIAlertView alloc]
                               initWithTitle:title message:msg delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [errorAlert show];
}

- (IBAction)onBackAction:(id)sender {
    [self.delegate fromForgotPassword:self];
}

@end
