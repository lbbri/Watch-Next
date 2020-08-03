//
//  UserSuggestions.m
//  Watch Next
//
//  Created by brm14 on 7/23/20.
//  Copyright © 2020 Mason Creations. All rights reserved.
//

#import "UserSuggestions.h"

#import "WatchNextUser.h"
#import <Parse/Parse.h>
#import "Interaction.h"

@implementation UserSuggestions


- (void) watchedListforUser: (WatchNextUser *)user {
    
    
    PFQuery *query = [PFQuery queryWithClassName:@"Interaction"];
    
    [query whereKey:@"creator" equalTo:user];
    [query whereKey:@"interactionType" equalTo:@(0)];
    
    [query includeKey:@"apiID"];
    [query includeKey:@"stars"];
    
    [query orderByDescending:@"stars"];
    
    
    
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        self.orderedWatched = objects;
        [self printIt];
    }];
    
}

- (void) printIt {
    
    NSLog(@"%@", self.orderedWatched);
}

@end
