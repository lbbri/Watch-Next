//
//  ListsViewController.m
//  Watch Next
//
//  Created by brm14 on 8/5/20.
//  Copyright © 2020 Mason Creations. All rights reserved.
//

#import "ListsViewController.h"
#import "MaterialTabs.h"

@interface ListsViewController () <MDCTabBarDelegate>

@property(strong, nonatomic) IBOutlet MDCTabBar *tabBar;
@property (weak, nonatomic) IBOutlet UIView *wathedContainer;
@property (weak, nonatomic) IBOutlet UIView *watchNextContainer;

@end

@implementation ListsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUpVisuals];
}

- (void) viewWillAppear:(BOOL)animated {
    self.navigationController.navigationBarHidden = YES;
}

- (void) tabBar:(MDCTabBar *)tabBar didSelectItem:(UITabBarItem *)item {
    
    if(item.tag == 0) {
        self.wathedContainer.alpha = 1;
        self.watchNextContainer.alpha = 0;
    } else {
        self.watchNextContainer.alpha = 1;
        self.wathedContainer.alpha = 0;
    }
    
}

- (void) setUpVisuals {
    
    self.tabBar = [[MDCTabBar alloc] initWithFrame: CGRectMake(0, 45, 414, 600)];
    self.tabBar.delegate = self;
    self.tabBar.items = @[
        [[UITabBarItem alloc] initWithTitle:@"Watched" image:nil tag:0],
        [[UITabBarItem alloc] initWithTitle:@"Watch Next" image:nil tag:1],
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
