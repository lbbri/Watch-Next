//
//  MediaViewController.m
//  Watch Next
//
//  Created by brm14 on 7/15/20.
//  Copyright © 2020 Mason Creations. All rights reserved.
//

#import "MediaViewController.h"
#import "Interaction.h"
#import "WatchNextUser.h"
#import "MediaCollectionViewCell.h"
#import <Parse/Parse.h>
#import "UIImageView+AFNetworking.h"
#import "NSDate+DateTools.h"
#import <MaterialButtons.h>
#import "MaterialButtons+ButtonThemer.h"
#import "MDCButton+MaterialTheming.h"

@interface MediaViewController () <UICollectionViewDataSource, UICollectionViewDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *posterView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *genreLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *synopsisLabel;
@property (weak, nonatomic) IBOutlet MDCButton *watchNextButton;
@property (strong, nonatomic) IBOutlet MDCContainerScheme *containerScheme;
@property (weak, nonatomic) IBOutlet MDCButton *watchedButton;
@property (strong, nonatomic) IBOutlet MDCContainerScheme *watchedContainerScheme;
@property (weak, nonatomic) IBOutlet UIButton *watchAgainButton;
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *ratingButtons;
@property (weak, nonatomic) IBOutlet UILabel *moreLikeLabel;
@property (strong, nonatomic) IBOutlet UICollectionView *collectionView;
@property (nonatomic) WatchNextUser *user;
@property (nonatomic) NSString *mediaAPIID;
@property (strong, nonatomic) NSMutableArray *relatedMediaArray;

@end

@implementation MediaViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    [self setUpVisuals];
    self.user = [WatchNextUser currentUser];
    [self setPosterImage];
    self.synopsisLabel.text = self.mediaDictionary[@"overview"];
    
    if(self.mediaDictionary[@"title"]) {
        self.titleLabel.text = self.mediaDictionary[@"title"];
        self.genreLabel.text = @"Movie";
        self.dateLabel.text = [self yearFromDate:self.mediaDictionary[@"release_date"]];
        self.mediaAPIID = [NSString stringWithFormat:@"movie/%@", self.mediaDictionary[@"id"]];
        
    } else {
        self.titleLabel.text = self.mediaDictionary[@"name"];
        self.genreLabel.text = @"Series";
        self.dateLabel.text = [self yearFromDate:self.mediaDictionary[@"first_air_date"]];
        self.mediaAPIID = [NSString stringWithFormat:@"tv/%@", self.mediaDictionary[@"id"]];
    }
    if([self checkIfWatchNext]) {
        self.containerScheme.colorScheme.primaryColor = [UIColor colorWithRed: 0.75 green: 0.22 blue: 0.17 alpha: 1.00];
        [self.watchNextButton applyContainedThemeWithScheme: self.containerScheme];
        
        [self.watchNextButton setTitle:@"Remove From Watch Next" forState:UIControlStateNormal];
        [self.watchedButton setTitle:@"Change to Watched" forState:UIControlStateNormal];
        self.watchedContainerScheme.colorScheme.primaryColor = [UIColor colorWithRed: 0.09 green: 0.63 blue: 0.52 alpha: 1.00];
        [self.watchedButton applyContainedThemeWithScheme: self.watchedContainerScheme];
    }
    if([self checkIfWatched]) {
        [self ratingStars];
        [self.watchedButton setTitle:@"Remove from Watched" forState:UIControlStateNormal];
        self.watchedContainerScheme.colorScheme.primaryColor = [UIColor colorWithRed: 0.75 green: 0.22 blue: 0.17 alpha: 1.00];
        [self.watchedButton applyContainedThemeWithScheme: self.watchedContainerScheme];
        [self.watchNextButton setTitle:@"Change to Watch Next" forState:UIControlStateNormal];
    }
    
    //TODO: to do change rating buttons visibility setHiddent: ![self checkIFWatched]
    self.watchAgainButton.enabled = [self checkIfWatched];
    self.moreLikeLabel.text = [NSString stringWithFormat:@"More Like %@", self.titleLabel.text];
    [self fetchRelated];
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
}

- (void) ratingStars {
    
    PFQuery *query = [PFQuery queryWithClassName:@"Interaction"];
    [query whereKey:@"creator" equalTo:[WatchNextUser currentUser]];
    [query whereKey:@"apiID" equalTo:self.mediaAPIID];
    [query includeKey:@"stars"];
    [query findObjectsInBackgroundWithBlock:^(NSArray <Interaction *>* _Nullable interactions, NSError * _Nullable error) {
        NSNumber *currentStars = interactions[0].stars;
        [self addStarRating:currentStars];
    }];
}

