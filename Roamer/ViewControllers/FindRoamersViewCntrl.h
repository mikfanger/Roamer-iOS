//
//  FindRoamersViewCntrl.h
//  Roamer
//
//  Created by Mac Home on 3/4/14.
//
//

#import <UIKit/UIKit.h>
#import "RoamerShortProfileViewCtrl.h"

@class FindRoamersViewCntrl;

@protocol FindRoamersViewCntrlDelegate <NSObject>
- (void)performBackAction:(FindRoamersViewCntrl *)viewCtrl;
@end

@interface FindRoamersViewCntrl : UIViewController <NSFetchedResultsControllerDelegate, UITableViewDataSource, UITableViewDelegate, RoamerShortProfileViewCtrlDelegate>

@property (nonatomic, weak) id <FindRoamersViewCntrlDelegate> delegate;

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@property (weak, nonatomic) IBOutlet UILabel *mLocationLabel;
@property (weak, nonatomic) IBOutlet UITableView *mTableView;
@property (weak, nonatomic) IBOutlet UILabel *mRomersLocLabel;

@property (weak, nonatomic) IBOutlet UIView *mLocTableView;
@property (weak, nonatomic) IBOutlet UITableView *mLocTable;

@property (strong, nonatomic) PFObject *userRoamer;

- (IBAction)onBackAction:(id)sender;
- (IBAction)mPickLocation:(id)sender;
@end
