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
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UIStepper *layoutStepper;
@property (nonatomic) CGFloat postersPerLine;

@end

@implementation HomeViewController

- (void) viewDidLoad {
    
    [super viewDidLoad];
    [self.activityIndicator startAnimating];
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    self.postersPerLine = 2.0f;
    self.layoutStepper.value = 2.0;
    [self collectionViewLayout:self.postersPerLine];
    [self fetchHomeMedia];
    
}


#pragma mark - Collection View

- (void) collectionViewLayout: (CGFloat)ppl {
    
    UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *)self.collectionView.collectionViewLayout;
    layout.minimumInteritemSpacing = 1;
    layout.minimumLineSpacing = 1;
    
    CGFloat postersPerLine = ppl;
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
    
    NSURL *url = [NSURL URLWithString:@"https://api.themoviedb.org/3/trending/all/day?api_key=InsertAPIKey"];
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:10.0];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:nil delegateQueue:[NSOperationQueue mainQueue]];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
           if (error != nil) {
               //TODO: add error alert
           } else {
               NSDictionary *dataDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
               self.mediaArray = dataDictionary[@"results"];
               [self.collectionView reloadData];
           }
    }];
    [task resume];
    [self.activityIndicator startAnimating];

}

- (NSURL *) posterURLFromDictionary: (NSDictionary *)dictionary {
    
    NSString *baseURLString = @"https://image.tmdb.org/t/p/w500";
    NSString *posterURLString = dictionary[@"poster_path"];
    NSString *fullPosterURLString = [baseURLString stringByAppendingFormat:@"%@", posterURLString];
    return [NSURL URLWithString:fullPosterURLString];
}


#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if([sender isKindOfClass: [MediaCollectionViewCell class]]) {
        UICollectionViewCell *tappedCell = sender;
        NSIndexPath *indexPath= [self.collectionView indexPathForCell:tappedCell];
        NSDictionary *media = self.mediaArray[indexPath.row];
        MediaViewController *mediaViewController = [segue destinationViewController];
        mediaViewController.mediaDictionary = media;
    }
}

#pragma mark - Visuals

- (IBAction)posterNumChanged:(id)sender {
    
    self.postersPerLine = (CGFloat)self.layoutStepper.value;
    [self collectionViewLayout:self.postersPerLine];
}


@end
