//
//  MyRoamersViewCntrl.m
//  Roamer
//
//  Created by Mac Home on 3/10/14.
//
//

#import "MyRoamersViewCntrl.h"
#import "AppDelegate.h"
#import "FindRoamersCell.h"
#import "Roamers.h"
#import "MyAppConstants.h"
#import "DataSource.h"

@interface MyRoamersViewCntrl () {
    NSIndexPath *currentIndex;
    UIImage*  cellBkgImg;
    
    NSMutableArray* roamerArray;
    NSArray *locationArray;
}

@end

@implementation MyRoamersViewCntrl

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
    roamerArray = [[NSMutableArray alloc] init];
    
    self.mLocationLabel.layer.cornerRadius = 8.0;
//    [self.mLocationLabel setFont:[UIFont fontWithName:@"CenturyGothic" size:16.0]];

    self.managedObjectContext = [[AppDelegate sharedDelegate] managedObjectContext];
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    NSUserDefaults* pref = [NSUserDefaults standardUserDefaults];
    self.mLocationLabel.text = [pref objectForKey:PREF_CURRENT_LOC_STRING];
    [self refreshRoamer];
    [self fetchRoamersFrom];
}

- (void) fetchRoamersFromDB{
    [NSFetchedResultsController deleteCacheWithName:@"MyRoamers"];
    _fetchedResultsController = nil;
    [self.mTableView reloadData];
    
}

- (void) refreshRoamer {
    [[AppDelegate sharedDelegate] showFetchAlert];
    [self.userRoamer refresh];
    [[AppDelegate sharedDelegate] dissmissFetchAlert];
}

- (void) fetchRoamersFrom{
    [roamerArray removeAllObjects];
    NSMutableArray* myRoamerArray = self.userRoamer[@"MyRoamers"];
    if(myRoamerArray == nil){
        [self.mTableView reloadData];
        return;
    }
    
    PFQuery *query = [PFQuery queryWithClassName:@"Roamer"];
    [query whereKey:@"Username" containedIn:myRoamerArray];
    [query orderByAscending:@"Username"];
	query.limit = 1000;
    
    [[AppDelegate sharedDelegate] showFetchAlert];
	[query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        [[AppDelegate sharedDelegate] dissmissFetchAlert];
		if (error) {
			NSLog(@"error in query!"); // todo why is this ever happening?
		} else {
            [roamerArray addObjectsFromArray:objects];
            [self.mTableView reloadData];
        }
    }];
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onBackAction:(id)sender {
    [self.delegate performBackFromMyRoamerAction:self];
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
//    return [[self.fetchedResultsController sections] count];
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
//        id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][section];
//        return [sectionInfo numberOfObjects];
    return [roamerArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *CellIdentifier = @"myRoamersCell";
    FindRoamersCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
/*    Roamers *roamers = (Roamers *)[self.fetchedResultsController objectAtIndexPath:indexPath];
    
    cell.mCellBkgView.layer.cornerRadius = 8.0; // half height & width
    [cell.mLocationLabel setFont:[UIFont fontWithName:@"CenturyGothic" size:16.0]];
    [cell.mNameLabel setFont:[UIFont fontWithName:@"Eurostile-Bold" size:20.0]];
//    CGRect rect = cell.mBkgImg.frame;
//    cell.mBkgImg.image = [self getBackGroundColor:rect.size.width height:rect.size.height];
    cell.mProfileImg.image = roamers.image;
    cell.mProfileImg.layer.masksToBounds = YES;
    cell.mProfileImg.layer.cornerRadius = 8.0; // half height & width
    cell.mNameLabel.text = roamers.name;
    cell.mLocationLabel.text = roamers.location; */
    
    PFObject *roamers = roamerArray[indexPath.row];
    
    cell.mCellBkgView.layer.cornerRadius = 8.0; // half height & width
//    [cell.mLocationLabel setFont:[UIFont fontWithName:@"CenturyGothic" size:16.0]];
//    [cell.mNameLabel setFont:[UIFont fontWithName:@"Eurostile-Bold" size:20.0]];
    
    //    cell.mProfileImg.image = roamers.image;
    cell.mProfileImg.layer.masksToBounds = YES;
    cell.mProfileImg.layer.cornerRadius = 8.0; // half height & width
    cell.mNameLabel.text = roamers[@"Username"]; //roamers.name;
    int val = [roamers[@"CurrentLocation"] intValue];
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
    
    currentIndex = indexPath;
    [self performSegueWithIdentifier:@"showRoamerProfile" sender:self];
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
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
    NSArray *sortDescriptors = @[sortDescriptor];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"ismyroamer = %d", IN_MY_ROAMER];
    [fetchRequest setPredicate:predicate];
    
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
    [self dismissViewControllerAnimated:NO completion:^{
        [self fetchRoamersFromDB];
    }];
}

#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"peformSetting"]) {
    } else if ([segue.identifier isEqualToString:@"showRoamerProfile"]) {
        PFObject *roamers = roamerArray[currentIndex.row];
//        Roamers *roamers = (Roamers *)[self.fetchedResultsController objectAtIndexPath:currentIndex];
        RoamerProfileViewCtrl *detailVC = segue.destinationViewController;
        detailVC.currentRoamer = roamers;
        detailVC.hideAddRemoveButton = FALSE;
        detailVC.delegate = self;
    }
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

@end
