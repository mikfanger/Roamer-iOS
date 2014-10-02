//
//  ShowEventsViewCntrl.h
//  Roamer
//
//  Created by Mac Home on 4/10/14.
//
//

#import <UIKit/UIKit.h>
#import "EventDetailViewCntrl.h"
#import "SortDateSelectorViewCtrl.h"

@class ShowEventsViewCntrl;

@protocol ShowEventsViewCntrlDelegate <NSObject>
- (void)backFromShowEventsView:(ShowEventsViewCntrl *)viewCtrl;
@end

@interface ShowEventsViewCntrl : UIViewController <UITableViewDataSource, UITableViewDelegate, EventDetailViewCntrlDelegate, SortDateSelectorViewCtrlDelegate, UIActionSheetDelegate>

@property (nonatomic, weak) id <ShowEventsViewCntrlDelegate> delegate;

@property (weak, nonatomic) IBOutlet UIButton *mSortButton;
@property (weak, nonatomic) IBOutlet UITableView *mTableView;
@property (weak, nonatomic) IBOutlet UILabel *mMyEventsTitleLabel;
@property (weak, nonatomic) IBOutlet UIView *mMyEventsView;
@property (weak, nonatomic) IBOutlet UILabel *mAllEventsTitleLabel;
@property (weak, nonatomic) IBOutlet UIView *mAllEventsView;

@property (weak, nonatomic) IBOutlet UIView *mSortSelectView;
@property (weak, nonatomic) IBOutlet UILabel *mSortDateLabel;
@property (weak, nonatomic) IBOutlet UILabel *mSortTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *mSortTypeLabel;

@property (strong, nonatomic) PFObject *userRoamer;

- (IBAction)onMyEventsAction:(id)sender;
- (IBAction)onAllEventsAction:(id)sender;
- (IBAction)onBackAction:(id)sender;
- (IBAction)onSortAction:(id)sender;

- (IBAction)onSortByDateAction:(id)sender;
- (IBAction)onSortByTimeAction:(id)sender;
- (IBAction)onSortByTypeAction:(id)sender;
- (IBAction)onPerformSortAction:(id)sender;

@end
