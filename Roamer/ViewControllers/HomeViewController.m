//
//  HomeViewController.m
//  Roamer
//
//  Created by Mac Home on 3/4/14.
//
//

#import "HomeViewController.h"
#import "MyAppConstants.h"
#import "DataSource.h"
#import "UserProfileHelper.h"
#import "AppDelegate.h"


@interface HomeViewController () {
    NSArray *locationArray;
    CGRect  locSelectRect;
    CGRect  locSelectRectHidden;
//    int locationInt;
}

@end

@implementation HomeViewController

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
    if ([[UIScreen mainScreen] bounds].size.height == 568){
        self.mBkgImage.image = [UIImage imageNamed:@"plane_1136x640.png"];
    } else {
        self.mBkgImage.image = [UIImage imageNamed:@"plane_960x640.png"];
    }

    locationArray = [DataSource CurrentLocList];
    self.mCurrentLocation.text = locationArray[0][@"name"];

    locSelectRect = self.mLocTableView.frame;
    locSelectRectHidden = CGRectMake(0, locSelectRect.origin.y + locSelectRect.size.height + 30, locSelectRect.size.width, locSelectRect.size.height);
    self.mLocTableView.frame = locSelectRectHidden;
    
    }

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    NSUserDefaults* pref = [NSUserDefaults standardUserDefaults];
    NSString* loc = [pref objectForKey:PREF_CURRENT_LOC_STRING];
    if(loc == nil){
        self.mCurrentLocation.text = @"";
    } else
        self.mCurrentLocation.text = loc;

    if(self.userRoamer == nil){
        [[AppDelegate sharedDelegate] dissmissFetchAlert];
        NSUserDefaults* pref = [NSUserDefaults standardUserDefaults];
        NSString* email = [pref objectForKey:PREF_EMAIL];
        NSString* pwd = [pref objectForKey:PREF_PASSWORD];
        UserProfileHelper* helper = [UserProfileHelper sharedUserProfileHelper];
        PFObject* object = [helper checkIfUserExist:email password:pwd];
        if(object != nil) {
            self.userRoamer = object;
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onLogoutAction:(id)sender {
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation removeObject:self.userRoamer[@"Username"] forKey:@"channels"];
    [currentInstallation saveInBackground];

    [self dismissViewControllerAnimated:true completion:nil];
}

- (IBAction)onFindRoamers:(id)sender {
    [self performSegueWithIdentifier:@"performFindRoamer" sender:self];
}

- (IBAction)onMyRoamers:(id)sender {
    [self performSegueWithIdentifier:@"performMyRoamer" sender:self];
}

- (IBAction)onShowEvents:(id)sender {
    [self performSegueWithIdentifier:@"showEvents" sender:self];
}

- (IBAction)onChangeLocationAction:(id)sender {
    [self.mTableView reloadData];
    [self slideInLocViewAnimation];
}

- (IBAction)onPostEventAction:(id)sender {
    NSUserDefaults* pref = [NSUserDefaults standardUserDefaults];
    int locInt = (int)[pref integerForKey:PREF_CURRENT_LOC_INT];
    if(locInt == 0){
        [self showAlertMessage:@"Error!!!" message:@"Please select your current location."];
    } else {
        [self performSegueWithIdentifier:@"performPostEvent" sender:self];
    }
}

- (void) showAlertMessage:(NSString *)title message:(NSString *)msg {
    UIAlertView *errorAlert = [[UIAlertView alloc]
                               initWithTitle:title message:msg delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [errorAlert show];
}

- (IBAction)onEditProfileAction:(id)sender {
    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"EditProfile_iPhone" bundle:nil];
    EditProfileStep1ViewCtrl* myStoryBoardInitialViewController = [storyboard instantiateInitialViewController];
    myStoryBoardInitialViewController.userRoamer = self.userRoamer;
    myStoryBoardInitialViewController.delegate = self;
    [self presentViewController:myStoryBoardInitialViewController animated:TRUE completion:nil];
}

- (IBAction)onShowInboxAction:(id)sender {
    [self performSegueWithIdentifier:@"performInboxRequest" sender:self];
}

- (void) slideInLocViewAnimation {
    self.mViewTitleLabel.text = @"Select Location";
    self.mLocTableView.frame = locSelectRectHidden;
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:0.6f];
    self.mLocTableView.frame = locSelectRect;
	[UIView commitAnimations];
}

