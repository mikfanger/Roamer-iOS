//
//  EventDateSelectorViewCtrl.h
//  Roamer
//
//  Created by Mac Home on 6/6/14.
//
//

#import <UIKit/UIKit.h>

@class EventDateSelectorViewCtrl;

@protocol EventDateSelectorViewCtrlDelegate <NSObject>
- (void)cancelEventDateSelectorView:(EventDateSelectorViewCtrl *)viewCtrl;
- (void)selectEventDateSelectorView:(EventDateSelectorViewCtrl *)viewCtrl eventDate:(NSDate *)eventDate;
@end

@interface EventDateSelectorViewCtrl : UIViewController

@property (weak, nonatomic) IBOutlet UIDatePicker *mEventDatePicker;

@property (nonatomic, weak) id <EventDateSelectorViewCtrlDelegate> delegate;

- (IBAction)onSelectAction:(id)sender;
- (IBAction)onCancelAction:(id)sender;


@end
