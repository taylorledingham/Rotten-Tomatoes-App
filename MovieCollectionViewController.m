//
//  MovieCollectionViewController.m
//  Rotten Mangoes
//
//  Created by Taylor Ledingham on 2014-10-29.
//  Copyright (c) 2014 Taylor Ledingham. All rights reserved.
//

#import "MovieCollectionViewController.h"

@interface MovieCollectionViewController () <NSFetchedResultsControllerDelegate>

@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;

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
    

    self.movieArray = [[NSMutableArray alloc]init];
   // currentPage = 1 ;
    NSString *urlString = [[NSString alloc] initWithFormat:@"http://api.rottentomatoes.com/api/public/v1.0/lists/movies/in_theaters.json?page_limit=50&page=1&country=ca&apikey=dk9s9j76292h6jk44dh5ru92"];
    movieURL = [[NSURL alloc]initWithString:urlString];
    
    [self.fetchedResultsController performFetch:nil];

    [self loadMovies];
    [self loadMovieArray];

    // Do any additional setup after loading the view.
}

-(void)loadMovies {
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLRequest *request = [[NSURLRequest alloc]initWithURL:movieURL];
    
    //wrap in non main default queue.
 dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
     [[session downloadTaskWithRequest:request completionHandler:^(NSURL *location, NSURLResponse *response, NSError *error) {
        
        if (error) {
            NSLog(@"Error is %@", [error localizedDescription]);
        }
        else {
            NSData *data = [[NSData alloc]initWithContentsOfURL:location];
            
            NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
            self.movieArrayFromAPI =  [responseDictionary valueForKey:@"movies"];
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
    
    TLCoreDataStack *coreDataStack = [TLCoreDataStack defaultStack];
    
    

        for (id currMovie in self.movieArrayFromAPI) {
            
            //check if
            NSFetchRequest *movieRequest =[[NSFetchRequest alloc]initWithEntityName:@"Movie"];
             NSPredicate *movieIDPredicate = [NSPredicate predicateWithFormat:@"movieID == %@",currMovie[@"id"]];
            NSError *error;
            movieRequest.predicate = movieIDPredicate;
            NSArray *result =[coreDataStack.managedObjectContext executeFetchRequest:movieRequest error:&error];
            Movie *movie;
            if (result.count == 0){
            
            movie = [NSEntityDescription insertNewObjectForEntityForName:@"Movie" inManagedObjectContext:coreDataStack.managedObjectContext];
            }
            else {
                //update
                movie = [result firstObject];
            }
            
            //Movie *movie = [[Movie alloc]init];
            //NSNumber *moveid = currMovie[@"id"];
            movie.movieID = currMovie[@"id"];
            movie.movieTitle = currMovie[@"title"];
            movie.movieSynopsis = currMovie[@"synopsis"];
            movie.releaseDate = currMovie[@"release_dates"][@"theater"];
            movie.movieID = currMovie[@"id"];
            movie.criticRating = [NSString stringWithFormat: @"%@", currMovie[@"ratings"][@"critics_score"]];
            movie.audienceRating = [NSString stringWithFormat:@"%@", currMovie[@"ratings"][@"audience_score"]];
            
            
            NSString *imageString = currMovie[@"posters"][@"thumbnail"];
            movie.movieThumbnailURL = imageString;
            
            
            imageString = currMovie[@"posters"][@"original"];
            imageString = [imageString stringByReplacingOccurrencesOfString:@"tmb" withString:@"org"];
           // NSURL *url = [NSURL URLWithString: imageString];
            movie.moviePosterURL = imageString;
            
            //[self.movieArray addObject:movie];

    }
    
    if (self.movieArrayFromAPI == nil){
        NSLog(@"skipping deletes");
        return;
        
    }
    
    NSFetchRequest *fetchedObjects = [self movieListFetchRequest];
    NSError *error;
    NSArray *objects = [coreDataStack.managedObjectContext executeFetchRequest:fetchedObjects error:&error];
            //loop through current movies and if there not in the movies array delete them
        for(Movie * currentMovie in objects) {
            NSPredicate *movieIDPredicate = [NSPredicate predicateWithFormat:@"id == %@", currentMovie.movieID];
            
            NSArray *results = [self.movieArrayFromAPI filteredArrayUsingPredicate:movieIDPredicate];
            if(results.count==0){
            [[coreDataStack managedObjectContext] deleteObject:currentMovie];
                NSLog(@"deleted object: %@", currentMovie.movieID);
            }
        }
    
    [coreDataStack saveContext];
    [self.collectionView reloadData];

    
    
}




- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}





#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    DetailMovieTableViewController *detailTVC = segue.destinationViewController;
    NSArray *selectedPath = [self.collectionView indexPathsForSelectedItems];
    NSIndexPath *path = [selectedPath firstObject];
     Movie *movie= [self.fetchedResultsController objectAtIndexPath:path];
    detailTVC.currMovie =  movie;
    
}


#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return [[self.fetchedResultsController sections] count];
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][section];
    return [sectionInfo numberOfObjects];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    MovieCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    Movie *movie= [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    //Movie *movie = self.movieArray[indexPath.row] ;
    cell.movieImageURL = [NSURL URLWithString: movie.movieThumbnailURL];
    [cell setUpCell:movie];
    
    
    return cell;
}



//- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
//{
//    
//    float bottomEdge = scrollView.contentOffset.y + scrollView.frame.size.height;
//    if (bottomEdge >= scrollView.contentSize.height) {
//        [self loadAnotherPage];
//        
//    }}



//-(void)loadAnotherPage {
//    
//    [footer startSpinner];
//    if(currentPage < 11){
//        
//    currentPage +=1;
//    NSLog(@"current page: %d", currentPage);
//    NSString *urlString = [[NSString alloc] initWithFormat:@"http://api.rottentomatoes.com/api/public/v1.0/lists/movies/in_theaters.json?page_limit=15&page=%d&country=ca&apikey=dk9s9j76292h6jk44dh5ru92", currentPage];
//    //urlString = [[NSString alloc]initWithFormat:@"http://api.rottentomatoes.com/api/public/v1.0.json?apikey=dk9s9j76292h6jk44dh5ru92"];
//    movieURL = [[NSURL alloc]initWithString:urlString];
//    [self loadMovies];
//    }
//    else {
//        [footer stopSpinner];
//    }
//
//    
//    
//}

#pragma mark <UICollectionViewDelegate>


- (UICollectionReusableView *)collectionView:(UICollectionView *)theCollectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)theIndexPath
{
    
    if(kind == UICollectionElementKindSectionFooter)
    {
        footer = [theCollectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"Footer" forIndexPath:theIndexPath];
    }
    
    return footer;
}