- (void) slideOutLocViewAnimation {
    self.mLocTableView.frame = locSelectRect;
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:0.6f];
    self.mLocTableView.frame = locSelectRectHidden;
	[UIView commitAnimations];
}

- (void)returnFromEditProfileStep1:(EditProfileStep1ViewCtrl *)viewCtrl {
    [self dismissViewControllerAnimated:YES completion:^{
    }];    
}

- (void)performBackAction:(FindRoamersViewCntrl *)viewCtrl {
    [self dismissViewControllerAnimated:YES completion:^{
    }];
}

- (void)performBackFromMyRoamerAction:(MyRoamersViewCntrl *)viewCtrl {
    [self dismissViewControllerAnimated:YES completion:^{
    }];    
}

- (void)backFromShowEventsView:(ShowEventsViewCntrl *)viewCtrl {
    [self dismissViewControllerAnimated:YES completion:^{
    }];
}

- (void)backFromPostEventsView:(PostEventViewController *)viewCtrl {
    [self dismissViewControllerAnimated:YES completion:^{
    }];
}

- (void)backFromInboxRequestView:(InboxRequestViewCtrl *)viewCtrl {
    [self dismissViewControllerAnimated:YES completion:^{
    }];    
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [locationArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"DataCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    cell.textLabel.text = locationArray[indexPath.row][@"name"];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSString* str = locationArray[indexPath.row][@"name"];
    self.mCurrentLocation.text = str;
    int locationInt = [locationArray[indexPath.row][@"value"] intValue];
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    
    [prefs setObject:str forKey:PREF_CURRENT_LOC_STRING];
    [prefs setInteger:locationInt forKey:PREF_CURRENT_LOC_INT];
    PFGeoPoint* geoPoint = locationArray[indexPath.row][@"latlong"];
    [prefs setDouble:geoPoint.latitude forKey:PREF_CURRENT_LOC_GEO_LAT];
    [prefs setDouble:geoPoint.longitude forKey:PREF_CURRENT_LOC_GEO_LONG];
    [prefs synchronize];

    NSString* objId =  [prefs objectForKey:PREF_USER_OBJECT_ID];
    
    PFQuery *query = [PFQuery queryWithClassName:@"Roamer"];
    [query getObjectInBackgroundWithId:objId block:^(PFObject *roamers, NSError *error) {
        roamers[@"CurrentLocation"] = [NSNumber numberWithInt:locationInt];
        [roamers saveInBackground];
        [self slideOutLocViewAnimation];
    }];
}

#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"performFindRoamer"]) {
        FindRoamersViewCntrl *friendsVC = segue.destinationViewController;
        friendsVC.userRoamer = self.userRoamer;
        friendsVC.delegate = self;
    } else if ([segue.identifier isEqualToString:@"performMyRoamer"]) {
        MyRoamersViewCntrl *friendsVC = segue.destinationViewController;
        friendsVC.userRoamer = self.userRoamer;
        friendsVC.delegate = self;
    } else if ([segue.identifier isEqualToString:@"showEvents"]) {
        ShowEventsViewCntrl *friendsVC = segue.destinationViewController;
        friendsVC.userRoamer = self.userRoamer;
        friendsVC.delegate = self;
    } else if ([segue.identifier isEqualToString:@"performPostEvent"]) {
        PostEventViewController *friendsVC = segue.destinationViewController;
        friendsVC.userRoamer = self.userRoamer;
        friendsVC.delegate = self;
    } else if ([segue.identifier isEqualToString:@"performInboxRequest"]) {
        InboxRequestViewCtrl *friendsVC = segue.destinationViewController;
        friendsVC.userRoamer = self.userRoamer;
        friendsVC.delegate = self;
    }
    //
}

@end
