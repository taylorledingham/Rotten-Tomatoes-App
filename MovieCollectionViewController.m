//
//  MovieCollectionViewController.m
//  Rotten Mangoes
//
//  Created by Taylor Ledingham on 2014-10-29.
//  Copyright (c) 2014 Taylor Ledingham. All rights reserved.
//

#import "MovieCollectionViewController.h"

@interface MovieCollectionViewController ()

@end

@implementation MovieCollectionViewController {
    NSURL *movieURL;
    MovieCollectionViewFooterCollectionReusableView *footer;
    NSString *nextPageURLString;
    int currentPage;
}

static NSString * const reuseIdentifier = @"Cell";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations
    // self.clearsSelectionOnViewWillAppear = NO;
    [self setupCollectionView];
    self.movieArray = [[NSMutableArray alloc]init];
    currentPage = 1 ;
    // Register cell classes
    //[self.collectionView registerClass:[MovieCollectionViewCell class] forCellWithReuseIdentifier:reuseIdentifier];
    NSString *urlString = [[NSString alloc] initWithFormat:@"http://api.rottentomatoes.com/api/public/v1.0/lists/movies/in_theaters.json?page_limit=15&page=%d&country=ca&apikey=dk9s9j76292h6jk44dh5ru92", currentPage];
    //urlString = [[NSString alloc]initWithFormat:@"http://api.rottentomatoes.com/api/public/v1.0.json?apikey=dk9s9j76292h6jk44dh5ru92"];
    movieURL = [[NSURL alloc]initWithString:urlString];
    [self loadMovies];
    [self loadMovieArray];

    // Do any additional setup after loading the view.
}

-(void)loadMovies {
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLRequest *request = [[NSURLRequest alloc]initWithURL:movieURL];
    
    //wrap in non main default queue.
 dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
     [[session downloadTaskWithRequest:request completionHandler:^(NSURL *location, NSURLResponse *response, NSError *error) {
        
        if (error) {
            NSLog(@"Error is %@", [error localizedDescription]);
        }
        else {
            NSData *data = [[NSData alloc]initWithContentsOfURL:location];
            
            NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
            self.movieDictionary =  [responseDictionary valueForKey:@"movies"];
            //nextPageURLString = [responseDictionary valueForKey:@"movies"][@"next"];
            [self loadMovieArray];
            [footer stopSpinner];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.collectionView reloadData];
            });
        }
    }] resume];
 });

}

-(void)loadMovieArray {
    
    for (id currMovie in self.movieDictionary) {
        
        Movie *movie = [[Movie alloc]init];
        movie.movieTitle = currMovie[@"title"];
        movie.movieSynopsis = currMovie[@"synopsis"];
        movie.releaseDate = currMovie[@"release_dates"][@"theater"];
        movie.movieID = currMovie[@"id"];
        movie.criticRating = [NSString stringWithFormat: @"%@", currMovie[@"ratings"][@"critics_score"]];
        movie.audienceRating = [NSString stringWithFormat:@"%@", currMovie[@"ratings"][@"audience_score"]];
       
        NSString *imageString = currMovie[@"posters"][@"thumbnail"];
        NSURL *url = [NSURL URLWithString: imageString];
        NSData *data = [NSData dataWithContentsOfURL:url];
        UIImage *img = [[UIImage alloc] initWithData:data];
        movie.movieThumbnail = img;
        
        imageString = currMovie[@"posters"][@"original"];
        //imageString = [imageString stringByReplacingOccurrencesOfString:@"tmb" withString:@"org"];
        url = [NSURL URLWithString: imageString];
        data = [NSData dataWithContentsOfURL:url];
        img = [[UIImage alloc] initWithData:data];
        movie.moviePoster = img;
        
        
        [self.movieArray addObject:movie];
    }
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)setupCollectionView {
    
//    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
//    [flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
//    flowLayout.minimumInteritemSpacing = 1.0;
//    flowLayout.minimumLineSpacing = 1.0;
//    [flowLayout setItemSize:CGSizeMake(150, 150)];
//    [self.collectionView setCollectionViewLayout:flowLayout];

}



#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    DetailMovieTableViewController *detailTVC = segue.destinationViewController;
    NSArray *selectedPath = [self.collectionView indexPathsForSelectedItems];
    NSIndexPath *path = [selectedPath firstObject];
    detailTVC.currMovie =  self.movieArray[path.row];
    
}


#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.movieArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    MovieCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    Movie *movie = self.movieArray[indexPath.row] ;
    
    [cell setUpCell:movie];
    
   // cell.backgroundColor = [UIColor redColor];
    
    // Configure the cell
    
    
    return cell;
}

#pragma mark <UICollectionViewDelegate>

//-(void)scrollViewDidScroll:(UIScrollView *)scrollView
//{
////    CGFloat height = scrollView.frame.size.height;
////    
////    CGFloat contentYoffset = scrollView.contentOffset.y;
////    
////    CGFloat distanceFromBottom = scrollView.contentSize.height - contentYoffset;
////    
////    if(distanceFromBottom < height)
////    {
////        NSLog(@"end of the table");
////        [self loadAnotherPage];
////    }
//    
//    float bottomEdge = scrollView.contentOffset.y + scrollView.frame.size.height;
//    if (bottomEdge >= scrollView.contentSize.height) {
//        [self loadAnotherPage];
//        
//    }
//}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    
    float bottomEdge = scrollView.contentOffset.y + scrollView.frame.size.height;
    if (bottomEdge >= scrollView.contentSize.height) {
        [self loadAnotherPage];
        
    }}



-(void)loadAnotherPage {
    
    [footer startSpinner];
    if(currentPage < 11){
        
    currentPage +=1;
    NSLog(@"current page: %d", currentPage);
    NSString *urlString = [[NSString alloc] initWithFormat:@"http://api.rottentomatoes.com/api/public/v1.0/lists/movies/in_theaters.json?page_limit=15&page=%d&country=ca&apikey=dk9s9j76292h6jk44dh5ru92", currentPage];
    //urlString = [[NSString alloc]initWithFormat:@"http://api.rottentomatoes.com/api/public/v1.0.json?apikey=dk9s9j76292h6jk44dh5ru92"];
    movieURL = [[NSURL alloc]initWithString:urlString];
    [self loadMovies];
    }
    else {
        [footer stopSpinner];
    }

    
    
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)theCollectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)theIndexPath
{
    
    if(kind == UICollectionElementKindSectionFooter)
    {
        footer = [theCollectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"Footer" forIndexPath:theIndexPath];
    }
    
    return footer;
}

/*
// Uncomment this method to specify if the specified item should be highlighted during tracking
- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
	return YES;
}
*/

/*
// Uncomment this method to specify if the specified item should be selected
- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}
*/

/*
// Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
- (BOOL)collectionView:(UICollectionView *)collectionView shouldShowMenuForItemAtIndexPath:(NSIndexPath *)indexPath {
	return NO;
}

- (BOOL)collectionView:(UICollectionView *)collectionView canPerformAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	return NO;
}

- (void)collectionView:(UICollectionView *)collectionView performAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	
}
*/

@end
