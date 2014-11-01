//
//  DetailMovieTableViewController.m
//  Rotten Mangoes
//
//  Created by Taylor Ledingham on 2014-10-29.
//  Copyright (c) 2014 Taylor Ledingham. All rights reserved.
//

#import "DetailMovieTableViewController.h"
#import "ReviewTableViewController.h"

@interface DetailMovieTableViewController ()

@end

@implementation DetailMovieTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    NSDateFormatter * dateFormat = [[NSDateFormatter alloc] init];
    //[dateFormat setDateFormat:@"MMM. dd, yyyy"];
    [dateFormat setDateFormat:@"yyyy-MM-dd"];
    
    NSDate *movieDate = [dateFormat dateFromString:self.currMovie.releaseDate];
    [dateFormat setDateFormat:@"MMM. dd, yyyy"];

    
    self.movieTitleLabel.text = self.currMovie.movieTitle;
    if(self.currMovie.movieSynopsis == nil){
        self.movieDescLabel.text  = @"No Synopsis";
    }
    else {
        self.movieDescLabel.text = self.currMovie.movieSynopsis;
     }
    if (self.currMovie.releaseDate == nil){
        self.releaseDateLabel.text = @"Release Date not available";
    }
    else {
        self.releaseDateLabel.text = [NSString stringWithFormat:@"Release Date: %@" ,[dateFormat stringFromDate:movieDate]];
    }
    
    //self.moviePosterImage.image = self.currMovie.moviePoster;
    self.audienceScoreLabel.text = [self.currMovie.audienceRating stringByAppendingString:@"%"];
    self.criticScoreLabel.text = [self.currMovie.criticRating stringByAppendingString:@"%"];
    if (self.currMovie.moviePosterURL == nil){
        self.moviePosterImage.image = [UIImage imageNamed:@"checkmarkicon@x2"];
    }
    else {
    SDWebImageManager *manager = [SDWebImageManager sharedManager];
    [manager downloadImageWithURL:[NSURL URLWithString: self.currMovie.moviePosterURL] options:0 progress:^(NSInteger receivedSize, NSInteger expectedSize) {
        NSLog(@"downloading image: %f %%", (float)receivedSize/(float)expectedSize);
    } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
        NSLog(@"%@", image);
       self.moviePosterImage.image = image;
        
    }
     
     ];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source



#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqual:@"showMovieReviews"]) {
        
        ReviewTableViewController *reviewTVC = segue.destinationViewController;
        reviewTVC.movieID = [[NSString alloc]init];
        reviewTVC.movieID = [NSString stringWithFormat:@"%@", self.currMovie.movieID];
        
    }
    
    else if ([segue.identifier isEqual:@"showMovieTheatres"]) {
        
        TheatreMapViewController *theatreMapVC = segue.destinationViewController;
        theatreMapVC.movieTitle = [[NSString alloc]init];
        theatreMapVC.movieTitle = [NSString stringWithFormat:@"%@", self.currMovie.movieTitle];
        theatreMapVC.currMovie = self.currMovie;
        
    }
    
}


@end
