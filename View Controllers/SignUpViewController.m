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

@property (strong, nonatomic) IBOutlet UITextField *usernameField;
@property (strong, nonatomic) IBOutlet UITextField *passwordField;

@end

@implementation SignUpViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (IBAction)signUpTap:(id)sender {
    
    //WatchNextUser *newUser = [WatchNextUser user];
    PFUser *newUser = [PFUser user];
    
    newUser.username = self.usernameField.text;
    newUser.password = self.passwordField.text;
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error"
                                                                   message:@"Message" preferredStyle:(UIAlertControllerStyleAlert)];
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
           if (error != nil)
           {
               NSLog([NSString stringWithFormat:@"username: %@ and password: %@",newUser.username, newUser.password]);
               alert.message = error.localizedDescription;
               [self presentViewController:alert animated:YES completion:^{
               }];
           }
           else
           {
               NSLog(@"success");
               [self performSegueWithIdentifier:@"signupSegue" sender:nil];
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
