//
//  RequestTableViewCell.h
//  Roamer
//
//  Created by Rajesh Mehta on 6/26/14.
//
//

#import <UIKit/UIKit.h>

@protocol RequestCellDelegate <NSObject>
- (void)performAcceptRequest:(int)rowIndex;
- (void)performDeclineRequest:(int)rowIndex;
@end

@interface RequestTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *mNameLabel;
@property (weak, nonatomic) IBOutlet PFImageView *mProfileImg;

@property (nonatomic) int mRowIndex;
@property (nonatomic, weak) id <RequestCellDelegate> delegate;

- (IBAction)onAcceptAction:(id)sender;
- (IBAction)onDeclineAction:(id)sender;
@end
