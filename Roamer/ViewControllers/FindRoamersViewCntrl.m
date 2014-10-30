//
//  FindRoamersViewCntrl.m
//  Roamer
//
//  Created by Mac Home on 3/4/14.
//
//

#import "FindRoamersViewCntrl.h"
#import "FindRoamersCell.h"
#import "AppDelegate.h"
#import "Roamers.h"
#import "DataSource.h"
#import "MyAppConstants.h"

@interface FindRoamersViewCntrl () {
    NSMutableArray *roamersArray;
    NSIndexPath *currentIndex;
    UIImage*  cellBkgImg;

    NSArray *locationArray;
    CGRect  locSelectRect;
    CGRect  locSelectRectHidden;
    
//    NSMutableArray *romaersArray;
}

@end

@implementation FindRoamersViewCntrl

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
    self.mLocationLabel.text = @" All";
    locationArray = [DataSource CurrentLocList];

//    locationArray = @[@"All",@"Dallas",@"Boston",@"Miami",@"Los Angeles"];

    roamersArray = [[NSMutableArray alloc] init];
    
    self.mLocationLabel.layer.cornerRadius = 8.0;
//    [self.mLocationLabel setFont:[UIFont fontWithName:@"CenturyGothic" size:16.0]];
//    [self.mRomersLocLabel setFont:[UIFont fontWithName:@"CenturyGothic" size:16.0]];
    
    locSelectRect = self.mLocTableView.frame;
    locSelectRectHidden = CGRectMake(0, locSelectRect.origin.y + locSelectRect.size.height + 30, locSelectRect.size.width, locSelectRect.size.height);
    self.mLocTableView.frame = locSelectRectHidden;

    roamersArray = [[NSMutableArray alloc] init];
	// Do any additional setup after loading the view.
    self.managedObjectContext = [[AppDelegate sharedDelegate] managedObjectContext];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    NSUserDefaults* pref = [NSUserDefaults standardUserDefaults];
    self.mLocationLabel.text = [pref objectForKey:PREF_CURRENT_LOC_STRING];
    int locInt = (int)[pref integerForKey:PREF_CURRENT_LOC_INT];

    [self fetchRoamersFromDB:locInt];
}

- (NSString *) getLocationFromInt:(int)val {
    NSString* str;
    for(NSDictionary* dict in locationArray) {
        if(val == [dict[@"value"] intValue]){
            str = dict[@"name"];
            break;
        }
    }
    return str;
}

