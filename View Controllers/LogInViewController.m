//
//  LogInViewController.m
//  Watch Next
//
//  Created by brm14 on 7/14/20.
//  Copyright © 2020 Mason Creations. All rights reserved.
//

#import "LogInViewController.h"
#import <Parse/Parse.h>
#import "WatchNextUser.h"
//@import FacebookLogin;

@interface LogInViewController ()

@property (weak, nonatomic) IBOutlet UITextField *usernameField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;

@end

@implementation LogInViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //[self addLoginButton];
    // Do any additional setup after loading the view.
}

//- (void)addLoginButton {
//    FBSDKLoginButton *loginButton = [[FBSDKLoginButton alloc] init];
//    loginButton.delegate = self;
//
//    //loginButton.permissions = @[@"user_birthday", @"user_friends"];
//    loginButton.permissions = @[@"email"];
//    loginButton.center = self.view.center;
//    [self.view addSubview:loginButton];
//}
//
//- (void)loginButton:(nonnull FBSDKLoginButton *)loginButton didCompleteWithResult:(nullable FBSDKLoginManagerLoginResult *)result error:(nullable NSError *)error {
//
//    NSAssert(error || result, @"Must have a result or an error");
//
//    if (error) {
//        return NSLog(@"An Error occurred: %@", error.localizedDescription);
//    }
//
//    if (result.isCancelled) {
//        return NSLog(@"Login was cancelled");
//    }
//
//    NSLog(@"Success. Granted permissions: %@", result.grantedPermissions);
//
//    [self performSegueWithIdentifier:@"FBLoginSegue" sender:nil];
//}
//
//- (void)loginButtonDidLogOut:(nonnull FBSDKLoginButton *)loginButton {
//    NSLog(@"Logged out");
//}


- (IBAction)logInTap:(id)sender {

    NSString *username = self.usernameField.text;
    NSString *password = self.passwordField.text;

    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error"
                                                                   message:@"Message" preferredStyle:(UIAlertControllerStyleAlert)];
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

    }
    else {

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

- (IBAction)screenTap:(id)sender {
    
    [self.view endEditing:YES];
    
}




@end
