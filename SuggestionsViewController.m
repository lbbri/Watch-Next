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

@interface SuggestionsViewController () <UICollectionViewDataSource, UICollectionViewDelegate>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;


@end

@implementation SuggestionsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.suggestionsPool = [[NSMutableArray alloc] init];
    self.topKeywords = [[NSMutableArray alloc] init];
    
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    

    // Do any additional setup after loading the view.
    
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
    
    int i = 0;
    for (i = 0; i <5; i++){
        
        Interaction *currentInteraction = self.orderedWatched[i];
        
        [self recommendedAPICallForID:currentInteraction[@"apiID"]];
        [self similarAPICallForID:currentInteraction[@"apiID"]];
        [self keywordAPICallForID:currentInteraction[@"apiID"]];
        
    }
    
}

- (void) recommendedAPICallForID: (NSString *)apiID {
    
    NSString *urlString = [NSString stringWithFormat:@"https://api.themoviedb.org/3/%@/recommendations?api_key=2c075d6299d70eaf6f4a13fc180cb803&language=en-US", apiID];
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:10.0];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:nil delegateQueue:[NSOperationQueue mainQueue]];
    
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error != nil) {
            NSLog(@"%@", [error localizedDescription]);
        } else {
            
            //all the recommended for a watched movie
            NSDictionary *dataDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            NSArray *tempResults = dataDictionary[@"results"];
            int i = 0;
            for(i = 0; i <3; i++) {

                [self.suggestionsPool addObject:tempResults[i]];
            }
            
            
           // NSLog(@"%lu", self.suggestionsPool.count);
            
        }
    }];
    [task resume];
    
}


- (void) similarAPICallForID: (NSString *)apiID {
    
    NSString *urlString = [NSString stringWithFormat:@"https://api.themoviedb.org/3/%@/similar?api_key=2c075d6299d70eaf6f4a13fc180cb803&language=en-US", apiID];
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:10.0];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:nil delegateQueue:[NSOperationQueue mainQueue]];
    
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error != nil) {
            NSLog(@"%@", [error localizedDescription]);
        } else {
            
            //all the recommended for a watched movie
            NSDictionary *dataDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            NSArray *tempResults = dataDictionary[@"results"];
            int i = 0;
            for(i = 0; i <3; i++) {

                [self.suggestionsPool addObject:tempResults[i]];
            }
              

        }
    }];
    [task resume];
    
}


- (void) keywordAPICallForID: (NSString *)apiID {
    
    NSString *urlString = [NSString stringWithFormat:@"https://api.themoviedb.org/3/%@/keywords?api_key=2c075d6299d70eaf6f4a13fc180cb803&language=en-US", apiID];
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:10.0];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:nil delegateQueue:[NSOperationQueue mainQueue]];
    
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error != nil) {
            NSLog(@"%@", [error localizedDescription]);
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
           
            //NSLog(@"%@", self.topKeywords);

        }
    }];
    [task resume];
    
}

- (void) titlesFromKeyword: (NSString *)keywordID {
        
    NSString *urlString = [NSString stringWithFormat:@"https://api.themoviedb.org/3/keyword/%@/movies?api_key=2c075d6299d70eaf6f4a13fc180cb803&language=en-US", keywordID];
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:10.0];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:nil delegateQueue:[NSOperationQueue mainQueue]];
    
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error != nil) {
            NSLog(@"%@", [error localizedDescription]);
        } else {
            
            NSDictionary *dataDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            NSArray *tempResults = dataDictionary[@"results"];
            
            if(tempResults.count > 0){
                int i = 0;
                for(i = 0; i <3; i++) {
                    [self.suggestionsPool addObject:tempResults[i]];
                }
                
            }
            
 

        }
    }];
    [task resume];
    
    
}

- (IBAction)viewSuggestions:(id)sender {
    
    [self collectionViewLayout];
    [self.collectionView reloadData];
    
}

- (void) collectionViewLayout {
    
    UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *)self.collectionView.collectionViewLayout;
    
    //can also set in storyboard
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



/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