- (void) fetchRoamersFromDB:(int)locInt {
    PFQuery *query = [PFQuery queryWithClassName:@"Roamer"];
    [query whereKey:@"CurrentLocation" equalTo:[NSNumber numberWithInt:locInt]];
    [query whereKey:@"objectId" notEqualTo:self.userRoamer.objectId];
    [query whereKey:@"EmailVerified" equalTo:[NSNumber numberWithInt:1]];
    
    query.limit = 1000;
    [[AppDelegate sharedDelegate] showFetchAlert];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        [[AppDelegate sharedDelegate] dissmissFetchAlert];
        if (!error) {
            [roamersArray removeAllObjects];
            [roamersArray addObjectsFromArray:objects];
            NSLog(@"Successfully retrieved %d roamers.", (int)objects.count);
            [self.mTableView reloadData];
        } else {
            // Log details of the failure
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];

    //    [NSFetchedResultsController deleteCacheWithName:@"FindRoamers"];
//    _fetchedResultsController = nil;

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onBackAction:(id)sender {
    [self.delegate performBackAction:self];
//    [self dismissViewControllerAnimated:true completion:nil];
}

- (IBAction)mPickLocation:(id)sender {
//    [self slideInLocViewAnimation];
}

- (void) slideInLocViewAnimation {
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


- (UIImage *) getBackGroundColor:(int)width height:(int)height {
    if(cellBkgImg != nil)
        return cellBkgImg;
    
    CGSize size = CGSizeMake(width, height);
    UIGraphicsBeginImageContextWithOptions(size, NO, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGColorSpaceRef colorspace = CGColorSpaceCreateDeviceRGB();
    
    size_t gradientNumberOfLocations = 2;
    CGFloat gradientLocations[2] = { 0.0, 1.0 };
    CGFloat gradientComponents[8] = { 0, 0, 0, 1,     // Start color
        25.0/255.0, 25.0/255.0, 25.0/255.0, 1 };  // End color
    
    CGGradientRef gradient = CGGradientCreateWithColorComponents (colorspace, gradientComponents, gradientLocations, gradientNumberOfLocations);
    
    CGContextDrawLinearGradient(context, gradient, CGPointMake(0, 0), CGPointMake(0, size.height), 0);
    
    cellBkgImg = UIGraphicsGetImageFromCurrentImageContext();
    
    CGGradientRelease(gradient);
    CGColorSpaceRelease(colorspace);
    UIGraphicsEndImageContext();

    return cellBkgImg;
}

- (id) checkForNull:(id)obj {
    if([obj isKindOfClass:[NSNull class]])
        return nil;
    
    return obj;
}

#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 100;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if(tableView == self.mLocTable)
        return 1;
    else
        return 1;
//        return [[self.fetchedResultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(tableView == self.mLocTable)
        return [locationArray count];
    else {
//        id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][section];
//        return [sectionInfo numberOfObjects];
        return [roamersArray count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(tableView == self.mLocTable) {
        static NSString *CellIdentifier = @"DataCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
        cell.textLabel.text = locationArray[indexPath.row][@"name"];
    
        return cell;

    }
    
    NSString *CellIdentifier = @"findRoamersCell";
    FindRoamersCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
//    Roamers *roamers = (Roamers *)[self.fetchedResultsController objectAtIndexPath:indexPath];
    PFObject *roamers = roamersArray[indexPath.row];
    
    cell.mCellBkgView.layer.cornerRadius = 8.0; // half height & width
//    [cell.mLocationLabel setFont:[UIFont fontWithName:@"CenturyGothic" size:16.0]];
//    [cell.mNameLabel setFont:[UIFont fontWithName:@"Eurostile-Bold" size:20.0]];

//    cell.mProfileImg.image = roamers.image;
    cell.mProfileImg.layer.masksToBounds = YES;
    cell.mProfileImg.layer.cornerRadius = 8.0; // half height & width
    cell.mNameLabel.text = roamers[@"Username"]; //roamers.name;
//    int val = [roamers[@"CurrentLocation"] intValue];
    cell.mLocationLabel.text = [self getLocationFromInt:[roamers[@"CurrentLocation"] intValue]]; //roamers.location;
    

/*    PFFile *userImageFile = roamers[@"Pic"];
    [userImageFile getDataInBackgroundWithBlock:^(NSData *imageData, NSError *error) {
        if (!error) {
            UIImage *image = [UIImage imageWithData:imageData];
            cell.mProfileImg.image = image;
        }
    }]; */
    
    PFFile *userImageFile = [self checkForNull:roamers[@"Pic"]];
    if(userImageFile == nil){
        cell.mProfileImg.image = [UIImage imageNamed:@"default_userpic.png"];
    } else {
        PFImageView *thumbnailImageView = (PFImageView*)cell.mProfileImg;
        thumbnailImageView.file = userImageFile;
        [thumbnailImageView loadInBackground];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    if(tableView == self.mLocTable) {
        self.mLocationLabel.text = locationArray[indexPath.row];
//        [self fetchRoamersFromDB];
        [self slideOutLocViewAnimation];
        return;
    }
    
    currentIndex = indexPath;
    [self performSegueWithIdentifier:@"showRoamerShortProfile" sender:self];
}


/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */

/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
 {
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
 }
 else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }
 }
 */

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
 {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

#pragma mark - Fetched results controller

- (NSFetchedResultsController *)fetchedResultsController
{
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    } else {
        [NSFetchedResultsController deleteCacheWithName:@"Master"];
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Roamers" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    
    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"location" ascending:YES];
    NSArray *sortDescriptors = @[sortDescriptor];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    NSString* str = [self.mLocationLabel.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if(![str isEqualToString:@"All"]){
        NSPredicate* predicate = [NSPredicate predicateWithFormat:@"location like %@", str];
        [fetchRequest setPredicate:predicate];
    }
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    aFetchedResultsController.delegate = self;
    self.fetchedResultsController = aFetchedResultsController;
    
	NSError *error = nil;
	if (![self.fetchedResultsController performFetch:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
	    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
	    abort();
	}
    
    return _fetchedResultsController;
}

- (void)performBackAction:(RoamerShortProfileViewCtrl *)viewCtrl {
    [self dismissViewControllerAnimated:YES completion:^{
    }];    
}


#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"peformSetting"]) {
    } else if ([segue.identifier isEqualToString:@"showRoamerShortProfile"]) {
        PFObject *roamers = roamersArray[currentIndex.row];
//        Roamers *roamers = (Roamers *)[self.fetchedResultsController objectAtIndexPath:currentIndex];
        RoamerShortProfileViewCtrl *detailVC = segue.destinationViewController;
        detailVC.currentRoamer = roamers;
        detailVC.userRoamer = self.userRoamer;
        detailVC.delegate = self;
    }
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

@end
