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

@interface MediaViewController () <UICollectionViewDataSource, UICollectionViewDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *posterView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *synopsisLabel;
@property (weak, nonatomic) IBOutlet UIButton *watchNextButton;
@property (weak, nonatomic) IBOutlet UIButton *watchedButton;
@property (weak, nonatomic) IBOutlet UIButton *watchAgainButton;
@property (weak, nonatomic) IBOutlet UISlider *ratingSlider;
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *ratingButtons;
@property (weak, nonatomic) IBOutlet UILabel *ratingLabel;
@property (weak, nonatomic) IBOutlet UILabel *moreLikeLabel;
@property (strong, nonatomic) IBOutlet UICollectionView *collectionView;
@property (nonatomic) WatchNextUser *user;
@property (nonatomic) NSString *mediaAPIID;
@property (strong, nonatomic) NSMutableArray *relatedMediaArray;

@end

@implementation MediaViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    self.user = [WatchNextUser currentUser];
    [self setPosterImage];
    self.synopsisLabel.text = self.mediaDictionary[@"overview"];
    
    if(self.mediaDictionary[@"title"]) {
        self.titleLabel.text = self.mediaDictionary[@"title"];
        self.mediaAPIID = [NSString stringWithFormat:@"movie/%@", self.mediaDictionary[@"id"]];
    } else {
        self.titleLabel.text = self.mediaDictionary[@"name"];
        self.mediaAPIID = [NSString stringWithFormat:@"tv/%@", self.mediaDictionary[@"id"]];
    }
    [self.watchNextButton setSelected:[self checkIfWatchNext]];
    [self.watchedButton setSelected:[self checkIfWatched]];
    [self.ratingSlider setHidden:![self checkIfWatched]];
    self.watchAgainButton.enabled = [self checkIfWatched];
    self.moreLikeLabel.text = [NSString stringWithFormat:@"More Like %@", self.titleLabel.text];
    [self fetchRelated];
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
}

- (void) viewWillAppear:(BOOL)animated {
    self.navigationController.navigationBarHidden = NO;
}

- (void) removeFromWatchNext {
    
    NSMutableArray *originalWatchNext = (NSMutableArray *)[self.user getWatchNextList];
    [originalWatchNext removeObject:self.mediaAPIID];
    [self.user removeObjectForKey:@"watchNext"];
    [self.user addUniqueObjectsFromArray:originalWatchNext forKey:@"watchNext"];
    [self.user saveInBackground];
    //remove from interaction table
    [Interaction removeWatchNext:self.mediaAPIID withCompletion:^(BOOL succeeded, NSError * _Nullable error) {
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
        [self.watchedButton setSelected:NO];
        [self.ratingSlider setHidden:YES];
        self.watchAgainButton.enabled = NO;
        [self.watchNextButton setSelected:YES];
        //remove from watched array
        NSMutableArray *originalWatched = (NSMutableArray *)[self.user getWatchedList];
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
            [self.watchNextButton setSelected:YES];
        }
    }];
}


- (IBAction)watchNextTap:(id)sender {
    
    if([self checkIfWatchNext]) {
        [self removeFromWatchNext];
        [self.watchNextButton setSelected:NO];
    } else {
        if([self checkIfWatched]) {
            [self changeToWatchNext];
        } else {
            [self addToWatchNext];
        }
    }
}

- (void) removeFromWatched {
    
    NSMutableArray *originalWatched = (NSMutableArray *)[self.user getWatchedList];
    [originalWatched removeObject:self.mediaAPIID];
    [self.user removeObjectForKey:@"watched"];
    [self.user saveInBackground];
    [self.user addUniqueObjectsFromArray:originalWatched forKey:@"watched"];
    [self.user saveInBackground];
    //remove from user array
    [Interaction removeWatched:self.mediaAPIID withCompletion:^(BOOL succeeded, NSError * _Nullable error) {
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
        [self.watchedButton setSelected:YES];
        [self.ratingSlider setHidden:NO];
       // [self.watchAgainButton setHidden:NO];
        self.watchAgainButton.enabled = YES;
        [self.watchNextButton setSelected:NO];
        //remove from watchNext array
        NSMutableArray *originalWatchNext = (NSMutableArray *)[self.user getWatchNextList];
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
            [self.watchedButton setSelected:YES];
            [self.ratingSlider setHidden:NO];
            //[self.watchAgainButton setHidden:NO];
            self.watchAgainButton.enabled = YES;
        }
    }];
}

- (IBAction)watchedTap:(id)sender {
    
    if([self checkIfWatched]) {
        
        [self removeFromWatched];
        [self.watchedButton setSelected:NO];
        [self.ratingSlider setHidden:YES];
        self.watchAgainButton.enabled = NO;
    } else {
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

//TODO: change from rating slider to buttons
- (IBAction)changeRatingSlider:(id)sender {
    
    self.ratingLabel.text = [NSString stringWithFormat:@"%f", self.ratingSlider.value];
    NSNumber *stars = @(self.ratingSlider.value);
    
    PFQuery *query = [PFQuery queryWithClassName:@"Interaction"];
    [query whereKey:@"creator" equalTo:[WatchNextUser currentUser]];
    [query whereKey:@"apiID" equalTo:self.mediaAPIID];
    [query getFirstObjectInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
        [Interaction changeRating:stars forInteraction:object.objectId withCompletion:^(BOOL succeeded, NSError * _Nullable error) {
        }];
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
        if([currentTag doubleValue] <= [stars doubleValue])
        {
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

- (void) setPosterImage {
    //move this method to the cell itself
    NSString *baseURLString = @"https://image.tmdb.org/t/p/w500";
    NSString *posterURLString = self.mediaDictionary[@"poster_path"];
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
    NSString *urlString = [NSString stringWithFormat:@"https://api.themoviedb.org/3/%@/similar?api_key=insertAPIKey&language=en-US", self.mediaAPIID];
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:10.0];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:nil delegateQueue:[NSOperationQueue mainQueue]];
    
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error != nil) {
            //TODO: add error alert
        } else {
            
            NSDictionary *dataDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            self.relatedMediaArray = dataDictionary[@"results"];
            
            [self.collectionView reloadData];
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


@end
