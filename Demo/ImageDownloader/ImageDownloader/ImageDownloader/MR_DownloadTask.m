//
//  MR_DownloadTask.m
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

#import "MR_DownloadTask.h"

@interface MR_DownloadTask ()<NSURLSessionDownloadDelegate>
{
    MR_DownloadImageCompletionBlock completionBlock;
    MR_DownloadImageProgressBlock progressBlock;
}
/** will hold the Url-session */
@property (strong,nonatomic,readwrite) NSURLSession *session;

/** will hold the NSURLSessionDownloadTask Object */
@property (strong,nonatomic,readwrite) NSURLSessionDownloadTask *downloadTask;

/**
 * useful for KVO
 */
@property (nonatomic,readwrite,getter = isFinished) BOOL finished;
@end

@implementation MR_DownloadTask

-(instancetype)initWithImageUrl:(NSURL *)url
             withOperationQueue:(NSOperationQueue *)queue
          withCompletionHandler:(MR_DownloadImageCompletionBlock)completionHandler
    withDownloadProgressHandler:(MR_DownloadImageProgressBlock)progressHandler
{
    self = [super init];
    if (!self) {
		return nil;
    }
    
    //Callback
    completionBlock=completionHandler;
    progressBlock=progressHandler;
    
    /** Prepare-Request */
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    self.session = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:queue];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    self.downloadTask = [self.session downloadTaskWithRequest:request];
    
    return self;
}


#pragma mark - NSURLSession Delegate
/* Sent periodically to notify the delegate of download progress. */
- (void)URLSession:(NSURLSession *)session
      downloadTask:(NSURLSessionDownloadTask *)downloadTask
      didWriteData:(int64_t)bytesWritten
 totalBytesWritten:(int64_t)totalBytesWritten
totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite {
    //Progress Block
    progressBlock(downloadTask.originalRequest.URL,bytesWritten,totalBytesWritten,totalBytesExpectedToWrite);
}


/* Sent when a download has been resumed. If a download failed with an
 * error, the -userInfo dictionary of the error will contain an
 * NSURLSessionDownloadTaskResumeData key, whose value is the resume
 * data.
 */
-(void)URLSession:(NSURLSession *)session
     downloadTask:(NSURLSessionDownloadTask *)downloadTask
didResumeAtOffset:(int64_t)fileOffset
expectedTotalBytes:(int64_t)expectedTotalBytes {
    //Not Using Resume
}


/* Sent when a download task that has completed a download.  The delegate should
 * copy or move the file at the given location to a new location as it will be
 * removed when the delegate message returns. URLSession:task:didCompleteWithError: will
 * still be called.
 */
- (void)URLSession:(NSURLSession *)session
      downloadTask:(NSURLSessionDownloadTask *)downloadTask
didFinishDownloadingToURL:(NSURL *)location {
    //Finish
    [self finishTask];
    
    //Complition Block with Sucess Image
    if (completionBlock) {
        NSString *path = [location path];
        NSData *data = [[NSFileManager defaultManager] contentsAtPath:path];
        
        UIImage *image = [UIImage imageWithData:data];
        completionBlock(image,downloadTask.originalRequest.URL,nil);
    }
}

/* Sent as the last message related to a specific task.  Error may be
 * nil, which implies that no error occurred and this task is complete.
 */
- (void)URLSession:(NSURLSession *)session
              task:(NSURLSessionTask *)task
didCompleteWithError:(NSError *)error
{
    //Finish
    [self finishTask];
    
    //Complition Block with Error
    completionBlock(nil,task.originalRequest.URL,error);
}

#pragma mark - Finish Function
- (void)finishTask
{
    //@Manish ----> lock Self here, for thread-safe
    @synchronized (self){
        if (!_finished){
            [self willChangeValueForKey:@"isFinished"];
            _finished = YES;
            [self didChangeValueForKey:@"isFinished"];
        }
    }
}

#pragma mark - dealloc
/* Do Nil Here
 */
-(void)dealloc
{
    self.session=nil;
    self.downloadTask=nil;
}

@end
