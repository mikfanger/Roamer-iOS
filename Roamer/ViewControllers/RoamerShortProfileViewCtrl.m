//
//  RoamerShortProfileViewCtrl.m
//  Roamer
//
//  Created by Mac Home on 3/7/14.
//
//

#import "RoamerShortProfileViewCtrl.h"
#import "MyAppConstants.h"
#import "DataSource.h"

@interface RoamerShortProfileViewCtrl () {
    NSArray *locationArray;
    NSArray *hotelArray;
    NSArray *jobArray;
    NSArray *airlineArray;

}

@end

@implementation RoamerShortProfileViewCtrl

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


- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    locationArray = [DataSource ProfileLocList];
    hotelArray = [DataSource HotelList];
    jobArray = [DataSource IndustryList];
    airlineArray = [DataSource AirlineList];

    self.extendedProfileView.hidden = FALSE;

    NSDateFormatter* monDateFormatter = [[NSDateFormatter alloc] init];
    [monDateFormatter setDateFormat:@"MM/dd/yyyy"];

    NSDate* createdAt = self.currentRoamer.createdAt;
    
    self.mRoamSinceDateLabel.text = [monDateFormatter stringFromDate:createdAt] ;
    self.mNameLabel.text = self.currentRoamer[@"Username"];
    if([self.currentRoamer[@"Male"] boolValue])
        self.mGenderLabel.text = @"Male";
    else
        self.mGenderLabel.text = @"Female";
    self.mJobPositionLabel.text = [self getStringFromInt:[self.currentRoamer[@"Job"] intValue] arrayList:jobArray];
    self.mLocationLabel.text = [self getStringFromInt:[self.currentRoamer[@"Location"] intValue] arrayList:locationArray];
    self.mHotelPrefLabel.text = [self getStringFromInt:[self.currentRoamer[@"Hotel"] intValue] arrayList:hotelArray];
    self.mAirlineLabel.text = [self getStringFromInt:[self.currentRoamer[@"Travel"] intValue] arrayList:airlineArray];

    self.mProfileImage.layer.masksToBounds = YES;
    self.mProfileImage.layer.cornerRadius = 8.0; // half height & width
    
    PFFile *userImageFile = self.currentRoamer[@"Pic"];
    [userImageFile getDataInBackgroundWithBlock:^(NSData *imageData, NSError *error) {
        if (!error) {
            UIImage *image = [UIImage imageWithData:imageData];
            self.mProfileImage.image = image;
        }
    }];

    if([self checkIfAddToRoamer]){
        self.mAddRemoveButton.enabled = TRUE;
    } else {
        self.mAddRemoveButton.enabled = FALSE;
    }
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


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onCloseAction:(id)sender {
    [self.delegate performBackAction:self];
}

- (BOOL) checkIfAddToRoamer {
    [self.userRoamer refresh];
    [self.currentRoamer refresh];
    NSString* userName = self.userRoamer[@"Username"];
    NSMutableArray* holdArray = self.currentRoamer[@"Hold"];
    NSMutableArray* myRoamersArray = self.currentRoamer[@"MyRoamers"];
    NSMutableArray* requestForArray = self.currentRoamer[@"Requests"];
    NSMutableArray* requestMyArray = self.userRoamer[@"Requests"];
    
    BOOL notInHold = TRUE;
    BOOL notInMyRoam = TRUE;
    BOOL notInForRequest = TRUE;
    BOOL notInMyRequest = TRUE;
    if((holdArray != nil) && ([holdArray containsObject:userName])){
        notInHold = FALSE;
    }
    
    if((myRoamersArray != nil) && ([myRoamersArray containsObject:userName])){
        notInMyRoam = FALSE;
    }

    if((requestForArray != nil) && ([requestForArray containsObject:userName])){
        notInForRequest = FALSE;
    }

    if((requestMyArray != nil) && ([requestMyArray containsObject:userName])){
        notInMyRequest = FALSE;
    }

    if(notInHold && notInMyRoam && notInForRequest && notInMyRequest) {
        return TRUE;
    } else {
        return FALSE;
    }
}

- (IBAction)onAddRoamerAction:(id)sender {
    [self.userRoamer refresh];
    [self.currentRoamer refresh];
    NSString* userName = self.userRoamer[@"Username"];
    NSMutableArray* holdArray = self.currentRoamer[@"Hold"];
    NSMutableArray* myRoamersArray = self.currentRoamer[@"MyRoamers"];
    
    BOOL notInHold = TRUE;
    BOOL notInMyRoam = TRUE;
    if((holdArray != nil) && ([holdArray containsObject:userName])){
        notInHold = FALSE;
    }

    if((myRoamersArray != nil) && ([myRoamersArray containsObject:userName])){
        notInMyRoam = FALSE;
    }
    
    if(notInHold && notInMyRoam) {
        NSMutableArray* requestArray = self.currentRoamer[@"Requests"];
        if(requestArray == nil){
            requestArray = [[NSMutableArray alloc] init];
        }
        [requestArray addObject:userName];
        self.currentRoamer[@"Requests"] = requestArray;
        [self.currentRoamer saveInBackground];
        
/*        NSMutableArray* myRoamerArray = self.userRoamer[@"MyRoamers"];
        if(myRoamerArray == nil){
            myRoamerArray = [[NSMutableArray alloc] init];
        }
        [myRoamerArray addObject:self.currentRoamer[@"Username"]];
        self.userRoamer[@"MyRoamers"] = myRoamerArray;
        [self.userRoamer saveInBackground]; */

    }

//    self.currentRoamer.ismyroamer = [NSNumber numberWithInt:IN_MY_ROAMER];
    
//    NSError *error;
//    if (![self.currentRoamer.managedObjectContext save:&error]) {
//        NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
//    }
    [self.delegate performBackAction:self];

}
@end
