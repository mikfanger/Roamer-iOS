//
//  LoginViewController.m
//  Roamer
//
//  Created by Mac Home on 2/23/14.
//
//

#import "LoginViewController.h"
#import "UserProfileHelper.h"
#import "MyAppConstants.h"
#import "HomeViewController.h"
#import "AppDelegate.h"

static const CGFloat KEYBOARD_ANIMATION_DURATION = 0.3;
static const CGFloat MINIMUM_SCROLL_FRACTION = 0.2;
static const CGFloat MAXIMUM_SCROLL_FRACTION = 0.8;
static const CGFloat LANDSCAPE_KEYBOARD_HEIGHT = 140;

static const CGFloat PORTRAIT_KEYBOARD_HEIGHT = 216;

CGFloat animatedDistance;

@interface LoginViewController ()
@property (nonatomic, strong) UITextField *currentTextField;

@end

@implementation LoginViewController

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
    
    UIToolbar* numberToolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, 320, 50)];
    numberToolbar.barStyle = UIBarStyleBlackTranslucent;
    numberToolbar.items = [NSArray arrayWithObjects:
                           [[UIBarButtonItem alloc]initWithTitle:@"Next" style:UIBarButtonItemStyleBordered target:self action:@selector(nextNumberPad)],
                           [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                           [[UIBarButtonItem alloc]initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(doneWithNumberPad)],
                           nil];
    [numberToolbar sizeToFit];
    
    UIToolbar* numberToolbar2 = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, 320, 50)];
    numberToolbar2.barStyle = UIBarStyleBlackTranslucent;
    numberToolbar2.items = [NSArray arrayWithObjects:
                            //                           [[UIBarButtonItem alloc]initWithTitle:@"" style:UIBarButtonItemStyleBordered target:self action:@selector(cancelNumberPad)],
                            [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                            [[UIBarButtonItem alloc]initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(doneWithNumberPad)],
                            nil];
    [numberToolbar2 sizeToFit];
    
    self.mEmailTextField.inputAccessoryView = numberToolbar;
    self.mPasswordTextField.inputAccessoryView = numberToolbar2;

    for(NSString *fontfamilyname in [UIFont familyNames])
    {
        NSLog(@"Family:'%@'",fontfamilyname);
        for(NSString *fontName in [UIFont fontNamesForFamilyName:fontfamilyname])
        {
            NSLog(@"\tfont:'%@'",fontName);
        }
        NSLog(@"~~~~~~~~");
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.mEmailTextField.text = @"";
    self.mPasswordTextField.text = @"";
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    if([prefs objectForKey:PREF_LOGIN_EMAIL]){
        self.mEmailTextField.text = [prefs objectForKey:PREF_LOGIN_EMAIL];
        self.mPasswordTextField.text = [prefs objectForKey:PREF_LOGIN_PASSWORD];
    }
}

-(void)nextNumberPad{
    if(self.currentTextField == self.mEmailTextField){
        [self.mPasswordTextField becomeFirstResponder];
    } else if(self.currentTextField == self.mPasswordTextField){
        [self.mPasswordTextField resignFirstResponder];
    }
    
}

-(void)doneWithNumberPad{
    [self.currentTextField resignFirstResponder];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onLoginAction:(id)sender {
    if ([self.mEmailTextField.text isEqualToString:@""]) {
        [self showAlertMessage:@"Error!!!" message:@"Enter a valid email address"];
        return;
    }
    
    if ([self.mPasswordTextField.text isEqualToString:@""]) {
        [self showAlertMessage:@"Error!!!" message:@"Password does not match!"];
        return;
    }
    
    if(self.mSaveLoginSwitch.isOn){
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        
        [prefs setObject:self.mEmailTextField.text forKey:PREF_LOGIN_EMAIL];
        [prefs setObject:self.mPasswordTextField.text forKey:PREF_LOGIN_PASSWORD];
        [prefs synchronize];
    }

    [[AppDelegate sharedDelegate] showFetchAlert];
    
    [PFUser logInWithUsernameInBackground:[self.mEmailTextField.text lowercaseString] password:self.mPasswordTextField.text
                block:^(PFUser *user, NSError *error) {
                    [[AppDelegate sharedDelegate] dissmissFetchAlert];
                    if (user) {
                        
                        //Boolean* emailVerified = *user.
                        UserProfileHelper* helper = [UserProfileHelper sharedUserProfileHelper];
                        PFObject* object = [helper checkIfUserExist:[self.mEmailTextField.text lowercaseString] password:self.mPasswordTextField.text];
                        if(object != nil) {
                            [object incrementKey:@"LoginCount"];
                            [object saveEventually];
                            self.userRoamer = object;
                            PFInstallation *currentInstallation = [PFInstallation currentInstallation];
                            [currentInstallation addUniqueObject:self.userRoamer[@"Username"] forKey:@"channels"];
                            [currentInstallation saveInBackground];
                            [self showHomeScreen];
                        } else {
                            [self showAlertMessage:@"Error" message:@"Email or Password does not match"];
                        }
                    } else {
                        if(error.code == 101)
                            [self showAlertMessage:@"Error!" message:@"Incorrect user name or password."];
                        else
                            [self showAlertMessage:@"Error!" message:error.description];
                    }
    }];
    
//    [self.navigationController pushViewController:myStoryBoardInitialViewController animated:YES];
}

- (IBAction)onForgotPassword:(id)sender {
    [self performSegueWithIdentifier:@"performForgotPwd" sender:self];
}

- (void) showAlertMessage:(NSString *)title message:(NSString *)msg {
    UIAlertView *errorAlert = [[UIAlertView alloc]
                               initWithTitle:title message:msg delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [errorAlert show];
}

- (void) showHomeScreen {
    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Home_iPhone" bundle:nil];
    HomeViewController* myStoryBoardInitialViewController = [storyboard instantiateInitialViewController];
    myStoryBoardInitialViewController.userRoamer = self.userRoamer;
    [self presentViewController:myStoryBoardInitialViewController animated:TRUE completion:nil];
    
}

- (IBAction)onCreateAccountAction:(id)sender {
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [prefs removeObjectForKey:PREF_EMAIL];
    [prefs removeObjectForKey:PREF_PASSWORD];
    [prefs removeObjectForKey:PREF_USERNAME];
    [prefs removeObjectForKey:PREF_GENDER];
    [prefs removeObjectForKey:PREF_REGION];
    [prefs removeObjectForKey:PREF_INDUSTRY];
    [prefs removeObjectForKey:PREF_TRAVEL_LEVEL];
    [prefs removeObjectForKey:PREF_AIRLINE];
    [prefs removeObjectForKey:PREF_HOTEL];
    [prefs removeObjectForKey:PREF_PROFILE_IMG];
    [prefs synchronize];

    [self performSegueWithIdentifier:@"performCreateAccount" sender:self];
}

- (void)performFinishedAction:(ExplanationViewCntrl *)viewCtrl {
    [self dismissViewControllerAnimated:NO completion:^{
        self.userRoamer = nil;
//        [self showHomeScreen];
    }];
}

- (void)fromForgotPassword:(ForgotPasswordViewCntrl *)viewCtrl {
    [self dismissViewControllerAnimated:YES completion:^{
    }];
}

#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"performCreateAccount"]) {
        ExplanationViewCntrl *friendsVC = segue.destinationViewController;
        friendsVC.delegate = self;
    } else if ([segue.identifier isEqualToString:@"performForgotPwd"]) {
        ForgotPasswordViewCntrl *friendsVC = segue.destinationViewController;
        friendsVC.delegate = self;
    }
    
}

#pragma mark - TextFieldDelegate

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    self.currentTextField = textField;
    
    CGRect textFieldRect = [self.mScrollView.window convertRect:textField.bounds fromView:textField];
    CGRect viewRect = [self.mScrollView.window convertRect:self.mScrollView.bounds fromView:self.mScrollView];
    CGFloat midline = textFieldRect.origin.y + 0.5 * textFieldRect.size.height;
    CGFloat numerator =
    midline - viewRect.origin.y - MINIMUM_SCROLL_FRACTION * viewRect.size.height;
    CGFloat denominator =
    (MAXIMUM_SCROLL_FRACTION - MINIMUM_SCROLL_FRACTION) * viewRect.size.height;
    CGFloat heightFraction = numerator / denominator;
    
    if (heightFraction < 0.0)
    {
        heightFraction = 0.0;
    }
    else if (heightFraction > 1.0)
    {
        heightFraction = 1.0;
    }
    
    UIInterfaceOrientation orientation =
    [[UIApplication sharedApplication] statusBarOrientation];
    if (orientation == UIInterfaceOrientationPortrait ||
        orientation == UIInterfaceOrientationPortraitUpsideDown)
    {
        animatedDistance = floor(PORTRAIT_KEYBOARD_HEIGHT * heightFraction);
    }
    else
    {
        animatedDistance = floor(LANDSCAPE_KEYBOARD_HEIGHT * heightFraction);
    }
    
    CGRect viewFrame = self.mScrollView.frame;
    viewFrame.origin.y -= animatedDistance;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:KEYBOARD_ANIMATION_DURATION];
    
    [self.mScrollView setFrame:viewFrame];
    
    [UIView commitAnimations];
}

- (void) textFieldDidEndEditing:(UITextField *)textField {
    
    CGRect viewFrame = self.mScrollView.frame;
    viewFrame.origin.y += animatedDistance;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:KEYBOARD_ANIMATION_DURATION];
    
    [self.mScrollView setFrame:viewFrame];
    
    [UIView commitAnimations];
}

@end
