//
//  SearchResultsTableViewCell.h
//  Watch Next
//
//  Created by brm14 on 7/14/20.
//  Copyright © 2020 Mason Creations. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SearchResultsTableViewCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UILabel *titleLabel;

@property (strong, nonatomic) IBOutlet UIImageView *posterView;
@property (strong, nonatomic) IBOutlet UILabel *synopsisLabel;

@property (nonatomic) NSDictionary *mediaDictionary;
@end

NS_ASSUME_NONNULL_END
