//
//  HomeViewController.m
//  Watch Next
//
//  Created by brm14 on 7/14/20.
//  Copyright © 2020 Mason Creations. All rights reserved.
//

#import "HomeViewController.h"
#import "MediaViewController.h"
#import "MediaCollectionViewCell.h"


@interface HomeViewController () <UICollectionViewDataSource, UICollectionViewDelegate>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (strong, nonatomic) NSMutableArray *mediaArray;


@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self fetchHome];
    
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    
    UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *)self.collectionView.collectionViewLayout;
    
    
    //can also set in storyboard
    layout.minimumInteritemSpacing = 3;
    layout.minimumLineSpacing = 3;
    
    CGFloat postersPerLine = 3;
    
    //correctly calculates layout based on how many movies are on each row
    CGFloat itemWidth = (self.collectionView.frame.size.width - layout.minimumInteritemSpacing * (postersPerLine-1)) / postersPerLine;
    CGFloat itemHeight = itemWidth * 1.5;
    
    layout.itemSize = CGSizeMake(itemWidth, itemHeight);
    
    [self.collectionView reloadData];
    
}

- (nonnull __kindof UICollectionViewCell *)collectionView:(nonnull UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    MediaCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"MediaCell" forIndexPath:indexPath];
    
    NSDictionary *media = self.mediaArray[indexPath.row];
    
    if(media[@"title"]) {
        
        cell.titleLabel.text = media[@"title"];
    } else {
        cell.titleLabel.text = media[@"name"];
    }
    
    return cell;
}

- (NSInteger)collectionView:(nonnull UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    return self.mediaArray.count;
}


- (void) fetchHome {
    
    //connect to API via URL
    NSURL *url = [NSURL URLWithString:@"https://api.themoviedb.org/3/trending/all/day?api_key=2c075d6299d70eaf6f4a13fc180cb803"];
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:10.0];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:nil delegateQueue:[NSOperationQueue mainQueue]];
    
    
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
          //if there was an error when with getting the JSON
           if (error != nil) {
               NSLog(@"%@", [error localizedDescription]);
           } else {
               
               //load JSON data into dataDictionary
               NSDictionary *dataDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
               self.mediaArray = dataDictionary[@"results"];
               
               [self.collectionView reloadData];
           }
        
    }];
    [task resume];
    
}


#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    UICollectionViewCell *tappedCell = sender;
    NSIndexPath *indexPath= [self.collectionView indexPathForCell:tappedCell];
    NSDictionary *media = self.mediaArray[indexPath.row];
    
    MediaViewController *mediaViewController = [segue destinationViewController];
    mediaViewController.media = media;
    
}


@end
