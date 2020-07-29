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
@import FBSDKCoreKit;

@interface SceneDelegate ()

@end

@implementation SceneDelegate


- (void)scene:(UIScene *)scene willConnectToSession:(UISceneSession *)session options:(UISceneConnectionOptions *)connectionOptions {
    
    WatchNextUser *user = [WatchNextUser currentUser];
    
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


//- (void)sceneDidDisconnect:(UIScene *)scene {
//    // Called as the scene is being released by the system.
//    // This occurs shortly after the scene enters the background, or when its session is discarded.
//    // Release any resources associated with this scene that can be re-created the next time the scene connects.
//    // The scene may re-connect later, as its session was not neccessarily discarded (see `application:didDiscardSceneSessions` instead).
//}
//
//
//- (void)sceneDidBecomeActive:(UIScene *)scene {
//    // Called when the scene has moved from an inactive state to an active state.
//    // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
//}
//
//
//- (void)sceneWillResignActive:(UIScene *)scene {
//    // Called when the scene will move from an active state to an inactive state.
//    // This may occur due to temporary interruptions (ex. an incoming phone call).
//}
//
//
//- (void)sceneWillEnterForeground:(UIScene *)scene {
//    // Called as the scene transitions from the background to the foreground.
//    // Use this method to undo the changes made on entering the background.
//}
//
//
//- (void)sceneDidEnterBackground:(UIScene *)scene {
//    // Called as the scene transitions from the foreground to the background.
//    // Use this method to save data, release shared resources, and store enough scene-specific state information
//    // to restore the scene back to its current state.
//}


@end
