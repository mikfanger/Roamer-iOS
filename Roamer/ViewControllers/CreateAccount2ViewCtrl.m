//
//  CreateAccount2ViewCtrl.m
//  Roamer
//
//  Created by Mac Home on 2/24/14.
//
//

#import "CreateAccount2ViewCtrl.h"
#import <MobileCoreServices/UTCoreTypes.h>
#import "MyAppConstants.h"
#import "DataSource.h"

#define INDUSTRY_SELECT                 1
#define LOCAL_SELECT                    2
#define JOB_SELECT                      3

@interface CreateAccount2ViewCtrl () {
    NSArray *industryArray;
    NSArray *jobArray;
    NSArray *locationArray;
    CGRect  locSelectRect;
    CGRect  locSelectRectHidden;
    int industryInt;
    int locationInt;
    int jobInt;
    int currentButton;
    UIImage* profileImage;
    BOOL fromImagePicker;
}

@end

@implementation CreateAccount2ViewCtrl

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
    
    fromImagePicker = FALSE;
    
    locationArray = [DataSource ProfileLocList];
    self.mLocationLabel.text = @"";
    
    industryArray = [DataSource IndustryList];
    self.mIndustryLabel.text = @"";
    
    jobArray = [DataSource JobList];
    self.mJobLabel.text = @"";
    
    locSelectRect = self.mLocTableView.frame;
    locSelectRectHidden = CGRectMake(0, locSelectRect.origin.y + locSelectRect.size.height + 30, locSelectRect.size.width, locSelectRect.size.height);
    self.mLocTableView.frame = locSelectRectHidden;
    
    profileImage = [UIImage imageNamed:@"default_userpic.png"];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if(!fromImagePicker){
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        if([prefs objectForKey:PREF_REGION]){
            locationInt = [[prefs objectForKey:PREF_REGION] intValue];
            self.mLocationLabel.text = [self getStringFromInt:locationInt arrayList:locationArray];
            industryInt = [[prefs objectForKey:PREF_INDUSTRY] intValue];
            self.mIndustryLabel.text = [self getStringFromInt:industryInt arrayList:industryArray];
            jobInt = [[prefs objectForKey:PREF_JOB] intValue];
            self.mJobLabel.text = [self getStringFromInt:jobInt arrayList:jobArray];
            profileImage = [self readImageFromPref];
            self.mProfileImgView.image = profileImage;
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onNextAction:(id)sender {
    NSString* industry = self.mIndustryLabel.text;
    NSString* location = self.mLocationLabel.text;
    NSString* job = self.mJobLabel.text;
    
    if ([industry isEqualToString:@""]) {
        [self showAlertMessage:@"Error!" message:@"Industry is required field!"];
        return;
    }

    if ([location isEqualToString:@""]) {
        [self showAlertMessage:@"Error!" message:@"Home Region is required field!"];
        return;
    }
    if ([job isEqualToString:@""]) {
        [self showAlertMessage:@"Error!" message:@"Job is required field!"];
        return;
    }
    


    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    
    [prefs setObject:[NSNumber numberWithInt:locationInt] forKey:PREF_REGION];
    [prefs setObject:[NSNumber numberWithInt:industryInt] forKey:PREF_INDUSTRY];
    [prefs setObject:[NSNumber numberWithInt:jobInt] forKey:PREF_JOB];
    [prefs synchronize];

    [self performSegueWithIdentifier:@"performCreatAcct3" sender:self];
}

- (IBAction)onSelectLocAction:(id)sender {
    currentButton = LOCAL_SELECT;
    [self.mTableView reloadData];
    [self slideInLocViewAnimation];
}

- (IBAction)onPrevAction:(id)sender {
    [self dismissViewControllerAnimated:true completion:nil];
}

- (IBAction)onIndustrySelectAction:(id)sender {
    currentButton = INDUSTRY_SELECT;
    [self.mTableView reloadData];
    [self slideInLocViewAnimation];
}

- (IBAction)onJobSelectAction:(id)sender {
    currentButton = JOB_SELECT;
    [self.mTableView reloadData];
    [self slideInLocViewAnimation];
}


- (void) showAlertMessage:(NSString *)title message:(NSString *)msg {
    UIAlertView *errorAlert = [[UIAlertView alloc]
                               initWithTitle:title message:msg delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [errorAlert show];
}

- (IBAction)onSelectImgAction:(id)sender {
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum])
    {
        UIImagePickerController *imagePickerAlbum =[[UIImagePickerController alloc] init];
        imagePickerAlbum.delegate = self;
        imagePickerAlbum.mediaTypes = [NSArray arrayWithObjects:(NSString *) kUTTypeImage,nil];
        imagePickerAlbum.allowsEditing = YES;
        imagePickerAlbum.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        fromImagePicker = TRUE;
        [self presentViewController:imagePickerAlbum animated:YES completion:nil];
    }
}


- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    UIImage *chosenImage = info[UIImagePickerControllerEditedImage];
    profileImage = chosenImage;
    self.mProfileImgView.image = profileImage;
    [self saveImageToPref:profileImage];
    
    [picker dismissViewControllerAnimated:YES completion:^{
        fromImagePicker = FALSE;
    }];
    
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
}

