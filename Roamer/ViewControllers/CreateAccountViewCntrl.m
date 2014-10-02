//
//  CreateAccountViewCntrl.m
//  Roamer
//
//  Created by Mac Home on 2/24/14.
//
//

#import "CreateAccountViewCntrl.h"
#import "MyAppConstants.h"
#import "UserProfileHelper.h"
#import "AppDelegate.h"

static const CGFloat KEYBOARD_ANIMATION_DURATION = 0.3;
static const CGFloat MINIMUM_SCROLL_FRACTION = 0.2;
static const CGFloat MAXIMUM_SCROLL_FRACTION = 0.8;
static const CGFloat LANDSCAPE_KEYBOARD_HEIGHT = 140;

static const CGFloat PORTRAIT_KEYBOARD_HEIGHT = 216;

CGFloat animatedDistance;

@interface CreateAccountViewCntrl ()
@property (nonatomic, strong) UITextField *currentTextField;

@end

@implementation CreateAccountViewCntrl

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
    
    self.mUserNameTextField.delegate = self;
    self.mEmailTextField.delegate = self;
    self.mPasswordTextField.delegate = self;
    self.mConfirmPwdTextField.delegate = self;
    
    UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, 20)];
    self.mUserNameTextField.leftView = paddingView;
    self.mUserNameTextField.leftViewMode = UITextFieldViewModeAlways;
    self.mEmailTextField.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, 20)];
    self.mEmailTextField.leftViewMode = UITextFieldViewModeAlways;
    self.mPasswordTextField.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, 20)];
    self.mPasswordTextField.leftViewMode = UITextFieldViewModeAlways;
    self.mConfirmPwdTextField.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, 20)];
    self.mConfirmPwdTextField.leftViewMode = UITextFieldViewModeAlways; 

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
    
    self.mUserNameTextField.inputAccessoryView = numberToolbar;
    self.mEmailTextField.inputAccessoryView = numberToolbar;
    self.mPasswordTextField.inputAccessoryView = numberToolbar;
    self.mConfirmPwdTextField.inputAccessoryView = numberToolbar2;
    
    self.mTermsSwitch.on = false;
    self.mGenderSegCtrl.selectedSegmentIndex = -1;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    

    if([prefs objectForKey:PREF_EMAIL]){
        self.mUserNameTextField.text = [prefs objectForKey:PREF_USERNAME];
        self.mEmailTextField.text = [prefs objectForKey:PREF_EMAIL];
        self.mPasswordTextField.text = [prefs objectForKey:PREF_PASSWORD];
        self.mConfirmPwdTextField.text = [prefs objectForKey:PREF_PASSWORD];
        self.mGenderSegCtrl.selectedSegmentIndex = [prefs integerForKey:PREF_GENDER];
    } else {
        self.mUserNameTextField.text = @"";
        self.mEmailTextField.text = @"";
        self.mPasswordTextField.text = @"";
        self.mConfirmPwdTextField.text = @"";
    }
}

-(void)nextNumberPad{
    if(self.currentTextField == self.mUserNameTextField){
        [self.mEmailTextField becomeFirstResponder];
    } else if(self.currentTextField == self.mEmailTextField){
        [self.mPasswordTextField becomeFirstResponder];
    } else if(self.currentTextField == self.mPasswordTextField){
        [self.mConfirmPwdTextField becomeFirstResponder];
    } else if(self.currentTextField == self.mConfirmPwdTextField){
        [self.mConfirmPwdTextField resignFirstResponder];
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

- (IBAction)onNextAction:(id)sender {
    NSString *mEmailAddress = [self.mEmailTextField.text lowercaseString];
    NSString *mPassword = self.mPasswordTextField.text;
    NSString *mUsername = self.mUserNameTextField.text;
    NSString *mConfirmPassword = self.mConfirmPwdTextField.text;
    
    if ([mEmailAddress isEqualToString:@""]) {
        [self showAlertMessage:@"Error!!!" message:@"All fields must be filled!"];
        return;
    }

    if ([mPassword isEqualToString:@""]) {
        [self showAlertMessage:@"Error!!!" message:@"All fields must be filled!"];
        return;
    }

    if ([mUsername isEqualToString:@""]) {
        [self showAlertMessage:@"Error!!!" message:@"All fields must be filled!"];
        return;
    }

    if ([mConfirmPassword isEqualToString:@""]) {
        [self showAlertMessage:@"Error!!!" message:@"All fields must be filled!"];
        return;
    }

    if(![mPassword isEqualToString:mConfirmPassword]){
        [self showAlertMessage:@"Error!!!" message:@"Passwords must match!"];
        return;
    }
    
    if (![self validateEmail:mEmailAddress])
    {
        [self showAlertMessage:@"Error!!!" message:@"Please enter a valid email address!"];
        return;
    }

    if(!self.mTermsSwitch.isOn){
        [self showAlertMessage:@"Error!!!" message:@"You must agree to Terms and Conditions!"];
        return;
    }

    if((self.mGenderSegCtrl.selectedSegmentIndex != 0)  && (self.mGenderSegCtrl.selectedSegmentIndex != 1)) {
        [self showAlertMessage:@"Error!!!" message:@"Must select a gender!"];
        return;
    }
    
    UserProfileHelper* helper = [UserProfileHelper sharedUserProfileHelper];
    [[AppDelegate sharedDelegate] showFetchAlert];
    BOOL isEmailExists = [helper checkIfEmailExist:mEmailAddress userId:mUsername];
    [[AppDelegate sharedDelegate] dissmissFetchAlert];
    if(isEmailExists) {
        [self showAlertMessage:@"Error!!!" message:@"Email and/or Username already exists!!!"];
        return;
    }

    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    
    [prefs setObject:mEmailAddress forKey:PREF_EMAIL];
    [prefs setObject:mPassword forKey:PREF_PASSWORD];
    [prefs setObject:mUsername forKey:PREF_USERNAME];
    [prefs setInteger:self.mGenderSegCtrl.selectedSegmentIndex forKey:PREF_GENDER];
    [prefs synchronize];

    [self performSegueWithIdentifier:@"performCreatAcct2" sender:self];
}

-(BOOL) validateEmail:(NSString *) candidate
{
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:candidate];
}


- (void) showAlertMessage:(NSString *)title message:(NSString *)msg {
    UIAlertView *errorAlert = [[UIAlertView alloc]
                               initWithTitle:title message:msg delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [errorAlert show];
}

- (void)performFinishedAction:(CreateAccount2ViewCtrl *)viewCtrl {
    [self dismissViewControllerAnimated:NO completion:^{
        [self.delegate performFinishedAction:self];
    }];
}

- (IBAction)onPrevAction:(id)sender {
    [self dismissViewControllerAnimated:true completion:nil];
}

- (IBAction)onToCAction:(id)sender {
    [self performSegueWithIdentifier:@"showTerms" sender:self];
}

#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"performCreatAcct2"]) {
        CreateAccount2ViewCtrl *friendsVC = segue.destinationViewController;
        friendsVC.delegate = self;
    } else if ([segue.identifier isEqualToString:@"showTerms"]) {
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