- (void) addStarRating: (NSNumber *) stars {
    
    for(UIButton* btn in self.ratingButtons)
    {
        [btn setSelected:NO];
        NSNumber *currentTag = @(btn.tag);
        if([currentTag doubleValue] <= [stars doubleValue]) {
            [btn setSelected:YES];
        }
        
    }
}

- (void) viewWillAppear:(BOOL)animated {
    self.navigationController.navigationBarHidden = NO;
}

- (void) removeFromWatchNext {
    
    [self.watchNextButton setTitle:@"Add to Watch Next" forState:UIControlStateNormal];
    
    NSMutableArray *originalWatchNext = [NSMutableArray arrayWithArray:[self.user getWatchNextList]];
    [originalWatchNext removeObject:self.mediaAPIID];
    [self.user removeObjectForKey:@"watchNext"];
    [self.user addUniqueObjectsFromArray:originalWatchNext forKey:@"watchNext"];
    [self.user saveInBackground];
    //remove from interaction table
    [Interaction removeInteraction:self.mediaAPIID withCompletion:^(BOOL succeeded, NSError * _Nullable error) {
    }];
    
}

- (void) changeToWatchNext {
    
    __block Interaction *interactionToChange;
    
    PFQuery *query = [PFQuery queryWithClassName:@"Interaction"];
    [query whereKey:@"creator" equalTo:[WatchNextUser currentUser]];
    [query whereKey:@"apiID" equalTo:self.mediaAPIID];
    [query findObjectsInBackgroundWithBlock:^(NSArray <Interaction *>* _Nullable interactions, NSError * _Nullable error) {
        
        interactionToChange = interactions[0];
        
        [interactionToChange setInteractionType:watchNext];
        [interactionToChange setStars:@(0)];
        [interactionToChange setWouldWatchAgain:haveNotWatched];
        [interactionToChange saveInBackground];
        //update ui
        //TODO: to do change rating buttons visibility setHidden: YES
        self.watchAgainButton.enabled = NO;
        self.containerScheme.colorScheme.primaryColor = [UIColor colorWithRed: 0.75 green: 0.22 blue: 0.17 alpha: 1.00];
        [self.watchNextButton setTitle:@"Remove from Watch Next" forState:UIControlStateNormal];
        [self.watchNextButton applyContainedThemeWithScheme: self.containerScheme];
        
        
        //remove from watched array
        NSMutableArray *originalWatched = [NSMutableArray arrayWithArray:[self.user getWatchedList]];
        [originalWatched removeObject:self.mediaAPIID];
        [self.user removeObjectForKey:@"watched"];
        [self.user addUniqueObjectsFromArray:originalWatched forKey:@"watched"];
        [self.user saveInBackground];
        //add to watch next array
        [self.user addUniqueObject:self.mediaAPIID forKey:@"watchNext"];
        [self.user saveInBackground];
    }];
}


- (void) addToWatchNext {
    
    [Interaction createWatchNext:self.mediaAPIID  withCompletion:^(BOOL succeeded, NSError * _Nullable error) {
        if(succeeded) {
            [self.user addUniqueObject:self.mediaAPIID forKey:@"watchNext"];
            [self.user saveInBackground];
            self.containerScheme.colorScheme.primaryColor = [UIColor colorWithRed: 0.75 green: 0.22 blue: 0.17 alpha: 1.00];
            [self.watchNextButton setTitle:@"Remove from Watch Next" forState:UIControlStateNormal];
            [self.watchNextButton applyContainedThemeWithScheme: self.containerScheme];
        }
    }];
}


- (IBAction)watchNextTap:(id)sender {
    
    if([self checkIfWatchNext]) {
        [self removeFromWatchNext];
        self.containerScheme.colorScheme.primaryColor = [UIColor colorWithRed: 0.09 green: 0.63 blue: 0.52 alpha: 1.00];
        [self.watchNextButton setTitle:@"Add to Watch Next" forState:UIControlStateNormal];
        [self.watchNextButton applyContainedThemeWithScheme: self.containerScheme];
        
    } else {
        [self.watchNextButton setTitle:@"Remove From Watch Next" forState:UIControlStateNormal];
        [self.watchedButton setTitle:@"Change to Watched" forState:UIControlStateNormal];
        self.watchedContainerScheme.colorScheme.primaryColor = [UIColor colorWithRed: 0.09 green: 0.63 blue: 0.52 alpha: 1.00];
        [self.watchedButton applyContainedThemeWithScheme: self.watchedContainerScheme];
        
        if([self checkIfWatched]) {
            [self changeToWatchNext];
            [self addStarRating:@(0)];
        } else {
            [self addToWatchNext];
        }
    }
}

