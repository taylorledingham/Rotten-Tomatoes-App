//
//  MovieCollectionViewController.h
//  Rotten Mangoes
//
//  Created by Taylor Ledingham on 2014-10-29.
//  Copyright (c) 2014 Taylor Ledingham. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MovieCollectionViewCell.h"
#import "Movie.h"
#import "DetailMovieTableViewController.h"
#import "MovieCollectionViewFooterCollectionReusableView.h"

@interface MovieCollectionViewController : UICollectionViewController

@property (strong, nonatomic) NSMutableArray *movieDictionary;
@property (strong, nonatomic) NSMutableArray *movieArray;


@end
