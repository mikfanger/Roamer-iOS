//
//  ChatTextTableViewCell.h
//  Roamer
//
//  Created by Rajesh Mehta on 6/26/14.
//
//

#import <UIKit/UIKit.h>

@interface ChatTextTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *mUserNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *mMsgLabel;

-(void) initWithMessage:(NSString *) msg;

@end
