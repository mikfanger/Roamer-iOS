//
//  SortDateSelectorViewCtrl.h
//  Roamer
//
//  Created by Mac Home on 6/2/14.
//
//

#import <UIKit/UIKit.h>

@class SortDateSelectorViewCtrl;

@protocol SortDateSelectorViewCtrlDelegate <NSObject>
- (void)cancelSortDateSelectorView:(SortDateSelectorViewCtrl *)viewCtrl;
- (void)selectSortDateSelectorView:(SortDateSelectorViewCtrl *)viewCtrl startDate:(NSDate *)startDate endDate:(NSDate *)endDate;
@end

@interface SortDateSelectorViewCtrl : UIViewController
@property (weak, nonatomic) IBOutlet UIDatePicker *mStartDatePicker;
@property (weak, nonatomic) IBOutlet UIDatePicker *mEndDatePicker;

@property (nonatomic, weak) id <SortDateSelectorViewCtrlDelegate> delegate;

- (IBAction)onSelectAction:(id)sender;
- (IBAction)onCancelAction:(id)sender;

- (IBAction)onStartDateChange:(id)sender;

@end
