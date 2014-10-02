//
//  EditProfileStep2ViewCtrl.m
//  Roamer
//
//  Created by Rajesh Mehta on 6/18/14.
//
//

#import "EditProfileStep2ViewCtrl.h"
#import <MobileCoreServices/UTCoreTypes.h>
#import "MyAppConstants.h"
#import "DataSource.h"

#define INDUSTRY_SELECT                 1
#define LOCAL_SELECT                    2

@interface EditProfileStep2ViewCtrl () {
    NSArray *industryArray;
    NSArray *locationArray;
    CGRect  locSelectRect;
    CGRect  locSelectRectHidden;
    int industryInt;
    int locationInt;
    int currentButton;
}

@end

@implementation EditProfileStep2ViewCtrl

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
    locationArray = [DataSource ProfileLocList];
    self.mLocationLabel.text = locationArray[0][@"name"];
    
    industryArray = [DataSource IndustryList];
    self.mIndustryLabel.text = @"";
    
    locSelectRect = self.mLocTableView.frame;
    locSelectRectHidden = CGRectMake(0, locSelectRect.origin.y + locSelectRect.size.height + 30, locSelectRect.size.width, locSelectRect.size.height);
    self.mLocTableView.frame = locSelectRectHidden;
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    
    locationInt = [[prefs objectForKey:PREF_REGION] intValue];
    self.mLocationLabel.text = [self getStringFromInt:locationInt arrayList:locationArray];
    industryInt = [[prefs objectForKey:PREF_INDUSTRY] intValue];
    self.mIndustryLabel.text = [self getStringFromInt:industryInt arrayList:industryArray];
    
    if(self.profilePic != nil )
        self.mProfileImgView.image = self.profilePic;

}

- (IBAction)onNextAction:(id)sender {
    NSString* industry = self.mIndustryLabel.text;
    
    if ([industry isEqualToString:@""]) {
        [self showAlertMessage:@"Error!!!" message:@"Industry is required field!"];
        return;
    }
    
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    
    [prefs setObject:[NSNumber numberWithInt:locationInt] forKey:PREF_REGION];
    [prefs setObject:[NSNumber numberWithInt:industryInt] forKey:PREF_INDUSTRY];
    [prefs synchronize];
    
    [self performSegueWithIdentifier:@"showEditProfileStep3" sender:self];
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
        
        [self presentViewController:imagePickerAlbum animated:YES completion:nil];
    }
}


- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    UIImage *chosenImage = info[UIImagePickerControllerEditedImage];
    self.profilePic = chosenImage;
    self.mProfileImgView.image = self.profilePic;
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
}


- (void) slideInLocViewAnimation {
    if(currentButton == INDUSTRY_SELECT){
        self.mViewTitleLabel.text = @"Select Industry";
    } else if(currentButton == LOCAL_SELECT){
        self.mViewTitleLabel.text = @"Select Location";
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

- (void)returnFromEditProfileStep3:(EditProfileStep3ViewCtrl *)viewCtrl {
    [self dismissViewControllerAnimated:NO completion:^{
        [self.delegate returnFromEditProfileStep2:self];
    }];
}

#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"showEditProfileStep3"]) {
        EditProfileStep3ViewCtrl *friendsVC = segue.destinationViewController;
        friendsVC.profilePic = self.profilePic;
        friendsVC.userRoamer = self.userRoamer;
        friendsVC.delegate = self;
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
        locationInt = [industryArray[indexPath.row][@"value"] intValue];
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
