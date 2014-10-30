//
//  EditProfileStep3ViewCtrl.m
//  Roamer
//
//  Created by Rajesh Mehta on 6/18/14.
//
//

#import "EditProfileStep3ViewCtrl.h"
#import "MyAppConstants.h"
#import "UserProfileHelper.h"
#import "DataSource.h"
#import "AppDelegate.h"

#define TRAVEL_SELECT                      2
#define AIRLINE_SELECT                  3
#define HOTEL_SELECT                    4

@interface EditProfileStep3ViewCtrl () {
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

@implementation EditProfileStep3ViewCtrl

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

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    
    travelInt = [[prefs objectForKey:PREF_TRAVEL_LEVEL] intValue];
    self.mTravelLabel.text = [self getStringFromInt:travelInt arrayList:travelArray];
    airlineInt = [[prefs objectForKey:PREF_AIRLINE] intValue];
    self.mAirlineLabel.text = [self getStringFromInt:airlineInt arrayList:airlineArray];
    hotelInt = [[prefs objectForKey:PREF_HOTEL] intValue];
    self.mHotelLabel.text = [self getStringFromInt:hotelInt arrayList:hotelArray];
    
}

- (NSString *) getStringFromInt:(int)val arrayList:(NSArray *)arrays {
    NSString* str = @"Not Selected";
    for(NSDictionary* dict in arrays) {
        if(val == [dict[@"value"] intValue]){
            str = dict[@"name"];
            break;
        }
    }
    return str;
}

- (IBAction)onNextAction:(id)sender {
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    
    [prefs setObject:[NSNumber numberWithInt:travelInt] forKey:PREF_TRAVEL_LEVEL];
    [prefs setObject:[NSNumber numberWithInt:airlineInt] forKey:PREF_AIRLINE];
    [prefs setObject:[NSNumber numberWithInt:hotelInt] forKey:PREF_HOTEL];
    [prefs synchronize];
    
    //    UserProfileHelper* helper = [UserProfileHelper sharedUserProfileHelper];
    //    [helper saveToParse:self.profilePic];
    NSUserDefaults* pref = [NSUserDefaults standardUserDefaults];
    
    self.userRoamer[@"Air"] = [pref objectForKey:PREF_AIRLINE];
    self.userRoamer[@"Job"] = [pref objectForKey:PREF_JOB];
    self.userRoamer[@"Airline"] = [pref objectForKey:PREF_AIRLINE];
    self.userRoamer[@"Email"] = [pref objectForKey:PREF_EMAIL];
    self.userRoamer[@"Hotel"] = [pref objectForKey:PREF_HOTEL];
    self.userRoamer[@"Industry"] = [pref objectForKey:PREF_INDUSTRY];
    self.userRoamer[@"Location"] = [pref objectForKey:PREF_REGION];
    self.userRoamer[@"Password"] = [pref objectForKey:PREF_PASSWORD];
    self.userRoamer[@"Travel"] = [pref objectForKey:PREF_TRAVEL_LEVEL];
    
    if(self.profilePic != nil ) {
        NSData *imageData = UIImagePNGRepresentation(self.profilePic);
        NSString* fileName = [NSString stringWithFormat:@"%@.png",[pref objectForKey:PREF_USERNAME]];
        PFFile *imageFile = [PFFile fileWithName:fileName data:imageData];
        self.userRoamer[@"Pic"] = imageFile;
    }
    
    [[AppDelegate sharedDelegate] showFetchAlert];
    
    PFUser* user = [PFUser currentUser];
    user.password = [pref objectForKey:PREF_PASSWORD];
    user.email = [[pref objectForKey:PREF_EMAIL] lowercaseString];
    user.username = [[pref objectForKey:PREF_EMAIL] lowercaseString];
    [user save];
    
    [self.userRoamer saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        [[AppDelegate sharedDelegate] dissmissFetchAlert];
        if (!error) {
            [self showAlertMessage:@"Confirmed!" message:@"Roamer changes saved successfully."];
            [self.delegate returnFromEditProfileStep3:self];
        } else {
            [self showAlertMessage:@"Error!" message:@"Error saving changed data."];
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
