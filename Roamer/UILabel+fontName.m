//
//  UILabel+fontName.m
//  HealthFit
//
//  Created by Mac Home on 3/26/14.
//  Copyright (c) 2014 SympoleTech. All rights reserved.
//

#import "UILabel+fontName.h"

@implementation UILabel (fontName)

- (NSString *)fontName {
    return self.font.fontName;
}

- (void)setFontName:(NSString *)fontName {
    self.font = [UIFont fontWithName:fontName size:self.font.pointSize];
}
@end
