//
//  RequestTableViewCell.m
//  Roamer
//
//  Created by Rajesh Mehta on 6/26/14.
//
//

#import "RequestTableViewCell.h"

@implementation RequestTableViewCell

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

- (IBAction)onAcceptAction:(id)sender {
    NSLog(@"Touch on %d",self.mRowIndex);
    [self.delegate performAcceptRequest:self.mRowIndex];
}

- (IBAction)onDeclineAction:(id)sender {
    NSLog(@"Touch on %d",self.mRowIndex);
    [self.delegate performDeclineRequest:self.mRowIndex];
}

@end
