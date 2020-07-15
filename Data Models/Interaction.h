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

@property (nonatomic, strong) NSString *interactionID;
//@property (nonatomic, strong) WatchNextUser *creator;
@property (nonatomic, strong) PFUser *creator;

@property (nonatomic, strong) NSString *apiID;
@property (nonatomic, strong) NSString *mediaType;

@property (nonatomic) BOOL watched;
@property (nonatomic, strong) NSNumber *stars;
@property (nonatomic) BOOL wouldWatchAgain;


+ (void) createInteraction: (NSString *)title withType: ( NSString * _Nullable)type isWatched: (BOOL)watched withRating: (NSNumber * _Nullable)rating wouldWatchAgain: (BOOL)watchAgain withCompletion: (PFBooleanResultBlock _Nullable)completion;

+ (void) createWatchNext: (NSString *)title withType: ( NSString * _Nullable)type withCompletion: (PFBooleanResultBlock _Nullable)completion;

+ (void) createWatched: (NSString *)title withType: ( NSString * _Nullable)type withCompletion: (PFBooleanResultBlock _Nullable)completion;


+ (void) changeRating: (NSNumber *) stars forInteraction: (NSString *)objectID withCompletion:(PFBooleanResultBlock _Nullable)completion;


@end

NS_ASSUME_NONNULL_END
