//
//  CreateAccountPicViewCtrl.h
//  Roamer
//
//  Created by Mac Home on 2/24/14.
//
//

#import <UIKit/UIKit.h>

@class CreateAccountPicViewCtrl;

@protocol CreateAccountPicViewCtrlDelegate <NSObject>
- (void)performFinishedAction:(CreateAccountPicViewCtrl *)viewCtrl;
@end

@interface CreateAccountPicViewCtrl : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UILabel *mTravelLabel;
@property (weak, nonatomic) IBOutlet UILabel *mAirlineLabel;
@property (weak, nonatomic) IBOutlet UILabel *mHotelLabel;

@property (weak, nonatomic) IBOutlet UILabel *mViewTitleLabel;
@property (weak, nonatomic) IBOutlet UIView *mSelectTableView;
@property (weak, nonatomic) IBOutlet UITableView *mTableView;

@property (strong, nonatomic) UIImage *profilePic;

@property (nonatomic, weak) id <CreateAccountPicViewCtrlDelegate> delegate;

- (IBAction)onNextAction:(id)sender;
- (IBAction)onPrevAction:(id)sender;
- (IBAction)onTravelSelectAction:(id)sender;
- (IBAction)onAirlineSelectAction:(id)sender;
- (IBAction)onHotelSelectAction:(id)sender;

@end
