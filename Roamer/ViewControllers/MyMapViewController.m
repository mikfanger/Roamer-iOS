//
//  MyMapViewController.m
//  Roamer
//
//  Created by Mac Home on 6/6/14.
//
//

#import "MyMapViewController.h"
#import "LocationController.h"
#import "MyAppConstants.h"
#import "DataSource.h"
#import "MapDataPoint.h"
#import "DDAnnotationView.h"
#import "DDAnnotation.h"

#define METERS_PER_MILE 1609.344
#define kGOOGLE_API_KEY @"AIzaSyCMO_9EWAfU83za9plSDNxBaUSd_o0R0og"
#define kBgQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)

@interface MyMapViewController () {
    CLPlacemark *foundedPlace;
    CGRect  viewSelectRect;
    CGRect  viewSelectRectHidden;
    NSArray *placesArray;
    NSString* searchString;
    
    NSString* selectedName;
    NSString* selectedAddress;

}

@end

@implementation MyMapViewController

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
    placesArray = [[NSMutableArray alloc] init];
    placesArray = [DataSource PlacesList];

    viewSelectRect = self.mSelectView.frame;
    viewSelectRectHidden = CGRectMake(0, viewSelectRect.origin.y + viewSelectRect.size.height + 30, viewSelectRect.size.width, viewSelectRect.size.height);
    self.mSelectView.frame = viewSelectRectHidden;
    
//    self.mPlacesLabel.text = @"Tap to select";

    searchString = @"";
    selectedName = @"";
    selectedAddress = @"";

    UIToolbar* numberToolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, 320, 50)];
    numberToolbar.barStyle = UIBarStyleBlackTranslucent;
    numberToolbar.items = [NSArray arrayWithObjects:
                            [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],                            [[UIBarButtonItem alloc]initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(doneWithNumberPad)],

                            //                           [[UIBarButtonItem alloc]initWithTitle:@"" style:UIBarButtonItemStyleBordered target:self action:@selector(cancelNumberPad)],
                            nil];
    [numberToolbar sizeToFit];
    _mPlacesLabel.inputAccessoryView = numberToolbar;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [prefs removeObjectForKey:@"ChangedNewLoc"];
    [prefs synchronize];

    NSUserDefaults* pref = [NSUserDefaults standardUserDefaults];
//    NSString* loc = [pref objectForKey:PREF_CURRENT_LOC_STRING];
    double latitude = [pref doubleForKey:PREF_CURRENT_LOC_GEO_LAT];
    double longitude = [pref doubleForKey:PREF_CURRENT_LOC_GEO_LONG];

    
//    [[LocationController sharedLocationController] updateLocationWithAddress:loc completion:^(BOOL finished, CLPlacemark *place) {
//        if (finished==FALSE) {
//            [self showAlertMessage:@"Error" message:@"City not found!!!"];
//            return ;
//        }
//        else
//        {
//            foundedPlace=place;
        CLLocationCoordinate2D zoomLocation = CLLocationCoordinate2DMake(latitude, longitude);
    CLLocation* loc = [[CLLocation alloc] initWithLatitude:latitude longitude:longitude];

    DDAnnotation *annotation = [[DDAnnotation alloc] initWithCoordinate:loc title:@"Hold and Drag to move Pin"];
    
    NSArray * annotations = [self.mMapView annotations];
    [self.mMapView removeAnnotations:annotations];

            MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(zoomLocation, 2 * METERS_PER_MILE, 2 *METERS_PER_MILE);
            [self.mMapView setRegion:viewRegion animated:YES];
    [self.mMapView addAnnotation:annotation];
//        }
//    }];

    
}

-(void)doneWithNumberPad{
    [_mPlacesLabel resignFirstResponder];
    
    [_mScrollView setContentOffset: CGPointMake(0, 0) animated:YES];
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

- (IBAction)onSearchAction:(id)sender {
    searchString = _mPlacesLabel.text;
    if((searchString == nil) || [searchString isEqualToString:@""]){
        [self showAlertMessage:@"Error!!!" message:@"Please select valid search place."];
    } else
        [self queryGooglePlaces:searchString];
}

- (IBAction)onCancelAction:(id)sender {
    [self.delegate cancelMyMapViewSelectorView:self];
}

- (IBAction)onSelectPlaceAction:(id)sender {
    [self slideInLocViewAnimation];
}

- (void) slideInLocViewAnimation {
    self.mSelectViewLabel.text = @"Select Place";

    self.mSelectView.frame = viewSelectRectHidden;
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:0.6f];
    self.mSelectView.frame = viewSelectRect;
	[UIView commitAnimations];
}

- (void) slideOutLocViewAnimation {
    self.mSelectView.frame = viewSelectRect;
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:0.6f];
    self.mSelectView.frame = viewSelectRectHidden;
	[UIView commitAnimations];
}

