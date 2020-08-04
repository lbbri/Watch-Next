//
//  SignUpViewController.m
//  Watch Next
//
//  Created by brm14 on 7/14/20.
//  Copyright © 2020 Mason Creations. All rights reserved.
//

#import "SignUpViewController.h"
#import "WatchNextUser.h"
#import <Parse/Parse.h>

@interface SignUpViewController ()

@property (weak, nonatomic) IBOutlet UITextField *usernameField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;

@end

@implementation SignUpViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
}
/**
 @brief Allows the user to create a new Watch Next account with a username and password.
 @discussion signUpTap insures the username and password fields are not empty before proceeding to creating an account. If either field is empty an error alert is presented. If both fields contain text then Parse creates a new WatchNext User (a subclass of PFUser) and segues the user to the home screen.
 */
- (IBAction)signUpTap:(id)sender {
    
    WatchNextUser *newUser = [WatchNextUser user];
    
    newUser.username = self.usernameField.text;
    newUser.password = self.passwordField.text;
    
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
        [newUser signUpInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
            if (error != nil) {
                alert.message = error.localizedDescription;
                [self presentViewController:alert animated:YES completion:^{
                }];
            } else {
                [self performSegueWithIdentifier:@"signupSegue" sender:nil];
            }
        }];
    }
}


@end
