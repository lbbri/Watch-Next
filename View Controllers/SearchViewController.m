//
//  SearchViewController.m
//  Watch Next
//
//  Created by brm14 on 7/14/20.
//  Copyright © 2020 Mason Creations. All rights reserved.
//

#import "SearchViewController.h"
#import "SearchResultsTableViewCell.h"

@interface SearchViewController () <UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation SearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.searchBar.delegate = self;
    
    self.searchBar = [[UISearchBar alloc] init];
    [self.searchBar sizeToFit];
    
    // the UIViewController comes with a navigationItem property
    // this will automatically be initialized for you if when the
    // view controller is added to a navigation controller's stack
    // you just need to set the titleView to be the search bar
    self.navigationItem.titleView = self.searchBar;

    // Do any additional setup after loading the view.
}



//NOT WORKING
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    self.searchBar.showsCancelButton = YES;
}
//NOT WORKING
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    self.searchBar.showsCancelButton = NO;
    self.searchBar.text = @"";
    [self.searchBar resignFirstResponder];

}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 20;
}
//necessary for UITableViewSource implementation: asks data source for a cell to insert
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    //use the Movie cell I set up on the storyboard
    SearchResultsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SearchResultsCell"];
    //load movie at indexPath from movies array into movie dictionary, so that we can access it's id's
    
    return cell;
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