-(void) queryGooglePlaces: (NSString *) googleType {
    NSUserDefaults* pref = [NSUserDefaults standardUserDefaults];
    //    NSString* loc = [pref objectForKey:PREF_CURRENT_LOC_STRING];
    double latitude = [pref doubleForKey:PREF_CURRENT_LOC_GEO_LAT];
    double longitude = [pref doubleForKey:PREF_CURRENT_LOC_GEO_LONG];

    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    if([prefs objectForKey:@"ChangedNewLoc"]){
        CLLocationCoordinate2D loc = [[LocationController sharedLocationController] getTempPoint];
        latitude = loc.latitude;
        longitude = loc.longitude;
    }

    
    // Build the url string to send to Google. NOTE: The kGOOGLE_API_KEY is a constant that should contain your own API key that you obtain from Google. See this link for more info:
    // https://developers.google.com/maps/documentation/places/#Authentication
    NSString *url = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=%f,%f&radius=%@&types=%@&sensor=true&key=%@", latitude, longitude, [NSString stringWithFormat:@"%f", 300.0f], googleType, kGOOGLE_API_KEY];
    
    //Formulate the string as a URL object.
    NSURL *googleRequestURL=[NSURL URLWithString:url];
    
    // Retrieve the results of the URL.
    dispatch_async(kBgQueue, ^{
        NSData* data = [NSData dataWithContentsOfURL: googleRequestURL];
        [self performSelectorOnMainThread:@selector(fetchedData:) withObject:data waitUntilDone:YES];
    });
}

-(void)fetchedData:(NSData *)responseData {
    //parse out the json data
    NSError* error;
    NSDictionary* json = [NSJSONSerialization
                          JSONObjectWithData:responseData
                          
                          options:kNilOptions
                          error:&error];
    
    //The results from Google will be an array obtained from the NSDictionary object with the key "results".
    NSArray* places = [json objectForKey:@"results"];
    //Write out the data to the console.
    NSLog(@"Google Data: %@", places);

    [self plotPositions:places];
}

-(void)plotPositions:(NSArray *)data {
    // Remove any existing annotations
    for (id<MKAnnotation> annotation in self.mMapView.annotations) {
        if ([annotation isKindOfClass:[MapDataPoint class]]) {
            [self.mMapView removeAnnotation:annotation];
        }
    }
    // Loop through the array of places returned from the Google API.
    for (int i=0; i<[data count]; i++) {
        //Retrieve the NSDictionary object in each index of the array.
        NSDictionary* place = [data objectAtIndex:i];
        // 3 - There is a specific NSDictionary object that gives us the location info.
        NSDictionary *geo = [place objectForKey:@"geometry"];
        // Get the lat and long for the location.
        NSDictionary *loc = [geo objectForKey:@"location"];
        // 4 - Get your name and address info for adding to a pin.
        NSString *name=[place objectForKey:@"name"];
        NSString *vicinity=[place objectForKey:@"vicinity"];
        // Create a special variable to hold this coordinate info.
        CLLocationCoordinate2D placeCoord;
        // Set the lat and long.
        placeCoord.latitude=[[loc objectForKey:@"lat"] doubleValue];
        placeCoord.longitude=[[loc objectForKey:@"lng"] doubleValue];
        // 5 - Create a new annotation.
        MapDataPoint *placeObject = [[MapDataPoint alloc] initWithName:name address:vicinity coordinate:placeCoord];
        [self.mMapView addAnnotation:placeObject];
    }
}

#pragma mark - MKMapViewDelegate

-(MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation {
    // Define your reuse identifier.
    static NSString *identifier = @"MapPoint";
    
    if ([annotation isKindOfClass:[MapDataPoint class]]) {
        MKPinAnnotationView *annotationView = (MKPinAnnotationView *) [self.mMapView dequeueReusableAnnotationViewWithIdentifier:identifier];
        if (annotationView == nil) {
            annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
        } else {
            annotationView.annotation = annotation;
        }
        annotationView.enabled = YES;
        annotationView.canShowCallout = YES;
        annotationView.animatesDrop = YES;
        annotationView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeContactAdd];
        return annotationView;
    } else if ([annotation isKindOfClass:[DDAnnotation class]]) {
        DDAnnotationView *annotationView = (DDAnnotationView *)[self.mMapView dequeueReusableAnnotationViewWithIdentifier:@"Pin"];
        if (annotationView == nil) {
            annotationView = [[DDAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"Pin"];
        }
        // Dragging annotation will need _mapView to convert new point to coordinate;
        annotationView.mapView = self.mMapView;
        
        return annotationView;
    }
    
    return nil;
}

//-(void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view {
//    MapDataPoint *location = (MapDataPoint *) view.annotation;
//    NSLog(@"Location tapped: %@", location.address);
//}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control {
    MapDataPoint *location = (MapDataPoint *) view.annotation;
    NSLog(@"Location tapped: %@", location.address);
    
    selectedName = location.name;
    selectedAddress = location.address;

    NSString* str = [NSString stringWithFormat:@"Are you sure you want:%@ : %@?",location.name, location.address];
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Confirmation!!!" message:str delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
    
    alertView.tag = 101;
    
    [alertView show];

}

#pragma mark - UIAlertView Delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == 101) {
        if (buttonIndex == 0) {
            
        } else {
            [self.delegate selectMyMapViewSelectorView:self name:selectedName address:selectedAddress];
        }
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [placesArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"DataCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    cell.textLabel.text = placesArray[indexPath.row][@"name"];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    self.mPlacesLabel.text = placesArray[indexPath.row][@"name"];
    searchString = placesArray[indexPath.row][@"search"];
//    timeInt = [placesArray[indexPath.row][@"value"] intValue];
    [self slideOutLocViewAnimation];
}


- (void)textFieldDidBeginEditing:(UITextField *)textField {
    if (textField == _mPlacesLabel) {
        [_mScrollView setContentOffset: CGPointMake(0, 300) animated:YES];
    } 
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    [_mScrollView setContentOffset: CGPointMake(0, 0) animated:YES];
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    [textField resignFirstResponder];
    [_mScrollView setContentOffset: CGPointMake(0, 0) animated:YES];
}


@end
