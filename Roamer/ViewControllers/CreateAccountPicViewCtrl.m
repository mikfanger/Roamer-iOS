//
//  CreateAccountPicViewCtrl.m
//  Roamer
//
//  Created by Mac Home on 2/24/14.
//
//

#import <MobileCoreServices/UTCoreTypes.h>
#import "CreateAccountPicViewCtrl.h"
#import "MyAppConstants.h"
#import "UserProfileHelper.h"
#import "DataSource.h"
#import "AppDelegate.h"

#define TRAVEL_SELECT                      2
#define AIRLINE_SELECT                  3
#define HOTEL_SELECT                    4

@interface CreateAccountPicViewCtrl () {
    NSArray *travelArray;
    NSArray *airlineArray;
    NSArray *hotelArray;
    int currentButton;
    CGRect  locSelectRect;
    CGRect  locSelectRectHidden;
    
    int travelInt;
    int airlineInt;
    int hotelInt;
}

@end

@implementation CreateAccountPicViewCtrl

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

//    industryArray = @[@"Medical",@"Finance",@"Software",@"Manufacturing",@"Biotech"];
//    jobArray = @[@"Accounting",@"Marketing",@"Consultant",@"Sales",@"Garbage Man"];
//    airlineArray = @[@"Jet Blue",@"Southwest",@"Delta",@"United",@"American"];
//    hotelArray = @[@"Hilton",@"Starwood",@"Marriott",@"Doubletree",@"Embassy"];
//    travelArray = @[@{@"name": @"0-10% Travel Per Year",@"value":@"01"},@{@"name": @"10-30% Travel Per Year",@"value":@"02"},@{@"name": @"40-60% Travel Per Year",@"value":@"03"},@{@"name": @"60-80% Travel Per Year",@"value":@"04"},@{@"name": @"80-100% Travel Per Year",@"value":@"05"}];
    travelArray = [DataSource TravelStatusList];
    airlineArray = [DataSource AirlineList];
    hotelArray = [DataSource HotelList];
    
    self.mTravelLabel.text = @"";
    self.mAirlineLabel.text = @"";
    self.mHotelLabel.text = @"";

    locSelectRect = self.mSelectTableView.frame;
    locSelectRectHidden = CGRectMake(0, locSelectRect.origin.y + locSelectRect.size.height + 30, locSelectRect.size.width, locSelectRect.size.height);
    self.mSelectTableView.frame = locSelectRectHidden;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onNextAction:(id)sender {
    NSUserDefaults* pref = [NSUserDefaults standardUserDefaults];
    [[AppDelegate sharedDelegate] showFetchAlert];
    PFUser *user = [PFUser user];
    user.password = [pref objectForKey:PREF_PASSWORD];
    user.email = [[pref objectForKey:PREF_EMAIL] lowercaseString];
    user.username = [[pref objectForKey:PREF_EMAIL] lowercaseString];
    [user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        [[AppDelegate sharedDelegate] dissmissFetchAlert];
        if (!error) {
            [self onRoamerSave];
        } else {
            if(error.code == 202)
                [self showAlertMessage:@"Error" message:@"Account already exists."];
            else
                [self showAlertMessage:@"Error" message:@"Unable to create user."];
        }
    }];
}

