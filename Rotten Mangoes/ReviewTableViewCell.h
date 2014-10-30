//
//  ReviewTableViewCell.h
//  Rotten Mangoes
//
//  Created by Taylor Ledingham on 2014-10-29.
//  Copyright (c) 2014 Taylor Ledingham. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ReviewTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *reviewerNameLabel;
@property (weak, nonatomic) IBOutlet UITextView *reviewQuoteTextView;

@end
