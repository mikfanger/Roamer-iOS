//
//  ExplanationViewCntrl.h
//  Roamer
//
//  Created by Mac Home on 2/24/14.
//
//

#import <UIKit/UIKit.h>
#import "CreateAccountViewCntrl.h"

@class ExplanationViewCntrl;

@protocol ExplanationViewCntrlDelegate <NSObject>
- (void)performFinishedAction:(ExplanationViewCntrl *)viewCtrl;
@end

@interface ExplanationViewCntrl : UIViewController <CreateAccountViewCntrlDelegate>

@property (nonatomic, weak) id <ExplanationViewCntrlDelegate> delegate;
@property (weak, nonatomic) IBOutlet UIImageView *mBkgImgView;

- (IBAction)onCreateAccountAction:(id)sender;
- (IBAction)onPrevAction:(id)sender;

@end
