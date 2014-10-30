//
//  ReviewTableViewController.m
//  Rotten Mangoes
//
//  Created by Taylor Ledingham on 2014-10-29.
//  Copyright (c) 2014 Taylor Ledingham. All rights reserved.
//

#import "ReviewTableViewController.h"
#import "ReviewLinkViewController.h"

@interface ReviewTableViewController ()

@property (strong, nonatomic) NSMutableArray *reviewArray;

@end

@implementation ReviewTableViewController {
    NSURL *reviewURL;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Reviews";
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    NSString *reviewURLString = [NSString stringWithFormat: @"http://api.rottentomatoes.com/api/public/v1.0/movies/%@/reviews.json?review_type=top_critic&page_limit=3&page=1&country=us&apikey=dk9s9j76292h6jk44dh5ru92", self.movieID ];
    
    reviewURL = [[NSURL alloc]initWithString:reviewURLString];
    
    [self loadReviews];
    
}

- (void) loadReviews {
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLRequest *request = [NSURLRequest requestWithURL:reviewURL];
    
    NSURLSessionDownloadTask *task = [session downloadTaskWithRequest:request completionHandler:^(NSURL *location, NSURLResponse *response, NSError *error) {
        
        if (error) {
            NSLog(@"Error is %@", [error localizedDescription]);
        }
        else {
        NSData *data = [[NSData alloc]initWithContentsOfURL:location];

        NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
            
            NSLog(@"%@", responseDictionary.description);
        
        self.reviewArray = [responseDictionary valueForKey:@"reviews"];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
        }
        
        
    }];
    
    [task resume];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return self.reviewArray.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ReviewTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    
    
    NSString *reviewerName = self.reviewArray[indexPath.row][@"critic"];
    NSString *reviewerQuote = self.reviewArray[indexPath.row][@"quote"];
    
    [cell.reviewerNameLabel setText: reviewerName];
    [cell.reviewQuoteTextView setText: reviewerQuote];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    return 200.0;
}


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
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqual:@"showReviewLink"]) {
        
        ReviewLinkViewController *linkVC = segue.destinationViewController;
         NSIndexPath *selectedPath = [self.tableView indexPathForSelectedRow];
        NSString *urlString = self.reviewArray[selectedPath.row][@"links"][@"review"];
        linkVC.reviewURL = [NSURL URLWithString:urlString];
        
        
    }
    
}


@end
