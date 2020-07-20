//
//  MediaViewController.m
//  Watch Next
//
//  Created by brm14 on 7/15/20.
//  Copyright © 2020 Mason Creations. All rights reserved.
//

#import "MediaViewController.h"
#import <Parse/Parse.h>
#import "Interaction.h"
#import "WatchNextUser.h"

@interface MediaViewController ()

@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UIButton *watchNextButton;
@property (strong, nonatomic) IBOutlet UIButton *watchedButton;
@property (weak, nonatomic) IBOutlet UISlider *ratingSlider;
@property (strong, nonatomic) IBOutlet UIButton *watchAgainButton;


@property (nonatomic) WatchNextUser *user;

@property (nonatomic) NSString *mediaTitle;
@property (nonatomic) MediaType type;


@end

@implementation MediaViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.user = [WatchNextUser currentUser];
    
    if(self.media[@"title"]) {
        
        self.mediaTitle = self.media[@"title"];
        self.type = movie;
    } else {
        
        self.mediaTitle = self.media[@"name"];
        self.type = show;
    }
        

    self.titleLabel.text = self.mediaTitle;
        
    [self.watchedButton setSelected:[self checkIfWatched]];
    [self.watchNextButton setSelected:[self checkIfWatchNext]];

}

- (IBAction)watchNextTap:(id)sender {
    
    NSString *title = self.titleLabel.text;
        
    if([self checkIfWatchNext]) //if it is on watch next list then delete it from the list
    {
            
        NSMutableArray *originalWatchNext = (NSMutableArray *)[self.user getWatchedList];
        
        [originalWatchNext removeObject:self.titleLabel.text];
        
        [self.user removeObjectForKey:@"watchNext"];

        [self.user addUniqueObjectsFromArray:originalWatchNext forKey:@"watchNext"];
        [self.user saveInBackground];
        
        //remove from user array
        [Interaction removeWatchNext:title withCompletion:^(BOOL succeeded, NSError * _Nullable error) {
        }];
        
        
        [self.watchNextButton setSelected:NO];
    }
    else //add it to the list but first check if its in watched already
    {
        
        if([self checkIfWatched]) {
            
            __block Interaction *interactionToChange;
            
            PFQuery *query = [PFQuery queryWithClassName:@"Interaction"];
            
            [query whereKey:@"creator" equalTo:[WatchNextUser currentUser]];
            [query whereKey:@"apiID" equalTo:title];
            
            [query findObjectsInBackgroundWithBlock:^(NSArray <Interaction *>* _Nullable interactions, NSError * _Nullable error) {
                
                //change interaction
                interactionToChange = interactions[0];
                
                [interactionToChange setInteractionType:watched];
                [interactionToChange setStars:@(0)];
                [interactionToChange setWouldWatchAgain:haveNotWatched];
                [interactionToChange saveInBackground];
                
                //update ui
                [self.watchedButton setSelected:NO];
                [self.ratingSlider setHidden:YES];
                [self.watchAgainButton setHidden:YES];
                [self.watchNextButton setSelected:YES];
                
                //remove from watched array
                NSMutableArray *originalWatched = (NSMutableArray *)[self.user getWatchedList];
                [originalWatched removeObject:self.titleLabel.text];
                [self.user removeObjectForKey:@"watched"];
                [self.user addUniqueObjectsFromArray:originalWatched forKey:@"watched"];
                [self.user saveInBackground];
                
                //add to watch next array
                [self.user addUniqueObject:title forKey:@"watchNext"];
                [self.user saveInBackground];
                
            }];
            
            
        }
        else {
            
            [Interaction createWatchNext:title withCompletion:^(BOOL succeeded, NSError * _Nullable error) {
                  
                if(succeeded)
                {
                    
                    [self.user addUniqueObject:title forKey:@"watchNext"];
                    [self.user saveInBackground];
                    
                    [self.watchNextButton setSelected:YES];
                    
                }
            }];
            
        }
        
    }
    
}

- (IBAction)watchedTap:(id)sender {
        
    NSString *title = self.mediaTitle;
    
    //if it is already on the watched list take it off
    if([self checkIfWatched]) {
        
        NSMutableArray *originalWatched = (NSMutableArray *)[self.user getWatchedList];
        
        [originalWatched removeObject:self.titleLabel.text];
        
        [self.user removeObjectForKey:@"watched"];
        [self.user saveInBackground];

        [self.user addUniqueObjectsFromArray:originalWatched forKey:@"watched"];
        [self.user saveInBackground];
        
        //remove from user array
        [Interaction removeWatched:title withCompletion:^(BOOL succeeded, NSError * _Nullable error) {
        }];
        
        
        [self.watchedButton setSelected:NO];
        [self.ratingSlider setHidden:YES];
        [self.watchAgainButton setHidden:YES];
    
    }
    //if not add it, but first check if it is already on the watch next list
    else {
        if([self checkIfWatchNext]) {
            
            __block Interaction *interactionToChange;
            
            PFQuery *query = [PFQuery queryWithClassName:@"Interaction"];
            
            [query whereKey:@"creator" equalTo:[WatchNextUser currentUser]];
            [query whereKey:@"apiID" equalTo:title];
            
            
            [query findObjectsInBackgroundWithBlock:^(NSArray <Interaction *>* _Nullable interactions, NSError * _Nullable error) {
                
                //change interaction
                interactionToChange = interactions[0];
                [interactionToChange setInteractionType:watched];
                [interactionToChange saveInBackground];
                
                //update ui
                [self.watchedButton setSelected:YES];
                [self.ratingSlider setHidden:NO];
                [self.watchAgainButton setHidden:NO];
                [self.watchNextButton setSelected:NO];
                
                
                //remove from watchNext array
                NSMutableArray *originalWatchNext = (NSMutableArray *)[self.user getWatchNextList];
                [originalWatchNext removeObject:self.mediaTitle];
                [self.user removeObjectForKey:@"watchNext"];
                [self.user saveInBackground];

                [self.user addUniqueObjectsFromArray:originalWatchNext forKey:@"watchNext"];
                [self.user saveInBackground];
                
                //add to watched array
                [self.user addUniqueObject:title forKey:@"watched"];
                [self.user saveInBackground];
            }];
            
        } else {
            
            [Interaction createWatched:title  withCompletion:^(BOOL succeeded, NSError * _Nullable error) {

                if(succeeded) {
                    [self.user addUniqueObject:title forKey:@"watched"];
                    [self.user saveInBackground];
                    
                    [self.watchedButton setSelected:YES];
                    [self.ratingSlider setHidden:NO];
                    [self.watchAgainButton setHidden:NO];

                }
                
            }];
            
        }
    }

}

- (IBAction)watchAgainTap:(id)sender {
    
    //[sender setSelected:self.wwa];
    
}

- (IBAction)changeRatingSlider:(id)sender {
    
    NSNumber *stars = @(self.ratingSlider.value);
        
    PFQuery *query = [PFQuery queryWithClassName:@"Interaction"];
    
    [query whereKey:@"creator" equalTo:[WatchNextUser currentUser]];
    [query whereKey:@"apiID" equalTo:self.mediaTitle];
    
    [query getFirstObjectInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
        
        [Interaction changeRating:stars forInteraction:object.objectId withCompletion:^(BOOL succeeded, NSError * _Nullable error) {
        }];
    }];
    

}


- (BOOL) checkIfWatched {
   return [self.user.watched containsObject:self.mediaTitle];
}

- (BOOL) checkIfWatchNext {
    return [self.user.watchNext containsObject:self.mediaTitle];
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