#pragma mark - NSFetchedResultController Delegate methods

- (NSFetchedResultsController *)fetchedResultsController {
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    TLCoreDataStack *coreDataStack = [TLCoreDataStack defaultStack];
    NSFetchRequest *fetchRequest = [self movieListFetchRequest];
    
    _fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:coreDataStack.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    _fetchedResultsController.delegate = self;
    
    return _fetchedResultsController;
}


-(NSFetchRequest *)movieListFetchRequest {
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Movie"];
    
    fetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"releaseDate" ascending:YES]];
    
    return fetchRequest;
}



//-(void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath
//{
//    __weak UICollectionView *collectionView = self.collectionView;
//    switch (type) {
//        case NSFetchedResultsChangeInsert: {
//            if ([self.collectionView numberOfSections] > 0) {
//                if ([self.collectionView numberOfItemsInSection:indexPath.section] == 0) {
//                    self.shouldReloadCollectionView = YES;
//                } else {
//                    [self.blockOperation addExecutionBlock:^{
//                        [collectionView insertItemsAtIndexPaths:@[newIndexPath]];
//                    }];
//                }
//            } else {
//                self.shouldReloadCollectionView = YES;
//            }
//            break;
//        }
//        case NSFetchedResultsChangeDelete: {
//            if ([self.collectionView numberOfItemsInSection:indexPath.section] == 1) {
//                self.shouldReloadCollectionView = YES;
//            } else {
//                [self.blockOperation addExecutionBlock:^{
//                    [collectionView deleteItemsAtIndexPaths:@[indexPath]];
//                }];
//            }
//            break;
//        }
//        case NSFetchedResultsChangeUpdate: {
//            [self.blockOperation addExecutionBlock:^{
//                [collectionView reloadItemsAtIndexPaths:@[indexPath]];
//            }];
//            break;
//        }
//        case NSFetchedResultsChangeMove: {
//            [self.blockOperation addExecutionBlock:^{
//                [collectionView moveItemAtIndexPath:indexPath toIndexPath:newIndexPath];
//            }];
//            break;
//        }
//        default:
//            break;
//    }
//    }
//
//- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
//    {
//
//    if (self.shouldReloadCollectionView) {
//        [self.collectionView reloadData];
//    } else {
//        [self.collectionView performBatchUpdates:^{
//            [self.blockOperation start];
//        } completion:nil];
//    }
//    
//    }



@end
