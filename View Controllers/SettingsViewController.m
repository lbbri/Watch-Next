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

@interface SettingsViewController ()

@end

@implementation SettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (IBAction)didTapLogout:(id)sender {
    
    SceneDelegate *myDelegate = (SceneDelegate *)self.view.window.windowScene.delegate;
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil] ;
    LogInViewController *loginViewController = [storyboard instantiateViewControllerWithIdentifier:@"LoginViewController"];
    
    myDelegate.window.rootViewController = loginViewController;
    
    //[WatchNextUser logOutInBackgroundWithBlock:^(NSError * _Nullable error) {
    [PFUser logOutInBackgroundWithBlock:^(NSError * _Nullable error) {
        //current user is now nil
    }];
    
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
