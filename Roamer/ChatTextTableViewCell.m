//
//  ChatTextTableViewCell.m
//  Roamer
//
//  Created by Rajesh Mehta on 6/26/14.
//
//

#import "ChatTextTableViewCell.h"

@implementation ChatTextTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void) initWithMessage:(NSString *) msg {
    CGSize constSize=CGSizeMake(280, MAXFLOAT);
    NSData *data = [msg dataUsingEncoding:NSUTF8StringEncoding];
    NSString *goodValue = [[NSString alloc] initWithData:data encoding:NSNonLossyASCIIStringEncoding];
    CGSize size=[goodValue sizeWithFont:[UIFont fontWithName:@"Arial" size:16] constrainedToSize:constSize lineBreakMode:  NSLineBreakByWordWrapping];
    
    [self.mMsgLabel setFrame:CGRectMake(20, 21, size.width, size.height)];
    [self.mMsgLabel setNumberOfLines:0];
    [self.mMsgLabel setBaselineAdjustment:UIBaselineAdjustmentAlignBaselines];
    [self.mMsgLabel setText:msg];
    [self.contentView setFrame:CGRectMake(0, 0, 320, size.height+28)];
}

@end
