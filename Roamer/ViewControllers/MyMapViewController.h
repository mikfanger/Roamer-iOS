//
//  MyMapViewController.h
//  Roamer
//
//  Created by Mac Home on 6/6/14.
//
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@class MyMapViewController;

@protocol MyMapViewControllerDelegate <NSObject>
- (void)cancelMyMapViewSelectorView:(MyMapViewController *)viewCtrl;
- (void)selectMyMapViewSelectorView:(MyMapViewController *)viewCtrl name:(NSString *)name address:(NSString *)address;
@end

@interface MyMapViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, MKMapViewDelegate>

@property (nonatomic, weak) id <MyMapViewControllerDelegate> delegate;

@property (weak, nonatomic) IBOutlet UITextField *mPlacesLabel;
@property (weak, nonatomic) IBOutlet MKMapView *mMapView;

@property (weak, nonatomic) IBOutlet UIView *mSelectView;
@property (weak, nonatomic) IBOutlet UILabel *mSelectViewLabel;
@property (weak, nonatomic) IBOutlet UITableView *mSelectViewTable;
@property (weak, nonatomic) IBOutlet UIScrollView *mScrollView;

- (IBAction)onSearchAction:(id)sender;

- (IBAction)onCancelAction:(id)sender;
- (IBAction)onSelectPlaceAction:(id)sender;
@end
