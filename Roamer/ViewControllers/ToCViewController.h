//
//  ToCViewController.h
//  Roamer
//
//  Created by Rajesh Mehta on 8/13/14.
//
//

#import <UIKit/UIKit.h>

@interface ToCViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIImageView *mTocImgView;
@property (weak, nonatomic) IBOutlet UIScrollView *mScrollView;

- (IBAction)onBackAction:(id)sender;
@end
