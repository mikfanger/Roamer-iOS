//
//  RoamerProfileViewCtrl.m
//  Roamer
//
//  Created by Mac Home on 3/10/14.
//
//

#import "RoamerProfileViewCtrl.h"
#import "MyAppConstants.h"
#import "DataSource.h"

@interface RoamerProfileViewCtrl () {
    NSArray *travelStatusArray;
}

@end

@implementation RoamerProfileViewCtrl

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

    travelStatusArray = [DataSource TravelStatusList];

}


- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.extendedProfileView.hidden = false;
    self.mTravelStatusLabel.text = [self getStringFromInt:[self.currentRoamer[@"Travel"] intValue] arrayList:travelStatusArray];

    self.mAddRemoveButton.enabled = TRUE;

    if(self.hideAddRemoveButton){
        self.mAddRemoveButton.hidden = TRUE;
    } else {
        self.mAddRemoveButton.hidden = FALSE;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onRemoveRoamer:(id)sender {
//    self.currentRoamer.ismyroamer = [NSNumber numberWithInt:NOT_IN_MY_ROAMER];
    
//    NSError *error;
//    if (![self.currentRoamer.managedObjectContext save:&error]) {
//        NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
//    }
    [self.delegate performBackAction:self];
}
@end