- (void) saveImageToPref:(UIImage *)image {
    // Get image data. Here you can use UIImagePNGRepresentation if you need transparency
    NSData *imageData = UIImagePNGRepresentation(image);
    
    // Get image path in user's folder and store file with name image_CurrentTimestamp.jpg (see documentsPathForFileName below)
    NSString *imagePath = [self documentsPathForFileName:[NSString stringWithFormat:@"image_111.png"]];
    
    // Write image data to user's folder
    [imageData writeToFile:imagePath atomically:YES];
    
    // Store path in NSUserDefaults
    [[NSUserDefaults standardUserDefaults] setObject:imagePath forKey:PREF_PROFILE_IMG];
    
    // Sync user defaults
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (UIImage *) readImageFromPref {
    NSString *imagePath = [[NSUserDefaults standardUserDefaults] objectForKey:PREF_PROFILE_IMG];
    if (imagePath) {
        return [UIImage imageWithData:[NSData dataWithContentsOfFile:imagePath]];
    } else {
        return [UIImage imageNamed:@"default_userpic.png"];
    }
}

- (NSString *)documentsPathForFileName:(NSString *)name {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsPath = [paths objectAtIndex:0];
    
    return [documentsPath stringByAppendingPathComponent:name];
}

- (NSString *) getStringFromInt:(int)val arrayList:(NSArray *)arrays {
    NSString* str;
    for(NSDictionary* dict in arrays) {
        if(val == [dict[@"value"] intValue]){
            str = dict[@"name"];
            break;
        }
    }
    return str;
}

- (void) slideInLocViewAnimation {
    if(currentButton == INDUSTRY_SELECT){
        self.mViewTitleLabel.text = @"Select Industry";
    } else if(currentButton == LOCAL_SELECT){
            self.mViewTitleLabel.text = @"Select Region";
    } else if(currentButton == JOB_SELECT){
        self.mViewTitleLabel.text = @"Select Position";
    }
    
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

- (void)performFinishedAction:(CreateAccountPicViewCtrl *)viewCtrl {
    [self dismissViewControllerAnimated:NO completion:^{
        [self.delegate performFinishedAction:self];
    }];
}

#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"performCreatAcct3"]) {
        CreateAccountPicViewCtrl *friendsVC = segue.destinationViewController;
        if(profileImage != nil){
            friendsVC.profilePic = profileImage;
        }
        friendsVC.delegate = self;
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
    if(currentButton == INDUSTRY_SELECT){
        return [industryArray count];
    } else if(currentButton == LOCAL_SELECT) {
        return [locationArray count];
    } else if(currentButton == JOB_SELECT) {
        return [jobArray count];
    }
    
    return [industryArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"DataCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    if(currentButton == INDUSTRY_SELECT){
        cell.textLabel.text = industryArray[indexPath.row][@"name"];
    } else if(currentButton == LOCAL_SELECT) {
        cell.textLabel.text = locationArray[indexPath.row][@"name"];
    } else if(currentButton == JOB_SELECT) {
        cell.textLabel.text = jobArray[indexPath.row][@"name"];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if(currentButton == INDUSTRY_SELECT){
        self.mIndustryLabel.text = industryArray[indexPath.row][@"name"];
        industryInt = [industryArray[indexPath.row][@"value"] intValue];
    } else if(currentButton == LOCAL_SELECT) {
        self.mLocationLabel.text = locationArray[indexPath.row][@"name"];
        locationInt = [locationArray[indexPath.row][@"value"] intValue];
    } else if(currentButton == JOB_SELECT) {
        self.mJobLabel.text = jobArray[indexPath.row][@"name"];
        jobInt = [jobArray[indexPath.row][@"value"] intValue];
    }
    
    [self slideOutLocViewAnimation];
}


/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"DataCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    cell.textLabel.text = locationArray[indexPath.row][@"name"];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    self.mLocationLabel.text = locationArray[indexPath.row][@"name"];
    locationInt = [locationArray[indexPath.row][@"value"] intValue];
    [self slideOutLocViewAnimation];
}
*/
@end
