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
#import <MaterialTextFields.h>
#import <MaterialButtons.h>
#import "MaterialButtons+ButtonThemer.h"
#import "MDCButton+MaterialTheming.h"


@interface LogInViewController () 

@property (weak, nonatomic) IBOutlet MDCTextField *usernameField;
@property (weak, nonatomic) IBOutlet MDCTextField *passwordField;
@property (weak, nonatomic) IBOutlet MDCButton *loginButton;
@property (weak, nonatomic) IBOutlet MDCButton *FBButton;

@property(nonatomic) MDCTextInputControllerOutlined *usernameController;
@property(nonatomic) MDCTextInputControllerOutlined *passwordController;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@end

@implementation LogInViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    [self setUpVisuals];
}

#pragma mark - FBSDK Login

/**
 * @brief Allows user to log in  using a new or already existing Facebook account.
 * @discussion loginWithFacebookTap takes the user to a Facebook login screen where they can either sign in with an already existing Facebook account or create a new Facebook account and continue. If there is no user matching the inputted credentials an error alert is presented. If the user creates a new account or uses and already existing account the user is logged in and segued to the home screen.
 * @see changeViews
 */
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

/**
@brief Allows user to login with an already existing Watch Next account.
@discussion logInTap insures the username and password fields are not empty before checking if the credintials match that of a valid user. If either field is empty an error alert is presented. If Parse finds a user with matching credentials it continues to log the user in and segues to the home page. If the credentials are invalid an error alert is presented.
*/
- (IBAction)logInTap:(id)sender {
    [self.activityIndicator startAnimating];

    NSString *username = self.usernameField.text;
    NSString *password = self.passwordField.text;

    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error" message:@"Message" preferredStyle:(UIAlertControllerStyleAlert)];
    UIAlertAction *tryAgainAction = [UIAlertAction actionWithTitle:@"Try Again" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        }];
    [alert addAction:tryAgainAction];

    if([self.usernameField.text isEqual:@""]) {
        [self.activityIndicator stopAnimating];
        alert.message = @"User Name cannot be empty";
        [self presentViewController:alert animated:YES completion:^{
        }];
        
    } else if ([self.passwordField.text isEqual:@""]) {
        [self.activityIndicator stopAnimating];
        alert.message = @"Password cannot be empty";
        [self presentViewController:alert animated:YES completion:^{
        }];

    } else {
       [WatchNextUser logInWithUsernameInBackground:username password:password block:^(PFUser * user, NSError *  error) {
            if (error != nil) {
                [self.activityIndicator stopAnimating];
                alert.message = error.localizedDescription;
                [self presentViewController:alert animated:YES completion:^{
                }];
            } else {
                [self performSegueWithIdentifier:@"loginSegue" sender:nil];
                [self.activityIndicator stopAnimating];

            }
        }];
    }
}

#pragma mark - Animations
/** Drops the keyboard if anywhere else on the screen is tapped.*/
- (IBAction)screenTap:(id)sender {
    
    [self.view endEditing:YES];
}

#pragma mark - Helper Methods

/** Takes the user to the home screen. */
- (void) changeViews {
    
    SceneDelegate *myDelegate = (SceneDelegate *)self.view.window.windowScene.delegate;
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil] ;
    UITabBarController * tabBarController = [storyboard instantiateViewControllerWithIdentifier:@"MainTabBarController"];
    myDelegate.window.rootViewController = tabBarController;
}


#pragma mark - Visual Polish

- (void) setUpVisuals {
    
    self.usernameField.placeholder = @"Username";
    self.passwordField.placeholder = @"Password";
    
    self.usernameController = [[MDCTextInputControllerOutlined alloc] initWithTextInput:self.usernameField];
    self.passwordController = [[MDCTextInputControllerOutlined alloc] initWithTextInput:self.passwordField];
    
    MDCContainerScheme *containerScheme = [[MDCContainerScheme alloc] init];
    containerScheme.colorScheme.primaryColor = UIColor.lightGrayColor;
    
    [self.loginButton applyContainedThemeWithScheme: containerScheme];
    [self.loginButton setTitle:@"Log In" forState:UIControlStateNormal];
    self.loginButton.minimumSize = CGSizeMake(64, 36);
    CGFloat verticalInset = MIN(0, (CGRectGetHeight(self.loginButton.bounds) - 48) / 2);
    self.loginButton.hitAreaInsets = UIEdgeInsetsMake(verticalInset, 0, verticalInset, 0);
    
    MDCContainerScheme *FBcontainerScheme = [[MDCContainerScheme alloc] init];
    FBcontainerScheme.colorScheme.primaryColor = [UIColor colorWithRed: 0.20 green: 0.60 blue: 0.86 alpha: 1.00];
    
    [self.FBButton applyContainedThemeWithScheme: FBcontainerScheme];
    [self.FBButton setTitle:@"Continue with Facebook" forState:UIControlStateNormal];
    self.FBButton.minimumSize = CGSizeMake(64, 36);
    CGFloat FBverticalInset = MIN(0, (CGRectGetHeight(self.loginButton.bounds) - 48) / 2);
    self.FBButton.hitAreaInsets = UIEdgeInsetsMake(FBverticalInset, 0, FBverticalInset, 0);
    
    

}

@end
