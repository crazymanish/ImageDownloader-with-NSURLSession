//
//  MR_ImageView.m
//  ImageDownloader
//
//  Created by Manish Rathi on 11/09/14.
//  Copyright (c) 2014 Rathi Inc. All rights reserved.
//
//
//  This software is provided 'as-is', without any express or implied
//  warranty.  In no event will the authors be held liable for any damages
//  arising from the use of this software.
//
//  Permission is granted to anyone to use this software for any purpose,
//  including commercial applications, and to alter it and redistribute it
//  freely, subject to the following restrictions:
//
//  1. The origin of this software must not be misrepresented; you must not
//  claim that you wrote the original software. If you use this software
//  in a product, an acknowledgment in the product documentation would be
//  appreciated but is not required.
//
//  2. Altered source versions must be plainly marked as such, and must not be
//  misrepresented as being the original software.
//
//  3. This notice may not be removed or altered from any source distribution.
//

#import "MR_ImageView.h"
#import "MR_ProgressIndicator.h"
#import "MR_ImageDownloader.h"
#import "MR_ImageDownloadManager.h"

@interface MR_ImageView ()

/** Progress-Indicator Instance */
@property (nonatomic,strong) MR_ProgressIndicator *progressIndicator;

/** Downloading Image Url */
@property (nonatomic,strong) NSURL *downloadingImageUrl;
@end

@implementation MR_ImageView


#pragma mark - Add Circle Progress-Indicator
- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        //Add Progress-Indicator
        [self addCircleProgressIndicator];
    }
    return self;
}

-(id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        //Add Progress-Indicator
        [self addCircleProgressIndicator];
    }
    return self;
}

- (id)init {
    self = [super init];
    if (self) {
        //Add Progress-Indicator
        [self addCircleProgressIndicator];
    }
    return self;
}

/** Create Circle ProgressIndicator, & add it to Self's Centre */
-(void)addCircleProgressIndicator
{
    //Add Progress-Indicator
    if (!_progressIndicator) {
        _progressIndicator=[MR_ProgressIndicator new];
        
        /** @Manish ---- Frame calculation (Height/Width) */
        CGFloat minSize= MIN(self.frame.size.width, self.frame.size.height);
        CGRect frame=_progressIndicator.frame;
        frame.size.width=minSize/4;
        frame.size.height=minSize/4;
        [_progressIndicator setFrame:frame];
        
        //@Manish ---- make it Center
        CGPoint center = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
        [_progressIndicator setCenter:center];
        //[_progressIndicator setCenter:self.center];
        
        //make-it Hidden as by-default
        [_progressIndicator setHidden:YES];
        
        //Add SubView
        [self addSubview:_progressIndicator];
        
        // You can use Appearance Proxy to style the MACircleProgressIndicator
        MR_ProgressIndicator *appearance = [MR_ProgressIndicator appearance];
        
        // The color property sets the actual color of the procress circle (how
        // suprising ;) )
        appearance.color = [UIColor darkGrayColor];
    }
}


#pragma mark - Download Image
/** Download Image API */
-(void)downloadImageWithUrlString:(NSString *)urlString
{
    NSURL *url=[NSURL URLWithString:urlString];
    [self downloadImageWithUrl:url];
}

-(void)downloadImageWithUrl:(NSURL *)url
{
    [self downloadImageWithUrl:url withPlaceholderImage:nil];
}

/** With Place-Holder Image */
-(void)downloadImageWithUrlString:(NSString *)urlString withPlaceholderImage:(UIImage *)placeholderImage
{
    NSURL *url=[NSURL URLWithString:urlString];
    [self downloadImageWithUrl:url withPlaceholderImage:placeholderImage];
}

-(void)downloadImageWithUrl:(NSURL *)url withPlaceholderImage:(UIImage *)placeholderImage
{
    //set placeholder-Image
    if (placeholderImage) {
        self.image=placeholderImage;
    }else{
        self.image=nil;
    }
    
    //Set Url
    [self setDownloadingImageUrl:url];
    
    //make-it Un-Hide
    [_progressIndicator setHidden:NO];
    
    //Set 0
    [self updateDownloadingImageValue:0.0f];
    
    //Download Image
    [self downloadImageWithUrl:url withCompletionHandler:^(UIImage *image,NSURL *imageUrl,NSError* error) {
        //SET- IMAGE here.
        if ([url isEqual:imageUrl] && image) {
            //@Manish ---- Perform UI-operations in Main-Thread
            dispatch_async(dispatch_get_main_queue(), ^{
                self.image=image;
                //make-it Hidden
                [_progressIndicator setHidden:YES];
            });
        }
    }];
}

-(void)downloadImageWithUrl:(NSURL *)url withCompletionHandler:(MR_DownloadImageCompletionBlock)completionHandler
{
    /**
     * Download the Image Now
     */
    [[MR_ImageDownloadManager sharedInstance] downloadImageWithUrl:url withCompletionHandler:^(UIImage *image, NSURL *imageUrl, NSError *error) {
        //Completion-Handler
        if ([self.downloadingImageUrl isEqual:imageUrl]) {
            completionHandler(image,imageUrl,error);
        }
    } withDownloadProgressHandler:^(NSURL *imageUrl,int64_t bytesRead, int64_t totalBytesRead, int64_t totalBytesExpectedToRead) {
        //Progress Calculation
        if ([self.downloadingImageUrl isEqual:imageUrl]) {
            CGFloat progressValue=((CGFloat)totalBytesRead/(CGFloat)totalBytesExpectedToRead);
           // NSLog(@"Progress Value For URL =%@  Value ==== %f",[url lastPathComponent],progressValue);
            //Update Progress
            [self updateDownloadingImageValue:progressValue];
        }
    }];
}

#pragma mark - update download-progress of Image
/** @Manish ---> update ProgressValue Method */
-(void)updateDownloadingImageValue:(CGFloat)value {
    if (_progressIndicator) {
        //Update UI in main-thread
        dispatch_async(dispatch_get_main_queue(), ^{
            _progressIndicator.value=value;
        });
    }
}

#pragma mark - dealloc
//@Manish
-(void)dealloc
{
    /** do Nil ----@Manish */
    _progressIndicator=nil;
    _downloadingImageUrl=nil;
}

@end
