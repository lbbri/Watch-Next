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
#import "UIImageView+AFNetworking.h"

@interface SearchViewController () <UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UISearchBar *searchBar;

@property (strong, nonatomic) NSMutableArray *searchResults;
@property (strong, nonatomic) NSDictionary *mediaDictionary;

@end

@implementation SearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.searchBar.delegate = self;
    
}

#pragma mark - Search Bar Controls
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    self.searchResults = (NSMutableArray *)@[];
    [self searchAPI];
    [self.tableView reloadData];
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


#pragma mark - Table View

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.searchResults.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    SearchResultsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SearchResultsCell"];
    
    NSDictionary *cellSearchDictionary = self.searchResults[indexPath.row];
    NSURL *tmdbURL = [self tmdbURLWithDictionary:cellSearchDictionary];
    [self tmdbDictionaryFromURL:tmdbURL forCell:cell];
    
    if(cell.mediaDictionary[@"title"])
    {
        cell.titleLabel.text = cell.mediaDictionary[@"title"];
    }else {
        cell.titleLabel.text = cell.mediaDictionary[@"name"];
    }
    cell.synopsisLabel.text = cell.mediaDictionary[@"overview"];
    cell.posterView.image = nil;
    [cell.posterView setImageWithURL:[self posterURLFromDictionary:cell.mediaDictionary]];
    
    return cell;
}

#pragma mark API Conversion

- (NSURL *)tmdbURLWithDictionary: (NSDictionary *) dictionary {
    
    NSDictionary *mediaExID = dictionary[@"external_ids"];
    NSDictionary *tmdbDictionary = mediaExID[@"tmdb"];
    NSString *tmdbURL = tmdbDictionary[@"url"];
    tmdbURL = [tmdbURL stringByReplacingOccurrencesOfString:@"https://www.themoviedb.org" withString:@"https://api.themoviedb.org/3"];
    
    NSString *finalURLString =[NSString stringWithFormat:@"%@?api_key=", tmdbURL];
    
    NSURL *finalURL = [NSURL URLWithString:finalURLString];
    
    return finalURL;
    
}


- (void) tmdbDictionaryFromURL: (NSURL *) url forCell: (SearchResultsTableViewCell *) cell{
    
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:20.0];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:nil delegateQueue:[NSOperationQueue mainQueue]];
    
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
           if (error != nil) {
               NSLog(@"%@", [error localizedDescription]);
           } else {
               
               NSDictionary *dataDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
               cell.mediaDictionary = dataDictionary;
               //[self.tableView reloadData];
           }
    }];

    [task resume];
    
    
}

#pragma mark - API Interactions

- (void)searchAPI {
    
    NSString *requestString = [NSString stringWithFormat:@"https://utelly-tv-shows-and-movies-availability-v1.p.rapidapi.com/lookup?term=%@&country=us", self.searchBar.text];
        
    requestString = [requestString stringByReplacingOccurrencesOfString: @" " withString:@"-"];
    
    NSDictionary *headers = @{ @"x-rapidapi-host": @"utelly-tv-shows-and-movies-availability-v1.p.rapidapi.com",
                               @"x-rapidapi-key": @"" };
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:requestString] cachePolicy:NSURLRequestUseProtocolCachePolicy
                                    timeoutInterval:20.0];
    [request setHTTPMethod:@"GET"];
    [request setAllHTTPHeaderFields:headers];
    NSURLSession *session = [NSURLSession sharedSession];
    
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            NSLog(@"%@", error);
        } else {
            NSDictionary *dataDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            self.searchResults = dataDictionary[@"results"];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
            });
        }
    }];
    [dataTask resume];
}

- (NSURL *)posterURLFromDictionary: (NSDictionary *)dictionary {
    
    NSString *baseURLString = @"https://image.tmdb.org/t/p/w500";
    NSString *posterURLString = dictionary[@"poster_path"];
    NSString *fullPosterURLString = [baseURLString stringByAppendingFormat:@"%@", posterURLString];
    
    return [NSURL URLWithString:fullPosterURLString];
}


#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    SearchResultsTableViewCell *tappedCell = sender;
    MediaViewController *mediaViewController = [segue destinationViewController];
    mediaViewController.mediaDictionary = tappedCell.mediaDictionary;
    
}


@end
