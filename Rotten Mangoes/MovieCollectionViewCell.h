//
//  MovieCollectionViewCell.h
//  Rotten Mangoes
//
//  Created by Taylor Ledingham on 2014-10-29.
//  Copyright (c) 2014 Taylor Ledingham. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Movie.h"

@interface MovieCollectionViewCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIImageView *movieImage;
@property (weak, nonatomic) IBOutlet UILabel *movieTitleLabel;
@property (strong, nonatomic) Movie *movie;

-(void)setUpCell:(Movie *)myMovie;


@end
