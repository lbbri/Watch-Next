//
//  SuggestionsViewController.h
//  Watch Next
//
//  Created by brm14 on 7/23/20.
//  Copyright © 2020 Mason Creations. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WatchNextUser.h"

NS_ASSUME_NONNULL_BEGIN

@interface SuggestionsViewController : UIViewController

@property (nonatomic) NSArray *orderedWatched;
@property (strong, nonatomic) NSMutableArray *suggestionsPool;

@property (strong, nonatomic) NSMutableArray *topKeywords;

- (void) watchedListforUser: (WatchNextUser *) user;




@end

NS_ASSUME_NONNULL_END