- (void) removeFromWatched {
    
    NSMutableArray *originalWatched = [NSMutableArray arrayWithArray:[self.user getWatchedList]];
    [originalWatched removeObject:self.mediaAPIID];
    [self.user removeObjectForKey:@"watched"];
    [self.user saveInBackground];
    [self.user addUniqueObjectsFromArray:originalWatched forKey:@"watched"];
    [self.user saveInBackground];
    //remove from user array
    [Interaction removeInteraction:self.mediaAPIID withCompletion:^(BOOL succeeded, NSError * _Nullable error) {
    }];
}

- (void) changeToWatched {
    
    __block Interaction *interactionToChange;
    
    PFQuery *query = [PFQuery queryWithClassName:@"Interaction"];
    [query whereKey:@"creator" equalTo:[WatchNextUser currentUser]];
    [query whereKey:@"apiID" equalTo:self.mediaAPIID];
    [query findObjectsInBackgroundWithBlock:^(NSArray <Interaction *>* _Nullable interactions, NSError * _Nullable error) {
        
        //change interaction
        interactionToChange = interactions[0];
        [interactionToChange setInteractionType:watched];
        [interactionToChange saveInBackground];
        //update ui
        //TODO: to do change rating buttons visibility setHidden:NO
        self.watchAgainButton.enabled = YES;
        self.containerScheme.colorScheme.primaryColor = [UIColor colorWithRed: 0.09 green: 0.63 blue: 0.52 alpha: 1.00];
        [self.watchNextButton setTitle:@"Change to Watch Next" forState:UIControlStateNormal];
        [self.watchNextButton applyContainedThemeWithScheme: self.containerScheme];
        //remove from watchNext array
        NSMutableArray *originalWatchNext = [NSMutableArray arrayWithArray:[self.user getWatchNextList]];
        [originalWatchNext removeObject:self.mediaAPIID];
        [self.user removeObjectForKey:@"watchNext"];
        [self.user saveInBackground];
        [self.user addUniqueObjectsFromArray:originalWatchNext forKey:@"watchNext"];
        [self.user saveInBackground];
        //add to watched array
        [self.user addUniqueObject:self.mediaAPIID forKey:@"watched"];
        [self.user saveInBackground];
    }];
}

- (void) addToWatched {
    
    [Interaction createWatched:self.mediaAPIID  withCompletion:^(BOOL succeeded, NSError * _Nullable error) {
        if(succeeded) {
            [self.user addUniqueObject:self.mediaAPIID forKey:@"watched"];
            [self.user saveInBackground];
            //TODO: to do change rating buttons visibility setHidden: NO
            self.watchAgainButton.enabled = YES;
        }
    }];
}

- (IBAction)watchedTap:(id)sender {
    
    if([self checkIfWatched]) {
        [self.watchedButton setTitle:@"Add to Watched" forState:UIControlStateNormal];
        self.watchedContainerScheme.colorScheme.primaryColor = [UIColor colorWithRed: 0.09 green: 0.63 blue: 0.52 alpha: 1.00];
        [self.watchedButton applyContainedThemeWithScheme: self.watchedContainerScheme];
        [self removeFromWatched];
        [self addStarRating:@(0)];
        //TODO: to do change rating buttons visibility setHidden:YES
        self.watchAgainButton.enabled = NO;
    } else {
        [self.watchedButton setTitle:@"Remove from Watched" forState:UIControlStateNormal];
        self.watchedContainerScheme.colorScheme.primaryColor = [UIColor colorWithRed: 0.75 green: 0.22 blue: 0.17 alpha: 1.00];
        [self.watchedButton applyContainedThemeWithScheme: self.watchedContainerScheme];
        [self.watchNextButton setTitle:@"Change to Watch Next" forState:UIControlStateNormal];
        if([self checkIfWatchNext]) {
            [self changeToWatched];
        } else {
            [self addToWatched];
        }
    }
    
}

- (IBAction)watchAgainTap:(id)sender {
    
    PFQuery *query = [PFQuery queryWithClassName:@"Interaction"];
    [query whereKey:@"creator" equalTo:[WatchNextUser currentUser]];
    [query whereKey:@"apiID" equalTo:self.mediaAPIID];
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        Interaction *changeInteraction = objects[0];
        [Interaction changeWouldWatchAgainFor:changeInteraction.objectId];
        [self.watchAgainButton setSelected:![self.watchAgainButton isSelected]];
    }];
}

- (IBAction)changeRatingTap:(UIButton *)sender {
    
    NSNumber *stars = @(sender.tag);
    
    PFQuery *query = [PFQuery queryWithClassName:@"Interaction"];
    [query whereKey:@"creator" equalTo:[WatchNextUser currentUser]];
    [query whereKey:@"apiID" equalTo:self.mediaAPIID];
    [query getFirstObjectInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
        [Interaction changeRating:stars forInteraction:object.objectId withCompletion:^(BOOL succeeded, NSError * _Nullable error) {
        }];
    }];
    for(UIButton* btn in self.ratingButtons)
    {
        [btn setSelected:NO];
        NSNumber *currentTag = @(btn.tag);
        if([currentTag doubleValue] <= [stars doubleValue]) {
            [btn setSelected:YES];
        }
    }
}


