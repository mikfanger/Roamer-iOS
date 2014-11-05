//
//  EditProfileStep1ViewCtrl.m
//  Roamer
//
//  Created by Rajesh Mehta on 6/18/14.
//
//

#import "EditProfileStep1ViewCtrl.h"
#import "MyAppConstants.h"
#import "UserProfileHelper.h"

#define EDIT_EMAIL_ALERT        202

static const CGFloat KEYBOARD_ANIMATION_DURATION = 0.3;
static const CGFloat MINIMUM_SCROLL_FRACTION = 0.2;
static const CGFloat MAXIMUM_SCROLL_FRACTION = 0.8;
static const CGFloat LANDSCAPE_KEYBOARD_HEIGHT = 140;

static const CGFloat PORTRAIT_KEYBOARD_HEIGHT = 216;

CGFloat animatedDistance;

@interface EditProfileStep1ViewCtrl ()
@property (nonatomic, strong) UITextField *currentTextField;

@end

@implementation EditProfileStep1ViewCtrl

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

    self.mPasswordTextField.delegate = self;
    self.mConfirmPwdTextField.delegate = self;

    UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, 20)];
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
    
    self.mPasswordTextField.inputAccessoryView = numberToolbar;
    self.mConfirmPwdTextField.inputAccessoryView = numberToolbar2;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    NSUserDefaults* pref = [NSUserDefaults standardUserDefaults];
    
    
    [pref setObject:self.userRoamer[@"Email"] forKey:PREF_EMAIL];
    [pref setObject:self.userRoamer[@"Password"] forKey:PREF_PASSWORD];
    [pref setObject:self.userRoamer[@"Username"] forKey:PREF_USERNAME];

    [pref setObject:self.userRoamer[@"Location"] forKey:PREF_REGION];
    [pref setObject:self.userRoamer[@"Industry"] forKey:PREF_INDUSTRY];

    [pref setObject:self.userRoamer[@"Travel"] forKey:PREF_TRAVEL_LEVEL];
    [pref setObject:self.userRoamer[@"Airline"] forKey:PREF_AIRLINE];
    [pref setObject:self.userRoamer[@"Hotel"] forKey:PREF_HOTEL];
    [pref setObject:self.userRoamer[@"Job"] forKey:PREF_JOB];

    PFFile *userImageFile = self.userRoamer[@"Pic"];
    if([self checkForNull:userImageFile] == nil) {
        self.profilePic = nil;
    } else {
        [userImageFile getDataInBackgroundWithBlock:^(NSData *imageData, NSError *error) {
            if (!error) {
                self.profilePic = [UIImage imageWithData:imageData];
            }
        }];
    }

    self.mEmailTextField.text = self.userRoamer[@"Email"];
    self.mPasswordTextField.text = self.userRoamer[@"Password"];
    self.mConfirmPwdTextField.text = self.userRoamer[@"Password"];

}

-(BOOL) validateEmail:(NSString *) candidate
{
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:candidate];
}

- (id) checkForNull:(id)obj {
    if([obj isKindOfClass:[NSNull class]])
        return nil;
    
    return obj;
}

-(void)nextNumberPad{
    if(self.currentTextField == self.mPasswordTextField){
        [self.mConfirmPwdTextField becomeFirstResponder];
    } else if(self.currentTextField == self.mConfirmPwdTextField){
        [self.mConfirmPwdTextField resignFirstResponder];
    }
    
}

-(void)doneWithNumberPad{
    [self.currentTextField resignFirstResponder];
}

- (IBAction)onEditEmailAction:(id)sender {
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Add or Edit Email Address" message:@"" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Save", nil];
    alert.tag = EDIT_EMAIL_ALERT;
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    UITextField * alertTextField = [alert textFieldAtIndex:0];
    alertTextField.keyboardType = UIKeyboardTypeEmailAddress;
    NSUserDefaults* pref = [NSUserDefaults standardUserDefaults];
    if ([pref objectForKey:PREF_EMAIL]) {
        alertTextField.placeholder = [pref objectForKey:PREF_EMAIL];
    } else {
        alertTextField.placeholder = @"";
    }
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == EDIT_EMAIL_ALERT) {
        UITextField * alertTextField = [alertView textFieldAtIndex:0];
        NSString* detailString = alertTextField.text;
        if ([alertTextField.text length] <= 0 || buttonIndex == 0){
            return; //If cancel or 0 length string the string doesn't matter
        }
        if (buttonIndex == 1) {
            [self validateAndSaveEmail:detailString];
        }
    }
}

- (void) validateAndSaveEmail:(NSString *) emailString {
    if ([emailString isEqualToString:@""]) {
        [self showAlertMessage:@"Error!!!" message:@"All fields must be filled!"];
        return;
    }
    
    if (![self validateEmail:emailString])
    {
        [self showAlertMessage:@"Error!!!" message:@"Please enter a valid email address!"];
        return;
    }
    
    UserProfileHelper* helper = [UserProfileHelper sharedUserProfileHelper];
    BOOL isEmailExists = [helper checkIfEmailOnlyExist:emailString];
    if(isEmailExists) {
        [self showAlertMessage:@"Error!!!" message:@"Email already exists!!!"];
        return;
    }

    self.mEmailTextField.text = emailString;
}

- (IBAction)onPrevAction:(id)sender {
    [self dismissViewControllerAnimated:true completion:nil];
}

- (IBAction)onNextAction:(id)sender {
    NSString *mPassword = self.mPasswordTextField.text;
    NSString *mConfirmPassword = self.mConfirmPwdTextField.text;
    
    if ([mPassword isEqualToString:@""]) {
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
 /*
    UserProfileHelper* helper = [UserProfileHelper sharedUserProfileHelper];
    BOOL isEmailExists = [helper checkIfEmailExist:mEmailAddress userId:mUsername];
    if(isEmailExists) {
        [self showAlertMessage:@"Error!!!" message:@"Email and/or Username already exists!!!"];
        return;
    } */
    
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    
    [prefs setObject:self.mEmailTextField.text forKey:PREF_EMAIL];
    [prefs setObject:mPassword forKey:PREF_PASSWORD];
    [prefs synchronize];
    
    [self performSegueWithIdentifier:@"showEditProfileStep2" sender:self];
}


- (void) showAlertMessage:(NSString *)title message:(NSString *)msg {
    UIAlertView *errorAlert = [[UIAlertView alloc]
                               initWithTitle:title message:msg delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [errorAlert show];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)returnFromEditProfileStep2:(EditProfileStep2ViewCtrl *)viewCtrl {
    [self dismissViewControllerAnimated:NO completion:^{
        [self.delegate returnFromEditProfileStep1:self];
    }];    
}

#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"showEditProfileStep2"]) {
        EditProfileStep2ViewCtrl *friendsVC = segue.destinationViewController;
        friendsVC.userRoamer = self.userRoamer;
        friendsVC.profilePic = self.profilePic;
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
