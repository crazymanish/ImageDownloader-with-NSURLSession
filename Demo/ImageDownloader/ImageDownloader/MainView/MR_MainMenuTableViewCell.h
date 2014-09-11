//
//  MR_MainMenuTableViewCell.h
//  ImageDownloader
//
//  Created by Manish Rathi on 11/09/14.
//  Copyright (c) 2014 Rathi Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MR_ImageView.h"

@interface MR_MainMenuTableViewCell : UITableViewCell

/**
 * ImageView
 */

@property (weak, nonatomic) IBOutlet MR_ImageView *thumbView;

@end
