//
//  Interaction.m
//  Watch Next
//
//  Created by brm14 on 7/15/20.
//  Copyright © 2020 Mason Creations. All rights reserved.
//

#import "Interaction.h"
#import <Parse/Parse.h>
#import "WatchNextUser.h"

@implementation Interaction

@dynamic interactionID;
@dynamic creator;
@dynamic apiID;
@dynamic mediaType;

@dynamic watched;
@dynamic stars;
@dynamic wouldWatchAgain;

+ (nonnull NSString *)parseClassName {
    return @"Interaction";
}


+ (void) createInteraction: (NSString *)title withType: ( NSString * _Nullable)type isWatched: (BOOL)watched withRating: (NSNumber * _Nullable)rating wouldWatchAgain: (BOOL)watchAgain withCompletion: (PFBooleanResultBlock _Nullable)completion {
    
    Interaction *newInteraction = [Interaction new];
    //Interaction *newInteraction = [Interaction objectWithClassName:@"Interaction"];
    //newInteraction.creator = [WatchNextUser currentUser];
    newInteraction.creator = [PFUser currentUser];

    newInteraction.apiID = title;
    newInteraction.mediaType = type;
    newInteraction.watched = watched;
    newInteraction.stars = rating;
    newInteraction.wouldWatchAgain = watchAgain;
    
    [newInteraction saveInBackgroundWithBlock:completion];
    
}

+ (void) createWatchNext: (NSString *)title withType: ( NSString * _Nullable)type withCompletion: (PFBooleanResultBlock _Nullable)completion {
    
    Interaction *watchNextInteraction = [Interaction new];
    
    watchNextInteraction.creator = [PFUser currentUser];
    watchNextInteraction.apiID = title;
    watchNextInteraction.mediaType = type;
    
    watchNextInteraction.watched = NO;
    
    [watchNextInteraction saveInBackgroundWithBlock:completion];
    
}

+ (void) createWatched: (NSString *)title withType: ( NSString * _Nullable)type withCompletion: (PFBooleanResultBlock _Nullable)completion {
    
    Interaction *watchedInteraction = [Interaction new];
    //newInteraction.creator = [WatchNextUser currentUser];
    watchedInteraction.creator = [PFUser currentUser];

    watchedInteraction.apiID = title;
    watchedInteraction.mediaType = type;
    watchedInteraction.watched = YES;
    
    [watchedInteraction saveInBackgroundWithBlock:completion];
    
}

+ (void) changeRating: (NSNumber *) stars forInteraction: (NSString *)objectID withCompletion:(PFBooleanResultBlock _Nullable)completion {
    
    PFQuery *query = [PFQuery queryWithClassName:@"Interaction"];

    // Retrieve the object by id
    [query getObjectInBackgroundWithId:objectID block:^(PFObject *currentInteraction, NSError *error) {
        
        currentInteraction[@"stars"] = stars;
        [currentInteraction saveInBackground];
    }];
    
}




@end
