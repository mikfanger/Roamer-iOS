//
//  FindRoamersCell.h
//  Roamer
//
//  Created by Mac Home on 3/7/14.
//
//

#import <UIKit/UIKit.h>

@interface FindRoamersCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *mBkgImg;
@property (weak, nonatomic) IBOutlet PFImageView *mProfileImg;
@property (weak, nonatomic) IBOutlet UILabel *mNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *mLocationLabel;
@property (weak, nonatomic) IBOutlet UIView *mCellBkgView;

@end
