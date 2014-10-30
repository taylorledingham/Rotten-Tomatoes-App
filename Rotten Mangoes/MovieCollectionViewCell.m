//
//  MovieCollectionViewCell.m
//  Rotten Mangoes
//
//  Created by Taylor Ledingham on 2014-10-29.
//  Copyright (c) 2014 Taylor Ledingham. All rights reserved.
//

#import "MovieCollectionViewCell.h"

@implementation MovieCollectionViewCell

-(void)setUpCell:(Movie *)myMovie {
    
    self.movie = myMovie;
   [self.movieTitleLabel setText: self.movie.movieTitle];
    self.movieImage.image = self.movie.movieThumbnail;
  //  self.backgroundColor = [UIColor redColor];
    
}

@end
