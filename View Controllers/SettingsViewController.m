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

@property (weak, nonatomic) IBOutlet PFImageView *profilePictureView;

@end

@implementation SettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    WatchNextUser *user = [WatchNextUser currentUser];
    self.profilePictureView.file = user.profilePicture;
    [self.profilePictureView loadInBackground];
    
}

- (IBAction)didTapLogout:(id)sender {
    
    SceneDelegate *myDelegate = (SceneDelegate *)self.view.window.windowScene.delegate;
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil] ;
    LogInViewController *loginViewController = [storyboard instantiateViewControllerWithIdentifier:@"LoginViewController"];
    
    myDelegate.window.rootViewController = loginViewController;
    
    [WatchNextUser logOutInBackgroundWithBlock:^(NSError * _Nullable error) {
    }];
    
}


- (IBAction)changePPTap:(id)sender {
    
    UIImagePickerController *imagePickerVC = [UIImagePickerController new];
    imagePickerVC.delegate = self;
    imagePickerVC.allowsEditing = YES;
    
    if([UIImagePickerController isSourceTypeAvailable:(UIImagePickerControllerSourceTypeCamera)])
    {
        imagePickerVC.sourceType = UIImagePickerControllerSourceTypeCamera;
    }
    else
    {
        imagePickerVC.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    }
    
    [self presentViewController:imagePickerVC animated:YES completion:nil];
}

- (void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo: (NSDictionary<NSString *, id>*)info {
    
    //gets the image captured by the UIImagePickerController
    UIImage *editedImage = info[UIImagePickerControllerEditedImage];
    
    editedImage = [self resizeImage:editedImage withSize:CGSizeMake(200.0 , 200.0)];
    
    self.profilePictureView.image = editedImage;
    [self dismissViewControllerAnimated:YES completion:nil];
    
    [WatchNextUser changeProfilePicture:editedImage withCompletion:^(BOOL succeeded, NSError * _Nullable error) {
        //
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

/*
#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
}
*/

@end
