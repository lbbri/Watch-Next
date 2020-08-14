//
//  WatchedViewController.m
//  Watch Next
//
//  Created by brm14 on 8/5/20.
//  Copyright © 2020 Mason Creations. All rights reserved.
//

#import "WatchedViewController.h"
#import "MediaViewController.h"
#import "MediaCollectionViewCell.h"
#import <Parse/Parse.h>
#import "WatchNextUser.h"
#import "UIImageView+AFNetworking.h"

@interface WatchedViewController () <UICollectionViewDataSource, UICollectionViewDelegate>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (strong, nonatomic) NSArray *watched;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UIStepper *layoutStepper;
@property (nonatomic) CGFloat postersPerLine;

@end

@implementation WatchedViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.postersPerLine = 2.0f;
    self.layoutStepper.value = 2.0;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    WatchNextUser *user = [WatchNextUser currentUser];
    if(![self.watched isEqualToArray:user.watched]) {
        self.watched = user.watched;
        self.collectionView.dataSource = self;
        self.collectionView.delegate = self;
        [self collectionViewLayout:self.postersPerLine];
        [self.collectionView reloadData];
    }
}

#pragma mark -- Collection View

- (void) collectionViewLayout: (CGFloat)ppl {
    
    UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *)self.collectionView.collectionViewLayout;
    layout.minimumInteritemSpacing = 1;
    layout.minimumLineSpacing = 1;
    
    CGFloat postersPerLine = ppl;
    CGFloat itemWidth = (self.collectionView.frame.size.width - layout.minimumInteritemSpacing * (postersPerLine-1)) / postersPerLine;
    CGFloat itemHeight = itemWidth * 1.5;
    
    layout.itemSize = CGSizeMake(itemWidth, itemHeight);
}

- (nonnull __kindof UICollectionViewCell *)collectionView:(nonnull UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    
    MediaCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"WatchedCell" forIndexPath:indexPath];
    
    [self mediaDictionaryWithID:self.watched[indexPath.row] forCell:cell completion:^(BOOL completion){
        if(completion) {
            cell.posterView.image = nil;
            [cell.posterView setImageWithURL:[self posterURLFromDictionary:cell.mediaDictionary]];
        }
    }];
    
    return cell;
}


- (NSInteger)collectionView:(nonnull UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.watched.count;
}

- (IBAction)posterNumChanged:(id)sender {
    
    self.postersPerLine = (CGFloat)self.layoutStepper.value;
    [self collectionViewLayout:self.postersPerLine];
}




#pragma mark -- API Interactions

- (void) mediaDictionaryWithID: (NSString *)apiID forCell: (MediaCollectionViewCell *)cell completion:(void (^)(BOOL completion))completionBlock {
    
    NSString *URLString =[NSString stringWithFormat:@"https://api.themoviedb.org/3/%@?api_key=InsertAPIKey", apiID];
    
    NSURL *url = [NSURL URLWithString:URLString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:20.0];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:nil delegateQueue:[NSOperationQueue mainQueue]];
    
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error != nil) {
            completionBlock(false);
            //TODO: add error alert
        } else {
            NSDictionary *dataDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            cell.mediaDictionary = dataDictionary;
            completionBlock(true);
        }
    }];
    
    [task resume];
    
}

- (NSURL *) posterURLFromDictionary: (NSDictionary *)dictionary {
    
    NSString *baseURLString = @"https://image.tmdb.org/t/p/w500";
    NSString *posterURLString = dictionary[@"poster_path"];
    NSString *fullPosterURLString = [baseURLString stringByAppendingFormat:@"%@", posterURLString];
    
    return [NSURL URLWithString:fullPosterURLString];
}



#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if([sender isKindOfClass:[MediaCollectionViewCell class]]) {
        MediaCollectionViewCell *tappedCell = sender;
        MediaViewController *mediaViewController = [segue destinationViewController];
        mediaViewController.mediaDictionary = tappedCell.mediaDictionary;
    }
}

@end
