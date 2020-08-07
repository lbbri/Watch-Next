//
//  SuggestionsViewController.m
//  Watch Next
//
//  Created by brm14 on 7/23/20.
//  Copyright © 2020 Mason Creations. All rights reserved.
//

#import "SuggestionsViewController.h"

#import "WatchNextUser.h"
#import <Parse/Parse.h>
#import "Interaction.h"
#import "MediaCollectionViewCell.h"
#import "UIImageView+AFNetworking.h"
#import "MediaViewController.h"

@interface SuggestionsViewController () <UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic) NSArray *orderedWatched;
@property (strong, nonatomic) NSMutableArray *suggestionsPool;
@property (strong, nonatomic) NSMutableArray *topKeywords;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@property(nonatomic) int loopCount;

@end

@implementation SuggestionsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.loopCount = 0;
    self.suggestionsPool = [[NSMutableArray alloc] init];
    self.topKeywords = [[NSMutableArray alloc] init];
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    [self watchedListforUser:[WatchNextUser currentUser]];
    [self.activityIndicator startAnimating];

}


- (void) watchedListforUser: (WatchNextUser *)user {
    
    
    PFQuery *query = [PFQuery queryWithClassName:@"Interaction"];
    [query whereKey:@"creator" equalTo:user];
    [query whereKey:@"interactionType" equalTo:@(0)];
    [query includeKey:@"apiID"];
    [query includeKey:@"stars"];
    [query orderByDescending:@"stars"];
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        self.orderedWatched = objects;
        [self recommendedTitles];
        
    }];
    
}


- (void) recommendedTitles {

    int lCount = 0;
    if(self.orderedWatched.count == 0)
    {
        [self collectionViewLayout];
        [self fetchHomeMedia];
    }
    else if(self.orderedWatched.count < 5)
    {
        lCount = (int)self.orderedWatched.count;
    }
    else
    {
        lCount = 5;
    }
    
    int i = 0;

    //TODO: change numbers based on how many interactions the user has
    for (i = 0; i < lCount; i++){
        Interaction *currentInteraction = self.orderedWatched[i];
        [self recommendedAPICallForID:currentInteraction[@"apiID"]];
        [self similarAPICallForID:currentInteraction[@"apiID"]];
        [self keywordAPICallForID:currentInteraction[@"apiID"]];
    }
}

- (void) recommendedAPICallForID: (NSString *)apiID {
    
    NSString *urlString = [NSString stringWithFormat:@"https://api.themoviedb.org/3/%@/recommendations?api_key=InsertAPIKey", apiID];
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:10.0];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:nil delegateQueue:[NSOperationQueue mainQueue]];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error != nil) {
            //TODO: add error alert
        } else {
            
            //all the recommended for a watched movie
            NSDictionary *dataDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            NSArray *tempResults = dataDictionary[@"results"];
            int i = 0;
            for(i = 0; i <3; i++) {
                if(tempResults[i])
                {
                    [self.suggestionsPool addObject:tempResults[i]];
                }
                
            }
            NSLog(@"reccomendd");
        }
    }];
    [task resume];
    
}


- (void) similarAPICallForID: (NSString *)apiID {
    
    NSString *urlString = [NSString stringWithFormat:@"https://api.themoviedb.org/3/%@/similar?api_key=InsertAPIKey&language=en-US", apiID];
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:10.0];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:nil delegateQueue:[NSOperationQueue mainQueue]];
    
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error != nil) {
            //TODO: add error message
        } else {
            //all the recommended for a watched movie
            NSDictionary *dataDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            NSArray *tempResults = dataDictionary[@"results"];
            int i = 0;
            for(i = 0; i <3; i++) {
                if(tempResults[i])
                {
                    [self.suggestionsPool addObject:tempResults[i]];
                }
            }

        }
    }];
    [task resume];
}


