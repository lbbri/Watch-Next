//
//  TestTabsViewController.m
//  Watch Next
//
//  Created by brm14 on 8/4/20.
//  Copyright © 2020 Mason Creations. All rights reserved.
//

#import "TestTabsViewController.h"
#import "MaterialTabs.h"

@interface TestTabsViewController () <MDCTabBarDelegate>

@property(strong, nonatomic) IBOutlet MDCTabBar *tabBar;
@property (weak, nonatomic) IBOutlet UIView *containerVeiwA;
@property (weak, nonatomic) IBOutlet UIView *containerViewB;



@end

@implementation TestTabsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    //self.tabBar = [[MDCTabBar alloc] initWithFrame:screenRect];
    self.tabBar = [[MDCTabBar alloc] initWithFrame: CGRectMake(0, 45, 414, 600)];

    self.tabBar.delegate = self;

    
    self.tabBar.items = @[
        [[UITabBarItem alloc] initWithTitle:@"Suggestions" image:nil tag:0],
        [[UITabBarItem alloc] initWithTitle:@"Trending" image:nil tag:1],
    ];
    
   // [self.tabBar targetForAction:@selector(tabBar) withSender:<#(nullable id)#>]
    
    //[self.tabBar ]
    
    self.tabBar.tintColor = [UIColor colorWithRed: 0.95 green: 0.77 blue: 0.06 alpha: 1.00];
    //self.tabBar.barTintColor = UIColor.blueColor;
    self.tabBar.alignment = MDCTabBarAlignmentJustified;
    self.tabBar.itemAppearance = MDCTabBarItemAppearanceTitles;
    self.tabBar.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
    [self.tabBar sizeToFit];
    [self.view addSubview:self.tabBar];
    
    // Do any additional setup after loading the view.
}



- (void) tabBar:(MDCTabBar *)tabBar didSelectItem:(UITabBarItem *)item {
    
    if(item.tag == 0) {
        self.containerVeiwA.alpha = 0;
        self.containerViewB.alpha = 1;
    } else {
        self.containerVeiwA.alpha = 1;
        self.containerViewB.alpha = 0;
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
