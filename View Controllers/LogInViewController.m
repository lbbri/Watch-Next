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

@interface LogInViewController ()

@property (strong, nonatomic) IBOutlet UITextField *usernameField;
@property (strong, nonatomic) IBOutlet UITextField *passwordField;

@end

@implementation LogInViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}


- (IBAction)logInTap:(id)sender {
    
    NSString *username = self.usernameField.text;
    NSString *password = self.passwordField.text;
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error"
                                                                   message:@"Message" preferredStyle:(UIAlertControllerStyleAlert)];
    UIAlertAction *tryAgainAction = [UIAlertAction actionWithTitle:@"Try Again" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        //Doing nothing will dismiss the view.
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



/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
