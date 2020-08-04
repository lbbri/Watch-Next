//
//  WatchNextUser.m
//  Watch Next
//
//  Created by brm14 on 7/15/20.
//  Copyright © 2020 Mason Creations. All rights reserved.
//

#import "WatchNextUser.h"
#import <Parse/Parse.h>
#import "Interaction.h"

@implementation WatchNextUser

@dynamic profilePicture;
@dynamic watched;
@dynamic watchNext;
//@dynamic suggested;
@dynamic keepSignedIn;


- (NSArray*) getWatchedList {
    WatchNextUser *user = [WatchNextUser currentUser];
    return user.watched;
}


- (NSArray*) getWatchNextList {
    WatchNextUser *user = [WatchNextUser currentUser];
    return user.watchNext;
}

+ (void) changeProfilePicture: ( UIImage * _Nullable)image withCompletion: (PFBooleanResultBlock _Nullable)completion {
    
    WatchNextUser *user = [WatchNextUser currentUser];
    user.profilePicture = [self getPFFileFromImage:image];
    [user saveInBackgroundWithBlock:completion];
}

+ (PFFileObject *)getPFFileFromImage: (UIImage * _Nullable)image {
    
    if(!image) {
        return nil;
    }
    NSData *imageData = UIImagePNGRepresentation(image);
    if(!imageData) {
        return nil;
    }
    return [PFFileObject fileObjectWithName:@"image.png" data:imageData];
}


@end
