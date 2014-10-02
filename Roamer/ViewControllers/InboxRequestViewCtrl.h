//
//  InboxRequestViewCtrl.h
//  Roamer
//
//  Created by Rajesh Mehta on 6/25/14.
//
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "RoamerProfileViewCtrl.h"
#import "RequestTableViewCell.h"
#import "ChatDetailViewController.h"

@class InboxRequestViewCtrl;

@protocol InboxRequestViewCtrlDelegate <NSObject>
- (void)backFromInboxRequestView:(InboxRequestViewCtrl *)viewCtrl;
@end

@interface InboxRequestViewCtrl : UIViewController <RoamerShortProfileViewCtrlDelegate, RequestCellDelegate, NSFetchedResultsControllerDelegate, ChatDetailViewControllerDelegate>

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@property (nonatomic, weak) id <InboxRequestViewCtrlDelegate> delegate;

@property (strong, nonatomic) PFObject *userRoamer;
@property (weak, nonatomic) IBOutlet UITableView *mTableView;
@property (weak, nonatomic) IBOutlet UIView *mInboxView;
@property (weak, nonatomic) IBOutlet UILabel *mInboxLabel;
@property (weak, nonatomic) IBOutlet UIView *mRequestsView;
@property (weak, nonatomic) IBOutlet UILabel *mRequestsLabel;
@property (weak, nonatomic) IBOutlet UIView *mSelectRoamerView;
@property (weak, nonatomic) IBOutlet UITableView *mSelectRoamerTableView;

- (IBAction)onBackAction:(id)sender;
- (IBAction)onInboxAction:(id)sender;
- (IBAction)onRequestsAction:(id)sender;
- (IBAction)onSendAction:(id)sender;
- (IBAction)onCancelSelectRoamerAction:(id)sender;

@end
