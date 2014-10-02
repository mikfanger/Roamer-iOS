//
//  RoamerProfileViewCtrl.h
//  Roamer
//
//  Created by Mac Home on 3/10/14.
//
//

#import "RoamerShortProfileViewCtrl.h"

@interface RoamerProfileViewCtrl : RoamerShortProfileViewCtrl

@property (weak, nonatomic) IBOutlet UILabel *mTravelStatusLabel;

@property (nonatomic, assign) BOOL hideAddRemoveButton;

- (IBAction)onRemoveRoamer:(id)sender;

@end
