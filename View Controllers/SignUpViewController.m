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

#import <MaterialTextFields.h>
#import <MaterialButtons.h>
#import "MaterialButtons+ButtonThemer.h"
#import "MDCButton+MaterialTheming.h"

@interface SignUpViewController () <UITextFieldDelegate>

@property (weak,nonatomic) IBOutlet MDCTextField *nameField;
@property (weak, nonatomic) IBOutlet MDCTextField *usernameField;
@property (weak, nonatomic) IBOutlet MDCTextField *passwordField;
@property (weak, nonatomic) IBOutlet MDCTextField *retypeField;
@property (weak, nonatomic) IBOutlet MDCButton *signUpButton;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;



@property(nonatomic) MDCTextInputControllerOutlined *nameController;
@property(nonatomic) MDCTextInputControllerOutlined *usernameController;
@property(nonatomic) MDCTextInputControllerOutlined *passwordController;
@property(nonatomic) MDCTextInputControllerOutlined *retypeController;

@end

@implementation SignUpViewController 

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    [self setUpVisuals];
}
/**
 @brief Allows the user to create a new Watch Next account with a username and password.
 @discussion signUpTap insures the username and password fields are not empty before proceeding to creating an account. If either field is empty an error alert is presented. If both fields contain text then Parse creates a new WatchNext User (a subclass of PFUser) and segues the user to the home screen.
 */
- (IBAction)signUpTap:(id)sender {
    [self.activityIndicator startAnimating];
    
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
    
    [self.activityIndicator stopAnimating];
}

#pragma mark - Visual Polish

- (void) setUpVisuals {
    
    self.nameField.placeholder = @"Name";
    self.usernameField.placeholder = @"Username";
    self.passwordField.placeholder = @"Password";
    self.retypeField.placeholder = @"Retype Password";
    
    
    self.nameController = [[MDCTextInputControllerOutlined alloc] initWithTextInput:self.nameField];
    self.usernameController = [[MDCTextInputControllerOutlined alloc] initWithTextInput:self.usernameField];
    self.passwordController = [[MDCTextInputControllerOutlined alloc] initWithTextInput:self.passwordField];
    self.retypeController = [[MDCTextInputControllerOutlined alloc] initWithTextInput:self.retypeField];
    
    self.passwordField.delegate = self;
    self.retypeField.delegate = self;
    
    MDCContainerScheme *containerScheme = [[MDCContainerScheme alloc] init];
    containerScheme.colorScheme.primaryColor = UIColor.lightGrayColor;
    
    [self.signUpButton applyContainedThemeWithScheme: containerScheme];
    [self.signUpButton setTitle:@"Sign Up" forState:UIControlStateNormal];
    self.signUpButton.minimumSize = CGSizeMake(64, 36);
    CGFloat verticalInset = MIN(0, (CGRectGetHeight(self.signUpButton.bounds) - 48) / 2);
    self.signUpButton.hitAreaInsets = UIEdgeInsetsMake(verticalInset, 0, verticalInset, 0);
    

}


- (BOOL)textFieldShouldReturn:(UITextField *)textField {
  [textField resignFirstResponder];

  // Text Field Validation
  if (textField == (UITextField *)self.retypeField) {
      if (![self.retypeField.text isEqualToString:self.passwordField.text]) {
       [self.retypeController setErrorText:@"Passwords Must Match" errorAccessibilityValue:nil];
    } else {
       [self.retypeController setErrorText:nil errorAccessibilityValue:nil];
    }
  }

  return NO;
}


@end
