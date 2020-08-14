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

/** A UITableView that will present the search results.*/
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
/** Contains dictionaries that hold information about the movies and tv shows  that were returned from a singular search*/
@property (strong, nonatomic) NSMutableArray *searchResults;
@property (strong, nonatomic) NSDictionary *mediaDictionary;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;


@end

@implementation SearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.searchBar.delegate = self;
    [self.searchBar becomeFirstResponder];
}

-(void) viewWillAppear:(BOOL)animated {
    self.navigationController.navigationBarHidden = YES;
}

#pragma mark - Search Bar Controls

/**
 @brief Triggers a search for titles using the UTelly API. Once the search is complete, the table view can begin loading with data.
 @see searchAPI
 */
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    
    [self.activityIndicator startAnimating];
    [self searchAPI:^(BOOL completion){
        
        if(completion) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.activityIndicator stopAnimating];
                [self.tableView reloadData];
            });
        }
    }];
    [searchBar resignFirstResponder];
}


- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    self.searchBar.showsCancelButton = YES;
}


- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    self.searchBar.showsCancelButton = NO;
    self.searchBar.text = @"";
    [self.searchBar resignFirstResponder];
}


#pragma mark - Table View

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.searchResults.count;
}

/**
 @brief Fills the table view with cells that contain information on the returned titles from a search result.
 @discussion tableView gets a title's media dictionary from the searchResults. It passes that dictionary to a method and upon completion sets the cell's title label, synopsis label, and posterView to the correct properteis.
 @see tmbdDictionaryFromURL
 @return UITableViewCell cell at the current index with all of its properties filled in.
 */
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    SearchResultsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SearchResultsCell"];
    NSDictionary *cellSearchDictionary = self.searchResults[indexPath.row];
    NSURL *tmdbURL = [self tmdbURLWithDictionary:cellSearchDictionary];
    [self tmdbDictionaryFromURL:tmdbURL forCell:cell completion:^(BOOL completion){
        
        if(completion) {
            [self.activityIndicator startAnimating];
            if(cell.mediaDictionary[@"title"]) {
                cell.titleLabel.text = cell.mediaDictionary[@"title"];
            } else {
                cell.titleLabel.text = cell.mediaDictionary[@"name"];
            }
            cell.synopsisLabel.text = cell.mediaDictionary[@"overview"];
            cell.posterView.image = nil;
            if([cell.mediaDictionary[@"poster_path"] isEqual:[NSNull null]]) {
                [cell.posterView setContentMode: UIViewContentModeCenter];
                [cell.posterView setImage:[UIImage imageNamed:@"poster_placeholder"]];
                [self.activityIndicator stopAnimating];
                [cell.posterView setContentMode: UIViewContentModeScaleAspectFill];
                
            } else {
                [cell.posterView setImageWithURL:[self posterURLFromDictionary:cell.mediaDictionary]];
                
            }
        }
    }];
    
    return cell;
}


#pragma mark -- API Conversion

/**
 @brief Takes a UTelly dictionary, finds 'The Movie Database' ID for the title, and returns  'The Movie Database' dictionary for that same title.
 @discussion tmdbURLWithDictionary uses a UTelly dictionary to find the 'The Movie Database' ID by digging through multiple dictionary levels. Once the ID is acquired it is concatenated with other strings to produce a link that could make a 'The Movie Database' API call. Once that string is created it is converted into a URL.
 @property dictionary The UTelly Dictionary that was returned after a search was completed
 @return NSURL a URL that can be used to make a 'The Movie Database' API call.
 */
- (NSURL *)tmdbURLWithDictionary: (NSDictionary *) dictionary {
    
    NSDictionary *mediaExID = dictionary[@"external_ids"];
    NSDictionary *tmdbDictionary = mediaExID[@"tmdb"];
    NSString *tmdbURL = tmdbDictionary[@"url"];
    tmdbURL = [tmdbURL stringByReplacingOccurrencesOfString:@"https://www.themoviedb.org" withString:@"https://api.themoviedb.org/3"];
    NSString *finalURLString =[NSString stringWithFormat:@"%@?api_key=InsertAPIKey", tmdbURL];
    NSURL *finalURL = [NSURL URLWithString:finalURLString];
    return finalURL;
}

/**
 @brief Fills a cell's 'mediaDictionary' with a dictionary from 'The Movie Database' containing information regarding a specific title.
 @property url The url that is necessary to fufill a request and make the call to 'The Movie Database' API
 @property cell The cell who's mediaDictionary is being initialized.
 */
- (void) tmdbDictionaryFromURL: (NSURL *) url forCell: (SearchResultsTableViewCell *) cell completion:(void (^)(BOOL completion))completionBlock{
    
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:20.0];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:nil delegateQueue:[NSOperationQueue mainQueue]];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error != nil) {
            completionBlock(false);
        } else {
            NSDictionary *dataDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            cell.mediaDictionary = dataDictionary;
            completionBlock(true);
        }
    }];
    
    [task resume];
}

#pragma mark - API Interactions

- (void)searchAPI: (void (^)(BOOL completion))completionBlock {
    NSString *requestString = [NSString stringWithFormat:@"https://utelly-tv-shows-and-movies-availability-v1.p.rapidapi.com/lookup?term=%@&country=us", self.searchBar.text];
    requestString = [requestString stringByReplacingOccurrencesOfString: @" " withString:@"-"];
    NSDictionary *headers = @{ @"x-rapidapi-host": @"utelly-tv-shows-and-movies-availability-v1.p.rapidapi.com",
                               @"x-rapidapi-key": @"InsertAPIKey" };
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:requestString] cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:20.0];
    [request setHTTPMethod:@"GET"];
    [request setAllHTTPHeaderFields:headers];
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            completionBlock(false);
        } else {
            NSDictionary *dataDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            self.searchResults = dataDictionary[@"results"];
            completionBlock(true);
        }
    }];
    
    [dataTask resume];
}

#pragma mark - Helper Method

- (NSURL *)posterURLFromDictionary: (NSDictionary *)dictionary {
    
    NSString *baseURLString = @"https://image.tmdb.org/t/p/w500";
    NSString *posterURLString = dictionary[@"poster_path"];
    NSString *fullPosterURLString = [baseURLString stringByAppendingFormat:@"%@", posterURLString];
    [self.activityIndicator stopAnimating];
    return [NSURL URLWithString:fullPosterURLString];
}


#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    SearchResultsTableViewCell *tappedCell = sender;
    MediaViewController *mediaViewController = [segue destinationViewController];
    mediaViewController.mediaDictionary = tappedCell.mediaDictionary;
}


@end
