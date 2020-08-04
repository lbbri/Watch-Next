//
//  LogInViewController.m
//  Watch Next
//
//  Created by brm14 on 7/14/20.
//  Copyright © 2020 Mason Creations. All rights reserved.
//

#import "LogInViewController.h"
#import "SceneDelegate.h"
#import "WatchNextUser.h"
#import <Parse/Parse.h>
#import <PFFacebookUtils.h>

@interface LogInViewController ()

@property (weak, nonatomic) IBOutlet UITextField *usernameField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;

@end

@implementation LogInViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
}

#pragma mark - FBSDK Login

- (IBAction)loginWithFacebookTap:(id)sender {

    NSArray *permissions = @[@"email"];
    [PFFacebookUtils logInInBackgroundWithReadPermissions:permissions block:^(PFUser *user, NSError *error) {
      if (!user) {
        //TODO: add error message
      } else if (user.isNew) {
        //TODO: add loading hud
          [self changeViews];
      } else {
          //TODO: add loading hud
          [self changeViews];
      }
    }];
}

#pragma mark - Regular Parse Login

- (IBAction)logInTap:(id)sender {

    NSString *username = self.usernameField.text;
    NSString *password = self.passwordField.text;

    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error" message:@"Message" preferredStyle:(UIAlertControllerStyleAlert)];
    UIAlertAction *tryAgainAction = [UIAlertAction actionWithTitle:@"Try Again" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        }];
    [alert addAction:tryAgainAction];

    if([self.usernameField.text isEqual:@""]) {
        alert.message = @"User Name cannot be empty";
        [self presentViewController:alert animated:YES completion:^{
        }];
        
    } else if ([self.passwordField.text isEqual:@""]) {
        alert.message = @"Password cannot be empty";
        [self presentViewController:alert animated:YES completion:^{
        }];

    } else {
       [WatchNextUser logInWithUsernameInBackground:username password:password block:^(PFUser * user, NSError *  error) {
            if (error != nil) {
                alert.message = error.localizedDescription;
                [self presentViewController:alert animated:YES completion:^{
                }];
            } else {
                [self performSegueWithIdentifier:@"loginSegue" sender:nil];
            }
        }];
    }
}

#pragma mark - Animations

- (IBAction)screenTap:(id)sender {
    
    [self.view endEditing:YES];
}

#pragma mark - Helper Methods

- (void) changeViews {
    
    SceneDelegate *myDelegate = (SceneDelegate *)self.view.window.windowScene.delegate;
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil] ;
    UITabBarController * tabBarController = [storyboard instantiateViewControllerWithIdentifier:@"MainTabBarController"];
    myDelegate.window.rootViewController = tabBarController;
}




@end
