//
//  DetailMovieTableViewController.h
//  Rotten Mangoes
//
//  Created by Taylor Ledingham on 2014-10-29.
//  Copyright (c) 2014 Taylor Ledingham. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Movie.h"
#import "TheatreMapViewController.h"
#import <SDWebImageManager.h>

@interface DetailMovieTableViewController : UITableViewController

@property (weak, nonatomic) IBOutlet UILabel *movieTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *releaseDateLabel;
@property (weak, nonatomic) IBOutlet UITextView *movieDescLabel;
@property (weak, nonatomic) IBOutlet UIImageView *moviePosterImage;
@property (weak, nonatomic) IBOutlet UILabel *criticScoreLabel;
@property (weak, nonatomic) IBOutlet UILabel *audienceScoreLabel;

@property (strong, nonatomic) Movie *currMovie;
- (IBAction)getMovieListings:(id)sender;

@end
