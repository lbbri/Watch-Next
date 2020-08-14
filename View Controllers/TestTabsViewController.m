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
    [self setUpVisuals];
}

- (void) viewWillAppear:(BOOL)animated {
    self.navigationController.navigationBarHidden = YES;
}


- (void) tabBar:(MDCTabBar *)tabBar didSelectItem:(UITabBarItem *)item {
    
    if(item.tag == 0) {
        self.containerVeiwA.alpha = 1;
        self.containerViewB.alpha = 0;
    } else {
        self.containerVeiwA.alpha = 0;
        self.containerViewB.alpha = 1;
    }
    
}

- (void) setUpVisuals {
    
    self.tabBar = [[MDCTabBar alloc] initWithFrame: CGRectMake(0, 45, 414, 600)];
    self.tabBar.delegate = self;
    self.tabBar.items = @[
        [[UITabBarItem alloc] initWithTitle:@"Trending" image:nil tag:0],
        [[UITabBarItem alloc] initWithTitle:@"Suggestions" image:nil tag:1],
    ];
    
    self.tabBar.tintColor = [UIColor colorWithRed: 0.95 green: 0.77 blue: 0.06 alpha: 1.00];
    self.tabBar.alignment = MDCTabBarAlignmentJustified;
    self.tabBar.itemAppearance = MDCTabBarItemAppearanceTitles;
    self.tabBar.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
    [self.tabBar sizeToFit];
    [self.view addSubview:self.tabBar];
    
    self.navigationController.navigationBarHidden = YES;
    
}

@end
