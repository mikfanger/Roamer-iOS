//
//  PostEventViewController.h
//  Roamer
//
//  Created by Mac Home on 6/6/14.
//
//

#import <UIKit/UIKit.h>
#import "EventDateSelectorViewCtrl.h"
#import "MyMapViewController.h"

@class PostEventViewController;

@protocol PostEventViewControllerDelegate <NSObject>
- (void)backFromPostEventsView:(PostEventViewController *)viewCtrl;
@end

@interface PostEventViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, EventDateSelectorViewCtrlDelegate, MyMapViewControllerDelegate, UIAlertViewDelegate>

@property (nonatomic, weak) id <PostEventViewControllerDelegate> delegate;
@property (weak, nonatomic) IBOutlet UILabel *mTypeLabel;
@property (weak, nonatomic) IBOutlet UILabel *mDateLabel;
@property (weak, nonatomic) IBOutlet UILabel *mTimeLabel;
@property (weak, nonatomic) IBOutlet UITextField *mCommentText;
@property (weak, nonatomic) IBOutlet UILabel *mAddressLabel;
@property (weak, nonatomic) IBOutlet UIScrollView *mScrollView;

@property (weak, nonatomic) IBOutlet UIView *mSelectView;
@property (weak, nonatomic) IBOutlet UILabel *mSelectViewLabel;
@property (weak, nonatomic) IBOutlet UITableView *mSelectViewTable;

@property (strong, nonatomic) PFObject *userRoamer;

- (IBAction)onPostAction:(id)sender;

- (IBAction)onBackAction:(id)sender;
- (IBAction)onSelectTypeAction:(id)sender;
- (IBAction)onSelectDateAction:(id)sender;
- (IBAction)onSelectTimeAction:(id)sender;
- (IBAction)onSelectMapAction:(id)sender;

@end
