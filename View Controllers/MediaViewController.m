//
//  MediaViewController.m
//  Watch Next
//
//  Created by brm14 on 7/15/20.
//  Copyright © 2020 Mason Creations. All rights reserved.
//

#import "MediaViewController.h"
#import <Parse/Parse.h>
#import "Interaction.h"

@interface MediaViewController ()

@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UISlider *ratingSlider;


@property(nonatomic) BOOL wwa;



@end

@implementation MediaViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.wwa = NO;
    // Do any additional setup after loading the view.
}

- (IBAction)watchNextTap:(id)sender {
    
    //check to make sure its not already on their watch next list
    
    NSString *title = self.titleLabel.text;
    NSString *testType = @"movie";
    
    [Interaction createWatchNext:title withType:testType withCompletion:^(BOOL succeeded, NSError * _Nullable error) {
          
        if(succeeded)
        {
            NSLog(@"success");
        }
        else
        {
            NSLog(@"failure");
        }
    }];
    
}

- (IBAction)watchedTap:(id)sender {
    
    //check to make sure its not already on their watch next list
    
    NSString *title = self.titleLabel.text;
    NSString *testType = @"movie";
    
    [Interaction createWatched:title withType:testType withCompletion:^(BOOL succeeded, NSError * _Nullable error) {

        if(succeeded)
        {
            NSLog(@"success");
        }
        else
        {
            NSLog(@"failure");
        }
    }];
    
}

- (IBAction)watchAgainTap:(id)sender {
    
    [sender setSelected:self.wwa];
    
    if(self.wwa == NO)
    {
        self.wwa = YES;
    }
    else
    {
        self.wwa = NO;
    }
    
}

- (IBAction)changeRatingSlider:(id)sender {
    
    NSNumber *stars = @(self.ratingSlider.value);
    
    [Interaction changeRating:stars forInteraction:@"NlwvsGKqsS" withCompletion:^(BOOL succeeded, NSError * _Nullable error) {
        
    }];
    
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
