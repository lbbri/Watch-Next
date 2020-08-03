//
//  UserSuggestions.h
//  Watch Next
//
//  Created by brm14 on 7/23/20.
//  Copyright © 2020 Mason Creations. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WatchNextUser.h"

NS_ASSUME_NONNULL_BEGIN

@interface UserSuggestions : NSObject

@property (nonatomic) NSArray *orderedWatched;

- (void) watchedListforUser: (WatchNextUser *)user;


@end

NS_ASSUME_NONNULL_END
