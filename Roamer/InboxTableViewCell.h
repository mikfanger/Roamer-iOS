//
//  InboxTableViewCell.h
//  Roamer
//
//  Created by Rajesh Mehta on 6/26/14.
//
//

#import <UIKit/UIKit.h>

@interface InboxTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *mNameLabel;
@property (weak, nonatomic) IBOutlet PFImageView *mProfileImg;
@property (weak, nonatomic) IBOutlet UILabel *mMsgLabel;
@property (weak, nonatomic) IBOutlet UIImageView *mNewMailImg;

@end