- (BOOL) checkIfWatched {
    return [self.user.watched containsObject:self.mediaAPIID];
}

- (BOOL) checkIfWatchNext {
    return [self.user.watchNext containsObject:self.mediaAPIID];
}


#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    MediaCollectionViewCell *tappedCell = sender;
    NSIndexPath *indexPath= [self.collectionView indexPathForCell:tappedCell];
    NSDictionary *media = self.relatedMediaArray[indexPath.row];
    MediaViewController *mediaViewController = [segue destinationViewController];
    mediaViewController.mediaDictionary = media;
}

#pragma mark - Helper Methods

- (NSString *) yearFromDate:(NSString *)dateString {
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat =  @"yyyy-MM-dd";
    //Configure the input format to parse the date string
    NSDate *date = [formatter dateFromString:dateString];
    //Configure output format
    formatter.dateStyle = NSDateFormatterShortStyle;
    formatter.timeStyle = NSDateFormatterNoStyle;
    return [NSString stringWithFormat:@"%ld", date.year];
}

- (void) setPosterImage {
    //move this method to the cell itself
    NSString *baseURLString = @"https://image.tmdb.org/t/p/w500";
    NSString *posterURLString = self.mediaDictionary[@"backdrop_path"];
    NSString *fullPosterURLString = [baseURLString stringByAppendingFormat:@"%@", posterURLString];
    NSURL *posterURL = [NSURL URLWithString:fullPosterURLString];
    self.posterView.image = nil;
    [self.posterView setImageWithURL:posterURL];
    
}

- (NSURL *) posterURLFromDictionary: (NSDictionary *)dictionary {
    
    NSString *baseURLString = @"https://image.tmdb.org/t/p/w500";
    NSString *posterURLString = dictionary[@"poster_path"];
    NSString *fullPosterURLString = [baseURLString stringByAppendingFormat:@"%@", posterURLString];
    
    return [NSURL URLWithString:fullPosterURLString];
}


- (void) fetchRelated {
    NSString *urlString = [NSString stringWithFormat:@"https://api.themoviedb.org/3/%@/similar?api_key=INSERTAPIKEY&language=en-US", self.mediaAPIID];
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:10.0];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:nil delegateQueue:[NSOperationQueue mainQueue]];
    
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error != nil) {
            //TODO: add error alert
        } else {
            
            NSDictionary *dataDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            self.relatedMediaArray = dataDictionary[@"results"];
            
            if(self.relatedMediaArray.count > 0) {
                [self.collectionView setHidden:NO];
                [self.moreLikeLabel setHidden:NO];
                [self.collectionView reloadData];
            }
        }
    }];
    [task resume];
    
}

#pragma mark - Collection View
- (NSInteger) collectionView:(nonnull UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.relatedMediaArray.count;
}

- (nonnull __kindof UICollectionViewCell *)collectionView:(nonnull UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    
    MediaCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"RelatedCell" forIndexPath:indexPath];
    NSDictionary *cellMedia = self.relatedMediaArray[indexPath.row];
    cell.posterView.image = nil;
    [cell.posterView setImageWithURL:[self posterURLFromDictionary:cellMedia]];
    return cell;
}

#pragma mark - Visual Polish

- (void) setUpVisuals {
    
    self.containerScheme = [[MDCContainerScheme alloc] init];
    self.containerScheme.colorScheme.primaryColor = [UIColor colorWithRed: 0.09 green: 0.63 blue: 0.52 alpha: 1.00];
    [self.watchNextButton setTitle:@"Add to Watch Next" forState:UIControlStateNormal];
    [self.watchNextButton applyContainedThemeWithScheme: self.containerScheme];
    self.watchNextButton.minimumSize = CGSizeMake(64, 36);
    CGFloat verticalInset = MIN(0, (CGRectGetHeight(self.watchNextButton.bounds) - 48) / 2);
    self.watchNextButton.hitAreaInsets = UIEdgeInsetsMake(verticalInset, 0, verticalInset, 0);
    
    
    self.watchedContainerScheme = [[MDCContainerScheme alloc] init];
    self.watchedContainerScheme.colorScheme.primaryColor = [UIColor colorWithRed: 0.09 green: 0.63 blue: 0.52 alpha: 1.00];
    [self.watchedButton setTitle:@"Add to Watched" forState:UIControlStateNormal];
    [self.watchedButton applyContainedThemeWithScheme: self.watchedContainerScheme];
    self.watchedButton.minimumSize = CGSizeMake(64, 36);
    self.watchedButton.hitAreaInsets = UIEdgeInsetsMake(verticalInset, 0, verticalInset, 0);
    
}



@end