- (void) keywordAPICallForID: (NSString *)apiID {
    
    NSString *urlString = [NSString stringWithFormat:@"https://api.themoviedb.org/3/%@/keywords?api_key=InserAPIKey&language=en-US", apiID];
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:10.0];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:nil delegateQueue:[NSOperationQueue mainQueue]];
    
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error != nil) {
            //TODO: add error alert
        } else {
            NSDictionary *dataDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            NSArray *tempResults = dataDictionary[@"results"];
            [self.topKeywords addObjectsFromArray:tempResults];
            
            int i = 0;
            for(i = 0; i < tempResults.count; i++)
            {
                NSDictionary *currentKeywordDictionary = tempResults[i];
                
                [self titlesFromKeyword:currentKeywordDictionary[@"id"]];
            }
        }
    }];
    [task resume];
    
}

- (void) titlesFromKeyword: (NSString *)keywordID {
        
    NSString *urlString = [NSString stringWithFormat:@"https://api.themoviedb.org/3/keyword/%@/movies?api_key=InsertAPIKey&language=en-US", keywordID];
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:10.0];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:nil delegateQueue:[NSOperationQueue mainQueue]];
    
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error != nil) {
            //TODO: add error alert
        } else {
            NSDictionary *dataDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            NSArray *tempResults = dataDictionary[@"results"];
            
            if(tempResults.count > 0){
                int i = 0;
                for(i = 0; i <3; i++) {
                    [self.suggestionsPool addObject:tempResults[i]];
                }
                
            }
            self.loopCount ++;
            if(self.loopCount == 5)
            {
                [self viewSuggestions];
            }

        }
    }];
    [task resume];
    
    
}

- (void) viewSuggestions {
    [self collectionViewLayout];
    [self.collectionView reloadData];
}

- (void) collectionViewLayout {
    
    UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *)self.collectionView.collectionViewLayout;
    layout.minimumInteritemSpacing = 1;
    layout.minimumLineSpacing = 1;
    
    CGFloat postersPerLine = 3;
    CGFloat itemWidth = (self.collectionView.frame.size.width - layout.minimumInteritemSpacing * (postersPerLine-1)) / postersPerLine;
    CGFloat itemHeight = itemWidth * 1.5;
    layout.itemSize = CGSizeMake(itemWidth, itemHeight);
}

- (NSInteger) collectionView:(nonnull UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.suggestionsPool.count;
}

- (nonnull __kindof UICollectionViewCell *)collectionView:(nonnull UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    
    MediaCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"SuggestionCell" forIndexPath:indexPath];
    NSDictionary *cellMedia = self.suggestionsPool[indexPath.row];
    cell.posterView.image = nil;
    [cell.posterView setImageWithURL:[self posterURLFromDictionary:cellMedia]];
    return cell;
}

- (NSURL *) posterURLFromDictionary: (NSDictionary *)dictionary {
    
    NSString *baseURLString = @"https://image.tmdb.org/t/p/w500";
    NSString *posterURLString = dictionary[@"poster_path"];
    NSString *fullPosterURLString = [baseURLString stringByAppendingFormat:@"%@", posterURLString];
    return [NSURL URLWithString:fullPosterURLString];
}


#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([sender isKindOfClass: [MediaCollectionViewCell class]])
    {
        UICollectionViewCell *tappedCell = sender;
        NSIndexPath *indexPath= [self.collectionView indexPathForCell:tappedCell];
        NSDictionary *media = self.suggestionsPool[indexPath.row];
        MediaViewController *mediaViewController = [segue destinationViewController];
        mediaViewController.mediaDictionary = media;

    }
    
    
}


- (void) fetchHomeMedia {
    
    NSURL *url = [NSURL URLWithString:@"https://api.themoviedb.org/3/trending/all/day?api_key=2c075d6299d70eaf6f4a13fc180cb803"];
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:10.0];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:nil delegateQueue:[NSOperationQueue mainQueue]];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
           if (error != nil) {
               //TODO: add error alert
           } else {
               NSDictionary *dataDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
               self.suggestionsPool = dataDictionary[@"results"];
               [self.collectionView reloadData];
           }
    }];
    [task resume];
}

@end
