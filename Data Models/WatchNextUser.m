//
//  WatchNextUser.m
//  Watch Next
//
//  Created by brm14 on 7/15/20.
//  Copyright © 2020 Mason Creations. All rights reserved.
//

#import "WatchNextUser.h"
#import <Parse/Parse.h>

@implementation WatchNextUser

@dynamic profilePicture;
@dynamic watched;
@dynamic watchNext;
//@dynamic suggested;
@dynamic keepSignedIn;


+ (void) changeProfilePicture: ( UIImage * _Nullable)image withCompletion: (PFBooleanResultBlock _Nullable)completion {
    //user can change profile picture
}

//+ (void)logInWithUsernameInBackground:(nonnull NSString *)username password:(nonnull NSString *)password block:(nullable ^(PFUser *user, NSError *error))block;

@end