//
//  SearchViewController.m
//  Watch Next
//
//  Created by brm14 on 7/14/20.
//  Copyright © 2020 Mason Creations. All rights reserved.
//

#import "SearchViewController.h"
#import "SearchResultsTableViewCell.h"
#import "MediaViewController.h"

#import <Foundation/Foundation.h>


@interface SearchViewController () <UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) IBOutlet UISearchBar *searchBar;
@property (strong, nonatomic) NSMutableArray *searchResults;

//@property (nonatomic) NSString *tmdbURL;

@end

@implementation SearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.searchBar.delegate = self;
    
    //self.searchBar = [[UISearchBar alloc] init];
    //[self.searchBar sizeToFit];
    
    //self.navigationItem.titleView = self.searchBar;

}


- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    
    //TODO: connect to UTElly and searcj
    
    [self searchAPI];
    
}
//NOT WORKING
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    NSLog(@"hi");
    self.searchBar.showsCancelButton = YES;
}
//NOT WORKING
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    self.searchBar.showsCancelButton = NO;
    self.searchBar.text = @"";
    [self.searchBar resignFirstResponder];

}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
   // return 20;
    return self.searchResults.count;
}
//necessary for UITableViewSource implementation: asks data source for a cell to insert
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    SearchResultsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SearchResultsCell"];
    
    NSDictionary *media = self.searchResults[indexPath.row];
    NSDictionary *mediaExID = media[@"external_ids"];
   // NSLog(@"%@", mediaExID);
    
    NSDictionary *tmdbDictionary = mediaExID[@"tmdb"];
    cell.titleLabel.text = media[@"name"];
    //NSLog(@"%@", tmdbDictionary[@"id"]);
    
    NSString *tmdbURL = tmdbDictionary[@"url"];
    [self getTMBDDictionary:tmdbURL];

    
    return cell;
}

- (void)searchAPI {
    
    NSString *requestString = [NSString stringWithFormat:@"https://utelly-tv-shows-and-movies-availability-v1.p.rapidapi.com/lookup?term=%@&country=us", self.searchBar.text];
        
    requestString = [requestString stringByReplacingOccurrencesOfString: @" " withString:@"-"];
    
    NSDictionary *headers = @{ @"x-rapidapi-host": @"utelly-tv-shows-and-movies-availability-v1.p.rapidapi.com",
                               @"x-rapidapi-key": @"65fd490d94msh0c0e7a08fe2fe52p1bb9cdjsnc6d7c863587a" };


    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:requestString]
        cachePolicy:NSURLRequestUseProtocolCachePolicy
    timeoutInterval:10.0];
    
    
    [request setHTTPMethod:@"GET"];
    [request setAllHTTPHeaderFields:headers];

    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request
                                                completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                                    if (error) {
                                                        NSLog(@"%@", error);
                                                    } else {
                                                        //NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
                                                        //NSLog(@"%@", httpResponse);
                                                        
                                                        NSDictionary *dataDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
                                                        self.searchResults = dataDictionary[@"results"];
                                                       // NSLog(@"%@", dataDictionary);
                                                    }
                                                }];
    [dataTask resume];
    [self.tableView reloadData];

    
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    UICollectionViewCell *tappedCell = sender;
    NSIndexPath *indexPath= [self.tableView indexPathForCell:tappedCell];
    NSDictionary *media = self.searchResults[indexPath.row];
    
    MediaViewController *mediaViewController = [segue destinationViewController];
    mediaViewController.media = media;
}

- (void) getTMBDDictionary: (NSString *)link {
    
    link = [link stringByReplacingOccurrencesOfString:@"https://www.themoviedb.org" withString:@"https://api.themoviedb.org/3"];
    NSString *requestString = [NSString stringWithFormat:@"%@?api_key=2c075d6299d70eaf6f4a13fc180cb803", link];
    
   // NSLog(requestString);
    
    NSURL *url = [NSURL URLWithString:requestString];
    //NSURL *url = [NSURL URLWithString:@"https://api.themoviedb.org/3/tv/49297?api_key=2c075d6299d70eaf6f4a13fc180cb803"];
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:10.0];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:nil delegateQueue:[NSOperationQueue mainQueue]];
       
       
       NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
             //if there was an error when with getting the JSON
              if (error != nil) {
                  NSLog(@"%@", [error localizedDescription]);
              } else {
                  
                  //load JSON data into dataDictionary
                  NSDictionary *dataDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
                  NSLog(@"%@", dataDictionary[@"name"]);
              }
           
       }];
       [task resume];
    
    
}






@end
