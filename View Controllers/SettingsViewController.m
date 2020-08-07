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
//#import <FBSDKLoginKit/FBSDKLoginKit.h>

@interface SettingsViewController ()

@property (weak, nonatomic) IBOutlet PFImageView *profilePictureView;
@property (weak, nonatomic) IBOutlet UILabel *watchedNumLabel;
@property (weak, nonatomic) IBOutlet UILabel *watchNextNumLabel;
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@end

@implementation SettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    WatchNextUser *user = [WatchNextUser currentUser];
    self.usernameLabel.text = [NSString stringWithFormat:@"Hey %@!", user.username];
    self.profilePictureView.file = user.profilePicture;
    self.watchedNumLabel.text = [NSString stringWithFormat:@"%lu", user.watched.count];
    self.watchNextNumLabel.text = [NSString stringWithFormat:@"%lu", user.watchNext.count];
    [self.profilePictureView loadInBackground];
    
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


#pragma mark - Profile Picture

- (IBAction)changePPTap:(id)sender {
    [self.activityIndicator startAnimating];
    UIImagePickerController *imagePickerVC = [UIImagePickerController new];
    imagePickerVC.delegate = self;
    imagePickerVC.allowsEditing = YES;
    
    if([UIImagePickerController isSourceTypeAvailable:(UIImagePickerControllerSourceTypeCamera)]) {
        imagePickerVC.sourceType = UIImagePickerControllerSourceTypeCamera;
    }
    else {
        imagePickerVC.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    }
    [self presentViewController:imagePickerVC animated:YES completion:nil];
}

- (void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo: (NSDictionary<NSString *, id>*)info {
    
    UIImage *editedImage = info[UIImagePickerControllerEditedImage];
    editedImage = [self resizeImage:editedImage withSize:CGSizeMake(200.0 , 200.0)];
    self.profilePictureView.image = editedImage;
    [self.activityIndicator stopAnimating];
    [self dismissViewControllerAnimated:YES completion:nil];
    [WatchNextUser changeProfilePicture:editedImage withCompletion:^(BOOL succeeded, NSError * _Nullable error) {
    }];
}

- (UIImage *)resizeImage:(UIImage *)image withSize:(CGSize)size {
    
    UIImageView *resizeImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
    resizeImageView.contentMode = UIViewContentModeScaleAspectFill;
    resizeImageView.image = image;
    UIGraphicsBeginImageContext(size);
    [resizeImageView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}


@end
