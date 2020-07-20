//
//  WatchNextUser.h
//  Watch Next
//
//  Created by brm14 on 7/15/20.
//  Copyright © 2020 Mason Creations. All rights reserved.
//

#import "PFUser.h"
#import <Parse.h>

NS_ASSUME_NONNULL_BEGIN

@interface WatchNextUser : PFUser<PFSubclassing>

@property (nonatomic, strong) PFFileObject *profilePicture;
@property (nonatomic, strong) NSArray *watched;
@property (nonatomic, strong) NSArray *watchNext;
//@property (nonatomic, strong) NSMutableArray *suggested;
@property (nonatomic) BOOL *keepSignedIn;

+ (void) changeProfilePicture: ( UIImage * _Nullable)image withCompletion: (PFBooleanResultBlock _Nullable)completion;

- (NSArray *) getWatchedList;
- (NSArray *) getWatchNextList;







//function for keep them signed in
@end

NS_ASSUME_NONNULL_END
