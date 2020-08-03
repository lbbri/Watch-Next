//
//  SettingsViewController.m
//  Watch Next
//
//  Created by brm14 on 7/14/20.
//  Copyright © 2020 Mason Creations. All rights reserved.
//

#import "SettingsViewController.h"
#import "SceneDelegate.h"
#import "LogInViewController.h"
#import <Parse/Parse.h>
#import "WatchNextUser.h"
#import <PFFacebookUtils.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>

@interface SettingsViewController ()

@end

@implementation SettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (IBAction)didTapLogout:(id)sender {
    
    SceneDelegate *myDelegate = (SceneDelegate *)self.view.window.windowScene.delegate;
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil] ;
    LogInViewController *loginViewController = [storyboard instantiateViewControllerWithIdentifier:@"LoginViewController"];
    
    myDelegate.window.rootViewController = loginViewController;
    
    [[FBSDKLoginManager new] logOut];
    [WatchNextUser logOutInBackgroundWithBlock:^(NSError * _Nullable error) {
    }];
    
}

/*
#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
}
*/

@end
