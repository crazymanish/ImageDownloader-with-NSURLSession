//
//  MR_MainMenuTableViewController.m
//  ImageDownloader
//
//  Created by Manish Rathi on 11/09/14.
//  Copyright (c) 2014 Rathi Inc. All rights reserved.
//

#import "MR_MainMenuTableViewController.h"
#import "MR_ImageDownloadManager.h"
#import "MR_MainMenuTableViewCell.h"

@interface MR_MainMenuTableViewController ()
@property (nonatomic,strong) NSMutableArray *imageUrlList;
@end

@implementation MR_MainMenuTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    //Fetch Images
    [self fetchImageUrls];
    
    //Reload Table
    [self.tableView reloadData];
}

-(void)fetchImageUrls
{
    if (!self.imageUrlList) {
        self.imageUrlList=[NSMutableArray array];
    }
    
    struct {
        short unsigned end;
        short unsigned start;
        char *url;
    }images[3] =
        {{19, 1, "http://img.mangahit.com/manga/0916/054046/%02d.jpg"},
        {19, 1, "http://img.mangahit.com/manga/0916/054037/%02d.jpg"},
        {19, 1, "http://img.mangahit.com/manga/0916/054022/%02d.jpg"}};

    for (int i = 0; i < 3; i++) {
        int end = images[i].end;
        for (int j = images[i].start; j <= end; j++) {
            [self.imageUrlList addObject:[NSString stringWithFormat:[NSString stringWithCString:images[i].url encoding:NSUTF8StringEncoding],j]];
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.imageUrlList.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MR_MainMenuTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MR_MainMenuTableViewCell" forIndexPath:indexPath];
    
    //DownLoad Image
    [cell.thumbView downloadImageWithUrlString:self.imageUrlList[indexPath.row]];
    
    return cell;
}


@end
