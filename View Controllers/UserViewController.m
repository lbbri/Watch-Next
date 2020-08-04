//
//  UserViewController.m
//  Watch Next
//
//  Created by brm14 on 7/14/20.
//  Copyright © 2020 Mason Creations. All rights reserved.
//

#import "UserViewController.h"
#import "MediaViewController.h"
#import "MediaCollectionViewCell.h"
#import <Parse/Parse.h>
#import "WatchNextUser.h"
#import "UIImageView+AFNetworking.h"


@interface UserViewController () <UICollectionViewDataSource, UICollectionViewDelegate>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *pageControl;

@property (strong, nonatomic) NSArray *watched;
@property (strong, nonatomic) NSArray *watchNext;


@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;



@end

@implementation UserViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    
    
    WatchNextUser *user = [WatchNextUser currentUser];
    self.watched = user.watched;
    self.watchNext = user.watchNext;
        
    [self collectionViewLayout];
    
    [self.collectionView reloadData];
   
    
}

- (void)viewWillAppear:(BOOL)animated{
 
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;

    
    WatchNextUser *user = [WatchNextUser currentUser];
    self.watched = user.watched;
    self.watchNext = user.watchNext;
 
    
    [super viewWillAppear:animated];
    [self.collectionView reloadData];
}


#pragma mark -- Collection View

- (void) collectionViewLayout {
    
    UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *)self.collectionView.collectionViewLayout;
    

    layout.minimumInteritemSpacing = 3;
    layout.minimumLineSpacing = 3;
    
    CGFloat postersPerLine = 3;
    
    CGFloat itemWidth = (self.collectionView.frame.size.width - layout.minimumInteritemSpacing * (postersPerLine-1)) / postersPerLine;
    CGFloat itemHeight = itemWidth * 1.5;
    
    layout.itemSize = CGSizeMake(itemWidth, itemHeight);
    
}

- (nonnull __kindof UICollectionViewCell *)collectionView:(nonnull UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    
    MediaCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"UserMediaCell" forIndexPath:indexPath];
   
    if(self.pageControl.selectedSegmentIndex == 0) {

        [self mediaDictionaryWithID:self.watchNext[indexPath.row] forCell:cell completion:^(BOOL completion) {
            
            if(completion) {
                cell.posterView.image = nil;
                [cell.posterView setImageWithURL:[self posterURLFromDictionary:cell.mediaDictionary]];
            }
            
        }];
        
        
    } else if(self.pageControl.selectedSegmentIndex == 1) {

        [self mediaDictionaryWithID:self.watched[indexPath.row] forCell:cell completion:^(BOOL completion){
            
            if(completion) {
                cell.posterView.image = nil;
                [cell.posterView setImageWithURL:[self posterURLFromDictionary:cell.mediaDictionary]];
            }
            
        }];
        
    } else {

        cell.titleLabel.text = @"Suggested";
    }
    return cell;
}


- (NSInteger)collectionView:(nonnull UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    if(self.pageControl.selectedSegmentIndex == 0) {
        return self.watchNext.count;
    }
    else if(self.pageControl.selectedSegmentIndex == 1) {
        return self.watched.count;
    } else {

        return 10;
    }
    return 0;
}

- (IBAction)viewChanged:(id)sender {
  
    [self.collectionView reloadData];

}

#pragma mark -- API Interactions


- (void) mediaDictionaryWithID: (NSString *)apiID forCell: (MediaCollectionViewCell *)cell completion:(void (^)(BOOL completion))completionBlock {
    
    NSString *URLString =[NSString stringWithFormat:@"https://api.themoviedb.org/3/%@?api_key=", apiID];
    
    NSURL *url = [NSURL URLWithString:URLString];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:20.0];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:nil delegateQueue:[NSOperationQueue mainQueue]];
    
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
           if (error != nil) {
               completionBlock(false);
               NSLog(@"%@", [error localizedDescription]);
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
