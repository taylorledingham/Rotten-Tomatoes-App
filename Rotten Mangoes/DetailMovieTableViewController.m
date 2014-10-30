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
    self.movieDescLabel.text = self.currMovie.movieSynopsis;
    self.releaseDateLabel.text = [NSString stringWithFormat:@"Release Date: %@" ,[dateFormat stringFromDate:movieDate]];
    self.moviePosterImage.image = self.currMovie.moviePoster;
    self.audienceScoreLabel.text = [self.currMovie.audienceRating stringByAppendingString:@"%"];
    self.criticScoreLabel.text = [self.currMovie.criticRating stringByAppendingString:@"%"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}
*/

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


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
        
    }
    
}


- (IBAction)getMovieListings:(id)sender {
}
@end
