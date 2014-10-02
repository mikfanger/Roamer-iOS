//
//  MyRoamersViewCntrl.h
//  Roamer
//
//  Created by Mac Home on 3/10/14.
//
//

#import <UIKit/UIKit.h>
#import "RoamerProfileViewCtrl.h"

@class MyRoamersViewCntrl;

@protocol MyRoamersViewCntrlDelegate <NSObject>
- (void)performBackFromMyRoamerAction:(MyRoamersViewCntrl *)viewCtrl;
@end

@interface MyRoamersViewCntrl : UIViewController <NSFetchedResultsControllerDelegate, UITableViewDataSource, UITableViewDelegate, RoamerShortProfileViewCtrlDelegate>

@property (nonatomic, weak) id <MyRoamersViewCntrlDelegate> delegate;

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@property (weak, nonatomic) IBOutlet UITableView *mTableView;
@property (weak, nonatomic) IBOutlet UILabel *mLocationLabel;

@property (strong, nonatomic) PFObject *userRoamer;

- (IBAction)onBackAction:(id)sender;
@end
