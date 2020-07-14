//
//  UserViewController.m
//  Watch Next
//
//  Created by brm14 on 7/14/20.
//  Copyright © 2020 Mason Creations. All rights reserved.
//

#import "UserViewController.h"
//#import "UserPageViewController.h"
//#import "DataViewController.h"
#import "MediaCollectionViewCell.h"

@interface UserViewController () <UICollectionViewDataSource, UICollectionViewDelegate>
//<UIPageViewControllerDelegate, UIPageViewControllerDataSource>

//@property (strong, nonatomic) NSArray *data;
//@property NSInteger *currentVCIndex;

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (strong, nonatomic) IBOutlet UISegmentedControl *pageControl;



@end

@implementation UserViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    
    UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *)self.collectionView.collectionViewLayout;
    
    
    //can also set in storyboard
    layout.minimumInteritemSpacing = 3;
    layout.minimumLineSpacing = 3;
    
    CGFloat postersPerLine = 3;
    
    //correctly calculates layout based on how many movies are on each row
    CGFloat itemWidth = (self.collectionView.frame.size.width - layout.minimumInteritemSpacing * (postersPerLine-1)) / postersPerLine;
    CGFloat itemHeight = itemWidth * 1.5;
    
    layout.itemSize = CGSizeMake(itemWidth, itemHeight);
    
    [self.collectionView reloadData];
    
    
//    self.currentVCIndex = 0;
//
//    [self configurePageViewController];
    
    
    // Do any additional setup after loading the view.
}

- (nonnull __kindof UICollectionViewCell *)collectionView:(nonnull UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    MediaCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"UserMediaCell" forIndexPath:indexPath];
    
    if(self.pageControl.selectedSegmentIndex == 0)
    {
        cell.testingLabel2.text = @"1";
    }
    else if(self.pageControl.selectedSegmentIndex == 1)
    {
        cell.testingLabel2.text = @"2";
    }
    else
    {
        cell.testingLabel2.text = @"3";
    }

    
    
    return cell;
}

//necessary function to implement UICollectionViewDataSource similar to TableView
- (NSInteger)collectionView:(nonnull UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    if(self.pageControl.selectedSegmentIndex == 0)
    {
        return 10;
    }
    else if(self.pageControl.selectedSegmentIndex == 1)
    {
        return 30;
    }
    else
    {
        return 40;
    }
    return 0;
}

- (IBAction)viewChanged:(id)sender {
   
    [self.collectionView reloadData];

}



//- (void) configurePageViewController {
//    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil] ;
//
//    UserPageViewController *userPVC = [storyboard instantiateViewControllerWithIdentifier:@"UserPageViewController"];
//
//    userPVC.delegate = self;
//    userPVC.dataSource = self;
//
//    [self addChildViewController:userPVC];
//    [userPVC didMoveToParentViewController:self];
//
//    //restraints to make sure page vc fit
//
//    userPVC.view.translatesAutoresizingMaskIntoConstraints = false;
//    //[self.contentView addSubview:self.contentView];
//    [self.contentView addSubview:userPVC.view];
//
//    //NSDictionary *views = [NSDictionary dictionaryWithObject:userPVC forKey:@"key1"];
//    //NSDictionary *views = @{@"view": userPVC};
//
//    //[self.contentView addConstraint:[NSLayoutConstraint constraintsWithVisualFormat:@"" options: [NSLayoutFormatOptions:0] metrics:nil views:views]];
//
//
//    UIViewController *startingVC = [self detailViewControllerAt:self.currentVCIndex];
//
//    [userPVC setViewControllers:(NSArray *)startingVC direction: UIPageViewControllerNavigationDirectionForward animated:YES completion:^(BOOL finished) {
//
//    }];
//}
//
//- (DataViewController *) detailViewControllerAt: (NSInteger *) index {
//
//
//    if( index >= (NSInteger *)self.data.count)
//    {
//        return nil;
//    }
//    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil] ;
//   // DataViewController *dataViewController = [storyboard instantiateViewControllerWithIdentifier:[NSString stringWithFormat:@"%@", DataViewController.self]];
//    DataViewController *dataViewController = [storyboard instantiateViewControllerWithIdentifier:@"DataViewController"];
//
//
//    dataViewController.index = index;
//    dataViewController.dataLabel = self.data[(NSInteger)index];
//
//    return dataViewController;
//
//}
//
//
//- (NSInteger)presentationIndexForPageViewController:(UIPageViewController *)pageViewController {
//    return (NSInteger)self.currentVCIndex;
//}
//
//- (NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController {
//    return self.data.count;
//}
//
//- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {
//
//    DataViewController *dataViewController = [[DataViewController alloc] init];
//    NSInteger *currentIndex = dataViewController.index;
//
//    self.currentVCIndex = currentIndex;
//
//    if(currentIndex == 0)
//    {
//        return nil;
//    }
//
//    currentIndex -=1;
//    return [self detailViewControllerAt:currentIndex];
//}
//
//- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
//
//    DataViewController *dataViewController = [[DataViewController alloc] init];
//    NSInteger *currentIndex = dataViewController.index;
//
//    self.currentVCIndex = currentIndex;
//
//    if(currentIndex == 3)
//    {
//        return nil;
//    }
//
//    currentIndex +=1;
//    return [self detailViewControllerAt:currentIndex];
//
//}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
