//
//  MovieCollectionViewCell.m
//  Rotten Mangoes
//
//  Created by Taylor Ledingham on 2014-10-29.
//  Copyright (c) 2014 Taylor Ledingham. All rights reserved.
//

#import "MovieCollectionViewCell.h"
#import <SDWebImageManager.h>

@implementation MovieCollectionViewCell

-(void)setUpCell:(Movie *)myMovie {
    
    self.movie = myMovie;
   [self.movieTitleLabel setText: self.movie.movieTitle];
    
    SDWebImageManager *manager = [SDWebImageManager sharedManager];
    [manager downloadImageWithURL:self.movieImageURL options:0 progress:^(NSInteger receivedSize, NSInteger expectedSize) {
        NSLog(@"downloading image: %f %%", (float)receivedSize/(float)expectedSize);
    } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
        NSLog(@"%@", image);
        self.movieImageView.image = image;

    }
     
     ];
    
    
    
}

@end
