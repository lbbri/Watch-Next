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

@dynamic interactionType;
@dynamic stars;
@dynamic wouldWatchAgain;


+ (nonnull NSString *)parseClassName {
    return @"Interaction";
}


+ (void) createWatchNext: (NSString *)title  withCompletion: (PFBooleanResultBlock _Nullable)completion {
    
    Interaction *watchNextInteraction = [Interaction new];
    
    watchNextInteraction.creator = [WatchNextUser currentUser];
    watchNextInteraction.apiID = title;
    watchNextInteraction.interactionType = watchNext;
    watchNextInteraction.wouldWatchAgain = haveNotWatched;
    
    [watchNextInteraction saveInBackgroundWithBlock:completion];
    
}


+ (void) createWatched: (NSString *)title withCompletion: (PFBooleanResultBlock _Nullable)completion {
    
    Interaction *watchedInteraction = [Interaction new];
    
    watchedInteraction.creator = [WatchNextUser currentUser];
    watchedInteraction.apiID = title;
    watchedInteraction.interactionType = watched;
    watchedInteraction.wouldWatchAgain = no;
    
    [watchedInteraction saveInBackgroundWithBlock:completion];
    
}



+ (void) removeWatchNext: (NSString *)title withCompletion: (PFBooleanResultBlock _Nullable)completion {
    
    __block Interaction *interactionToDelete;
    
    PFQuery *query = [PFQuery queryWithClassName:@"Interaction"];
    
    [query whereKey:@"creator" equalTo:[WatchNextUser currentUser]];
    [query whereKey:@"apiID" equalTo:title];
    [query whereKey:@"interactionType" equalTo:@(1)];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray <Interaction *>* _Nullable interactions, NSError * _Nullable error) {
        if(interactions) {
            
            interactionToDelete = interactions[0];
            
            [interactionToDelete deleteInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                if(error) {
                    
                    NSLog(@"%@", error.description);
                }
            }];
        }
        
    }];
    
}

//combine these into one i guess because there will only be one instance

+ (void) removeWatched: (NSString *)title withCompletion: (PFBooleanResultBlock _Nullable)completion {
    
    __block Interaction *interactionToDelete;
    
    PFQuery *query = [PFQuery queryWithClassName:@"Interaction"];
    
    [query whereKey:@"creator" equalTo:[WatchNextUser currentUser]];
    [query whereKey:@"apiID" equalTo:title];
    [query whereKey:@"interactionType" equalTo:@(0)];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray <Interaction *>* _Nullable interactions, NSError * _Nullable error) {
        interactionToDelete = interactions[0];
        
        [interactionToDelete deleteInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
            if(error) {
                
                NSLog(@"%@", error.description);
            }

        }];
    
        [interactionToDelete saveInBackground];
    }];
    
}
     
+ (void) changeRating: (NSNumber *) stars forInteraction: (NSString *)objectID withCompletion:(PFBooleanResultBlock _Nullable)completion {
         
        PFQuery *query = [PFQuery queryWithClassName:@"Interaction"];

        [query getObjectInBackgroundWithId:objectID block:^(PFObject *currentInteraction, NSError *error) {
             
             currentInteraction[@"stars"] = stars;
             [currentInteraction saveInBackground];
         }];
         
     }

+ (void) changeInteractionFor: (NSString *)objectID toType: (InteractionType)type withCommpletion: (PFBooleanResultBlock _Nullable) completion {
    
    PFQuery *query = [PFQuery queryWithClassName:@"Interaction"];

    [query getObjectInBackgroundWithId:objectID block:^(PFObject *currentInteraction, NSError *error) {
        
        currentInteraction[@"interactionType"] = [NSNumber numberWithInt:(type)];
        [currentInteraction saveInBackground];
    }];
    
}

+ (void) changeWouldWatchAgainFor: (NSString *)objectID {
    
    PFQuery *query = [PFQuery queryWithClassName:@"Interaction"];

       [query getObjectInBackgroundWithId:objectID block:^(PFObject *currentInteraction, NSError *error) {
            
           if([currentInteraction[@"wouldWatchAgain"]  isEqual: [NSNumber numberWithInt:(yes)]]){
               currentInteraction[@"wouldWatchAgain"] = [NSNumber numberWithInt:(no)];
           } else {
               currentInteraction[@"wouldWatchAgain"] = [NSNumber numberWithInt:(yes)];
           }
           
               
           [currentInteraction saveInBackground];
        }];
        
    
}



@end
