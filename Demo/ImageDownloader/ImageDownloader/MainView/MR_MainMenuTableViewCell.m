//
//  MR_MainMenuTableViewCell.m
//  ImageDownloader
//
//  Created by Manish Rathi on 11/09/14.
//  Copyright (c) 2014 Rathi Inc. All rights reserved.
//

#import "MR_MainMenuTableViewCell.h"

@implementation MR_MainMenuTableViewCell

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

@end
