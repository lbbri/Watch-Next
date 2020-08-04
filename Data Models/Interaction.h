//
//  Interaction.h
//  Watch Next
//
//  Created by brm14 on 7/15/20.
//  Copyright © 2020 Mason Creations. All rights reserved.
//

#import "PFObject.h"
#import "Parse/Parse.h"
#import "WatchNextUser.h"

NS_ASSUME_NONNULL_BEGIN

@interface Interaction : PFObject<PFSubclassing>

typedef enum {
    watched,
    watchNext
} InteractionType;

typedef enum {
    none,
    movie,
    show,
    
} MediaType;

typedef enum {
    yes,
    no,
    haveNotWatched,
} WatchAgain;

@property (nonatomic, strong) NSString *interactionID;
@property (nonatomic, strong) WatchNextUser *creator;

@property (nonatomic, strong) NSString *apiID;
@property (nonatomic) MediaType *mediaType;

@property (nonatomic) InteractionType interactionType;
@property (nonatomic, strong) NSNumber *stars;
@property (nonatomic) WatchAgain wouldWatchAgain;





+ (void) createWatchNext: (NSString *)title  withCompletion: (PFBooleanResultBlock _Nullable)completion;

+ (void) createWatched: (NSString *)title  withCompletion: (PFBooleanResultBlock _Nullable)completion;

+ (void) removeWatchNext: (NSString *)title withCompletion: (PFBooleanResultBlock _Nullable)completion;

+ (void) removeWatched: (NSString *)title withCompletion: (PFBooleanResultBlock _Nullable)completion;

+ (void) changeRating: (NSNumber *) stars forInteraction: (NSString *)objectID withCompletion:(PFBooleanResultBlock _Nullable)completion;

+ (void) changeInteractionFor: (NSString *)objectID toType: (InteractionType)type withCommpletion: (PFBooleanResultBlock _Nullable) completion;

+ (void) changeWouldWatchAgainFor: (NSString *)objectID;

@end

NS_ASSUME_NONNULL_END
