//
//  SignUpViewController.m
//  Watch Next
//
//  Created by brm14 on 7/14/20.
//  Copyright © 2020 Mason Creations. All rights reserved.
//

#import "SignUpViewController.h"
#import <Parse/Parse.h>
#import "../Data Models/WatchNextUser.h"


@interface SignUpViewController ()

@property (weak, nonatomic) IBOutlet UITextField *usernameField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;

@end

@implementation SignUpViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
}

- (IBAction)signUpTap:(id)sender {
    
    WatchNextUser *newUser = [WatchNextUser user];
    
    newUser.username = self.usernameField.text;
    newUser.password = self.passwordField.text;
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error" message:@"Message" preferredStyle:(UIAlertControllerStyleAlert)];
    UIAlertAction *tryAgainAction = [UIAlertAction actionWithTitle:@"Try Again" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        //handle try agin here. Doing nothing will dismiss the view.
    }];
    [alert addAction:tryAgainAction];
    
    
    if([self.usernameField.text isEqual:@""])
    {
        alert.message = @"User Name cannot be empty";
        [self presentViewController:alert animated:YES completion:^{
        }];
        
    }
    else if ([self.passwordField.text isEqual:@""])
    {
        alert.message = @"Password cannot be empty";
        [self presentViewController:alert animated:YES completion:^{
        }];
        
    }
    else
    {
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
