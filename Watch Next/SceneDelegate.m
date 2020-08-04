//
//  SceneDelegate.m
//  Watch Next
//
//  Created by brm14 on 7/14/20.
//  Copyright © 2020 Mason Creations. All rights reserved.
//

#import "SceneDelegate.h"
#import <Parse/Parse.h>
#import "WatchNextUser.h"
#import <PFFacebookUtils.h>

@interface SceneDelegate ()

@end

@implementation SceneDelegate


- (void)scene:(UIScene *)scene willConnectToSession:(UISceneSession *)session options:(UISceneConnectionOptions *)connectionOptions {
    
    WatchNextUser *user = [WatchNextUser currentUser];
    
    //persistent user login
    if(user != nil) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        UITabBarController * tabBarController = [storyboard instantiateViewControllerWithIdentifier:@"MainTabBarController"];
        self.window.rootViewController = tabBarController;
    }
}

- (void)scene:(UIScene *)scene openURLContexts:(NSSet<UIOpenURLContext *> *)URLContexts {
    
    UIOpenURLContext *urlContext = (UIOpenURLContext *)[[URLContexts allObjects] firstObject];
    if (!urlContext) {
        return;
    }
    NSURL *url = urlContext.URL;
    [FBSDKApplicationDelegate.sharedInstance application:UIApplication.sharedApplication openURL:url sourceApplication:nil annotation:@ [UIApplicationLaunchOptionsAnnotationKey]];
}


@end
