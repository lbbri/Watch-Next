//
//  HomeViewController.m
//  Watch Next
//
//  Created by brm14 on 7/14/20.
//  Copyright © 2020 Mason Creations. All rights reserved.
//

#import "HomeViewController.h"
#import "MediaCollectionViewCell.h"
#import "MediaViewController.h"
#import "UIImageView+AFNetworking.h"


@interface HomeViewController () <UICollectionViewDataSource, UICollectionViewDelegate>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (strong, nonatomic) NSMutableArray *mediaArray;

@end

@implementation HomeViewController

- (void) viewDidLoad {
    [super viewDidLoad];
    
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    
    [self collectionViewLayout];
    [self fetchHomeMedia];
    
}

#pragma mark - Collection View

//add parameters so it's not hard coded
- (void) collectionViewLayout {
    
    UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *)self.collectionView.collectionViewLayout;
    
    //can also set in storyboard
    layout.minimumInteritemSpacing = 3;
    layout.minimumLineSpacing = 3;
    
    CGFloat postersPerLine = 3;
    
    CGFloat itemWidth = (self.collectionView.frame.size.width - layout.minimumInteritemSpacing * (postersPerLine-1)) / postersPerLine;
    CGFloat itemHeight = itemWidth * 1.5;
    
    layout.itemSize = CGSizeMake(itemWidth, itemHeight);
    
}

- (NSInteger) collectionView:(nonnull UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.mediaArray.count;
}

- (nonnull __kindof UICollectionViewCell *)collectionView:(nonnull UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    
    MediaCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"MediaCell" forIndexPath:indexPath];
    NSDictionary *cellMedia = self.mediaArray[indexPath.row];
        
    cell.posterView.image = nil;
    [cell.posterView setImageWithURL:[self posterURLFromDictionary:cellMedia]];
    
    return cell;
}


#pragma mark - API Interaction

- (void) fetchHomeMedia {
    
    NSURL *url = [NSURL URLWithString:@"https://api.themoviedb.org/3/trending/all/day?api_key=];
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:10.0];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:nil delegateQueue:[NSOperationQueue mainQueue]];
    
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
           if (error != nil) {
               NSLog(@"%@", [error localizedDescription]);
           } else {
               
               NSDictionary *dataDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
               self.mediaArray = dataDictionary[@"results"];
    
               [self.collectionView reloadData];
           }
    }];
    [task resume];
    
}

//do not need this...?
- (NSString *) mediaTypeFromDictionary: (NSDictionary *)dictionary {
    return dictionary[@"media_type"];
}

- (NSURL *) posterURLFromDictionary: (NSDictionary *)dictionary {
    
    NSString *baseURLString = @"https://image.tmdb.org/t/p/w500";
    NSString *posterURLString = dictionary[@"poster_path"];
    NSString *fullPosterURLString = [baseURLString stringByAppendingFormat:@"%@", posterURLString];
    
    return [NSURL URLWithString:fullPosterURLString];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    UICollectionViewCell *tappedCell = sender;
    NSIndexPath *indexPath= [self.collectionView indexPathForCell:tappedCell];
    NSDictionary *media = self.mediaArray[indexPath.row];
    
    MediaViewController *mediaViewController = [segue destinationViewController];
    mediaViewController.mediaDictionary = media;
    
}

@end