- (void)onRoamerSave {
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    
    [prefs setObject:[NSNumber numberWithInt:travelInt] forKey:PREF_TRAVEL_LEVEL];
    [prefs setObject:[NSNumber numberWithInt:airlineInt] forKey:PREF_AIRLINE];
    [prefs setObject:[NSNumber numberWithInt:hotelInt] forKey:PREF_HOTEL];
    [prefs synchronize];

    
    NSUserDefaults* pref = [NSUserDefaults standardUserDefaults];
    
    NSInteger gender = [pref integerForKey:PREF_GENDER];
    
    PFObject *roamers = [PFObject objectWithClassName:@"Roamer"];
    roamers[@"Air"] = [pref objectForKey:PREF_AIRLINE];
    roamers[@"Airline"] = [pref objectForKey:PREF_AIRLINE];
    roamers[@"CurrentLocation"] = [NSNumber numberWithInt:0];
    roamers[@"Email"] = [[pref objectForKey:PREF_EMAIL] lowercaseString];
    roamers[@"Hotel"] = [pref objectForKey:PREF_HOTEL];
    roamers[@"Industry"] = [pref objectForKey:PREF_INDUSTRY];
    roamers[@"LoginCount"] = [NSNumber numberWithInt:0];
    //    roamers[@"Job"] = [pref objectForKey:PREF_JOB];
    roamers[@"Location"] = [pref objectForKey:PREF_REGION];
    if(gender == 0)
        roamers[@"Male"] = [NSNumber numberWithBool:true];
    else
        roamers[@"Male"] = [NSNumber numberWithBool:false];
    roamers[@"Password"] = [pref objectForKey:PREF_PASSWORD];
    roamers[@"Travel"] = [pref objectForKey:PREF_TRAVEL_LEVEL];
    roamers[@"Username"] = [pref objectForKey:PREF_USERNAME];
    
    if(self.profilePic != nil){
        NSData *imageData = UIImagePNGRepresentation(self.profilePic);
        NSString* fileName = [NSString stringWithFormat:@"%@.png",[pref objectForKey:PREF_USERNAME]];
        PFFile *imageFile = [PFFile fileWithName:fileName data:imageData];
        roamers[@"Pic"] = imageFile;
    } else {
        NSData *imageData = UIImagePNGRepresentation([UIImage imageNamed:@"default_userpic.png"]);
        NSString* fileName = [NSString stringWithFormat:@"%@.png",[pref objectForKey:PREF_USERNAME]];
        PFFile *imageFile = [PFFile fileWithName:fileName data:imageData];
        roamers[@"Pic"] = imageFile;        
    }
    [[AppDelegate sharedDelegate] showFetchAlert];
    [roamers saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        [[AppDelegate sharedDelegate] dissmissFetchAlert];
            if (!error) {
                PFInstallation *currentInstallation = [PFInstallation currentInstallation];
                [currentInstallation addUniqueObject:roamers[@"Username"] forKey:@"channels"];
                [currentInstallation saveInBackground];

                UserProfileHelper* helper = [UserProfileHelper sharedUserProfileHelper];
                NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
                
                [prefs setObject:[roamers objectId] forKey:PREF_USER_OBJECT_ID];
                int loc = [roamers[@"CurrentLocation"] intValue];
                [prefs setInteger:loc forKey:PREF_CURRENT_LOC_INT];
                [prefs setObject:[helper getCurrentLocString:loc] forKey:PREF_CURRENT_LOC_STRING];
                [prefs synchronize];

                [self showAlertMessage:@"Confirmation!!!" message:@"Roamer created successfully."];
            [self.delegate performFinishedAction:self];
        } else {
            [self showAlertMessage:@"Error!!!" message:@"Error Creating User."];
        }
    }];

    
}

- (void) showAlertMessage:(NSString *)title message:(NSString *)msg {
    UIAlertView *errorAlert = [[UIAlertView alloc]
                               initWithTitle:title message:msg delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [errorAlert show];
}

- (IBAction)onPrevAction:(id)sender {
    [self dismissViewControllerAnimated:true completion:nil];
}

- (IBAction)onTravelSelectAction:(id)sender {
    currentButton = TRAVEL_SELECT;
    [self.mTableView reloadData];
    [self slideInLocViewAnimation];
}

- (IBAction)onAirlineSelectAction:(id)sender {
    currentButton = AIRLINE_SELECT;
    [self.mTableView reloadData];
    [self slideInLocViewAnimation];
}

- (IBAction)onHotelSelectAction:(id)sender {
    currentButton = HOTEL_SELECT;
    [self.mTableView reloadData];
    [self slideInLocViewAnimation];
}

- (void) slideInLocViewAnimation {
    if(currentButton == TRAVEL_SELECT) {
        self.mViewTitleLabel.text = @"Select Travel Level";
    } else if(currentButton == AIRLINE_SELECT) {
        self.mViewTitleLabel.text = @"Select Airline";
    } else if(currentButton == HOTEL_SELECT) {
        self.mViewTitleLabel.text = @"Select Hotel";
    }

    self.mSelectTableView.frame = locSelectRectHidden;
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:0.6f];
    self.mSelectTableView.frame = locSelectRect;
	[UIView commitAnimations];
}

- (void) slideOutLocViewAnimation {
    self.mSelectTableView.frame = locSelectRect;
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:0.6f];
    self.mSelectTableView.frame = locSelectRectHidden;
	[UIView commitAnimations];
}

#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
//    if ([segue.identifier isEqualToString:@"performCreatAcct3"]) {
//    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(currentButton == TRAVEL_SELECT) {
        return [travelArray count];
    } else if(currentButton == AIRLINE_SELECT) {
        return [airlineArray count];
    } else if(currentButton == HOTEL_SELECT) {
        return [hotelArray count];
    }
    return [travelArray count];
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"DataCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    if(currentButton == TRAVEL_SELECT) {
        cell.textLabel.text = travelArray[indexPath.row][@"name"];
    } else if(currentButton == AIRLINE_SELECT) {
        cell.textLabel.text = airlineArray[indexPath.row][@"name"];
    } else if(currentButton == HOTEL_SELECT) {
        cell.textLabel.text = hotelArray[indexPath.row][@"name"];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if(currentButton == TRAVEL_SELECT) {
        self.mTravelLabel.text = travelArray[indexPath.row][@"name"];
        travelInt = [travelArray[indexPath.row][@"value"] intValue];
    } else if(currentButton == AIRLINE_SELECT) {
        self.mAirlineLabel.text = airlineArray[indexPath.row][@"name"];
        airlineInt = [airlineArray[indexPath.row][@"value"] intValue];
    } else if(currentButton == HOTEL_SELECT) {
        self.mHotelLabel.text = hotelArray[indexPath.row][@"name"];
        hotelInt = [hotelArray[indexPath.row][@"value"] intValue];
    }
    [self slideOutLocViewAnimation];
}

@end
