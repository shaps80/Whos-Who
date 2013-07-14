/*
   Copyright (c) 2013 Snippex. All rights reserved.

 Redistribution and use in source and binary forms, with or without
 modification, are permitted provided that the following conditions are met:

 1. Redistributions of source code must retain the above copyright notice, this
 list of conditions and the following disclaimer.

 2. Redistributions in binary form must reproduce the above copyright notice,
 this list of conditions and the following disclaimer in the documentation
 and/or other materials provided with the distribution.

 THIS SOFTWARE IS PROVIDED BY Snippex `AS IS' AND ANY EXPRESS OR
 IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
 MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO
 EVENT SHALL Snippex OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT,
 INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
 BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
 LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
 OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
 ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#import "SPXPersonCell.h"
#import <QuartzCore/QuartzCore.h>

#define CELL_VERTICAL_MARGIN                10
#define CELL_HORIZONTAL_MARGIN              10
#define CELL_COLLAPSED_HEIGHT               72

@implementation SPXPersonCell

-(void)awakeFromNib
{
    [super awakeFromNib];

    self.backgroundView = [[UIView alloc] init];
    self.selectedBackgroundView = [[UIView alloc] init];

    self.profileImageView.layer.cornerRadius = 22;
    self.profileImageView.layer.borderWidth = 1;
    self.profileImageView.layer.masksToBounds = YES;
    self.profileImageView.layer.borderColor = [UIColor colorWithWhite:0.7
                                                                alpha:1].CGColor;

    self.nameLabel.font = [UIFont fontWithName:@"Aller"
                                          size:self.nameLabel.font.pointSize];
    self.roleLabel.font = [UIFont fontWithName:@"Aller"
                                          size:self.roleLabel.font.pointSize];
}

// we override this to adjust the border color of the profile imageView
-(void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [self.nameLabel setHighlighted:selected];
    [self.roleLabel setHighlighted:selected];
    [self.profileImageView setHighlighted:selected];

    if (selected)
        self.profileImageView.layer.borderColor = [UIColor colorWithRed:0.224
                                                                  green:0.612
                                                                   blue:0.812
                                                                  alpha:1.000].CGColor;
    else
        self.profileImageView.layer.borderColor = [UIColor colorWithWhite:0.7
                                                                    alpha:1].CGColor;
}

-(void)setBiographyText:(NSString *)text
{
    self.bioLabel.attributedText = [SPXPersonCell attributedBiographyWithText:text];
}


// Helper method, returns the biography text as an NSAttributed string with all its attributes set
+(NSAttributedString *)attributedBiographyWithText:(NSString *)text
{
    if (!text.length) return nil;
    
    UIColor *textColor = [UIColor colorWithWhite:0.102 alpha:1.000];
    UIFont *font = [UIFont systemFontOfSize:13];
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];

    [style setLineHeightMultiple:1.2];

    NSDictionary *attributes = @{ NSFontAttributeName : font,
                                  NSForegroundColorAttributeName : textColor,
                                  NSParagraphStyleAttributeName : style,
                                  };

    return [[NSAttributedString alloc] initWithString:text
                                           attributes:attributes];
}

+(CGFloat)requiredHeightWithBiographyText:(NSString *)biography
{
    if (!biography) return CELL_COLLAPSED_HEIGHT;

    NSAttributedString *string = [SPXPersonCell attributedBiographyWithText:biography];
    CGFloat width = [[UIScreen mainScreen] bounds].size.width - (CELL_HORIZONTAL_MARGIN * 2);
    CGRect rect = [string boundingRectWithSize:CGSizeMake(width, 0) options:NSStringDrawingUsesLineFragmentOrigin context:nil];

    return CELL_COLLAPSED_HEIGHT + CELL_VERTICAL_MARGIN + CGRectGetHeight(rect);
}

@end
