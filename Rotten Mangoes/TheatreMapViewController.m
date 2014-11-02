//
//  TheatreMapViewController.m
//  Rotten Mangoes
//
//  Created by Taylor Ledingham on 2014-10-30.
//  Copyright (c) 2014 Taylor Ledingham. All rights reserved.
//

#import "TheatreMapViewController.h"

@interface TheatreMapViewController () <NSFetchedResultsControllerDelegate>

@property (strong, nonatomic) NSArray *theatreLocationArray;
@property (strong, nonatomic) NSString *movieTitleForURL;
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;

@end

@implementation TheatreMapViewController {
    CLLocation *currentLocation;
    CLLocation *currLoc;
    CLLocationManager *locationManager;
    CLPlacemark *userPlacemark;
    CLGeocoder *geoCoder;
    NSString *postalCode;
    BOOL foundUserLocation;
    NSURL *theatreURL;
    NSString *theatreID;
    NSMutableArray *pinImageArray;
    MKRoute *route;
    BOOL newUpdates;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    
    foundUserLocation = NO;
    locationManager = [[CLLocationManager alloc]init];
    geoCoder = [[CLGeocoder alloc]init];
    postalCode = [[NSString alloc]init];
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [locationManager requestWhenInUseAuthorization];
    [locationManager startUpdatingLocation];
    
    
    self.mapView.delegate = self;
    self.mapView.showsUserLocation = YES;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self setUpPinImageArray];
    [self.fetchedResultsController performFetch:nil];
    newUpdates = NO;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)setUpPinImageArray {
    
    pinImageArray = [[NSMutableArray alloc]init];
    
    [pinImageArray addObject:[UIImage imageNamed:@"pin0"]];
    [pinImageArray addObject:[UIImage imageNamed:@"pin1"]];
    [pinImageArray addObject:[UIImage imageNamed:@"pin2"]];
    [pinImageArray addObject:[UIImage imageNamed:@"pin3"]];
    [pinImageArray addObject:[UIImage imageNamed:@"pin4"]];
    [pinImageArray addObject:[UIImage imageNamed:@"pin5"]];
    [pinImageArray addObject:[UIImage imageNamed:@"pin6"]];
    [pinImageArray addObject:[UIImage imageNamed:@"pin7"]];
    [pinImageArray addObject:[UIImage imageNamed:@"pin8"]];
    [pinImageArray addObject:[UIImage imageNamed:@"pin9"]];
    [pinImageArray addObject:[UIImage imageNamed:@"pin10"]];
    [pinImageArray addObject:[UIImage imageNamed:@"pin11"]];

}



#pragma mark - location manager delegate


-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    
    currentLocation = [locations firstObject];
    [self.tableView reloadData];
    [locationManager stopUpdatingLocation];
    [locationManager stopUpdatingHeading];
     __weak typeof(self) weakSelf = self;
    
    [geoCoder reverseGeocodeLocation:currentLocation completionHandler:^(NSArray *placemarks, NSError *error) {
        
        if(error){
            NSLog(@"sorry couldn't reverse geo code the location");
        }
        
        else {
        
        userPlacemark = [placemarks firstObject];
        [weakSelf getPostalCodeFromPlacemark];
            foundUserLocation = YES;


        }
    }];
    
    
}

-(void) getPostalCodeFromPlacemark {
    
    postalCode = userPlacemark.postalCode;
    NSLog(@"%@", postalCode);
    [self deleteAndUpdateOldShowtimes];
    
}



#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
     return [[self.fetchedResultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][section];
    return [sectionInfo numberOfObjects];

}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    NSArray *objects = self.fetchedResultsController.fetchedObjects;
    if (objects.count == 0){
        
        cell.textLabel.text = @"this movie is not being played in any theatres";
        return cell;
    }
    TheatreLocation *loc= [self.fetchedResultsController objectAtIndexPath:indexPath];
    CLLocationDistance meters = [[[CLLocation alloc]initWithLatitude:loc.lat longitude:loc.lng] distanceFromLocation: currentLocation ];
    cell.textLabel.text = loc.theatreName;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%.2f km away - %@", meters/1000, loc.theatreAddress];
    
    return cell;
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    TheatreLocation *loc = [self.fetchedResultsController objectAtIndexPath:indexPath];
    CLLocation *myLocation = [[CLLocation alloc]initWithLatitude:loc.lat longitude:loc.lng];
    [self.mapView setRegion: MKCoordinateRegionMakeWithDistance(myLocation.coordinate, 2000, 2000)];
    
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return  60.0;
}

#pragma mark - data methods

-(void)deleteAndUpdateOldShowtimes {
    
    TLCoreDataStack *coreDataStack = [TLCoreDataStack defaultStack];
    NSFetchRequest *showTimeRequest =[NSFetchRequest fetchRequestWithEntityName:@"Showtime"];
    NSFetchRequest *theatreRequest =[self theatreListFetchRequest];
    NSError *error;
    NSArray *theatreResult =[coreDataStack.managedObjectContext executeFetchRequest:theatreRequest error:&error];
    if(theatreResult.count == 0){
        [self getTheatresFromPostalCode];
    }
    else {
        
        NSPredicate *showtimePredicate = [NSPredicate predicateWithFormat:@"movie == %@",self.currMovie];
        showTimeRequest.predicate = showtimePredicate;
        NSArray *result =[coreDataStack.managedObjectContext executeFetchRequest:showTimeRequest error:&error];
        
        for (Showtime *showtime in result) {
            
            NSDate *lastDay = showtime.lastUpdated;
            NSDate *nextDay = [NSDate date];
            
            NSTimeInterval secondsBetween = [lastDay timeIntervalSinceDate:nextDay];
            
            int numberOfDays = secondsBetween / 86400;
            
            if(numberOfDays >= 1 ){
                //delete showtime get new one
                [coreDataStack.managedObjectContext deleteObject:showtime];
                newUpdates = YES;
            }
            
        }
        if(newUpdates == YES){
            [coreDataStack saveContext];
            [self getTheatresFromPostalCode];
        }
        else {
            [self addTheatreAnnoations];

        }
        
    }
    
}

-(void) convertMovieTitleForArugments {
    
    
    self.movieTitleForURL = [self.movieTitle stringByReplacingOccurrencesOfString:@" " withString:@"+"];
    NSString *newPostalCode = [[NSString alloc]init];
    newPostalCode = [postalCode stringByReplacingOccurrencesOfString:@" " withString:@""];
    postalCode = newPostalCode;
    currLoc = currentLocation;
    
    
}

-(void) getTheatresFromPostalCode {
    
    [self convertMovieTitleForArugments];
    theatreURL = [NSURL URLWithString:[NSString stringWithFormat: @"http://lighthouse-movie-showtimes.herokuapp.com/theatres.json?address=%@&movie=%@", postalCode, self.movieTitleForURL ]];
    NSLog(@"%@", theatreURL);
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLRequest *request = [[NSURLRequest alloc]initWithURL:theatreURL];
    
    NSURLSessionDownloadTask *task = [session downloadTaskWithRequest:request completionHandler:^(NSURL *location, NSURLResponse *response, NSError *error) {
        
        if (error) {
            NSLog(@"Error is %@", [error localizedDescription]);
        }
        else {
            NSData *data = [[NSData alloc]initWithContentsOfURL:location];
            
            NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
            self.theatreLocationArray =  [responseDictionary valueForKey:@"theatres"];
            [self loadTheatreArray];
            
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
                [self addTheatreAnnoations];
                //update the map view
            });
        }
    }];
    
    [task resume];
    
}



-(void)loadTheatreArray {
    NSMutableArray *theatreArray = [[NSMutableArray alloc]init];
    TLCoreDataStack *coreDataStack = [TLCoreDataStack defaultStack];
    
    for (id object in self.theatreLocationArray) {
        
        //check if
        NSFetchRequest *theatreRequest =[[NSFetchRequest alloc]initWithEntityName:@"TheatreLocation"];
        NSPredicate *theatreIDPredicate = [NSPredicate predicateWithFormat:@"theatreID == %@",object[@"id"]];
        NSError *error;
        theatreRequest.predicate = theatreIDPredicate;
        NSArray *result =[coreDataStack.managedObjectContext executeFetchRequest:theatreRequest error:&error];
        TheatreLocation *theatre;
        Showtime *showtime;
        if (result.count == 0){
            
            theatre = [NSEntityDescription insertNewObjectForEntityForName:@"TheatreLocation" inManagedObjectContext:coreDataStack.managedObjectContext];
             showtime = [NSEntityDescription insertNewObjectForEntityForName:@"Showtime" inManagedObjectContext:coreDataStack.managedObjectContext];
        }
        else {
            //update
            theatre = [result firstObject];
            NSError *error;
            NSFetchRequest *showTimeRequest =[NSFetchRequest fetchRequestWithEntityName:@"Showtime"];
            NSPredicate *showtimeTheatrePredicate = [NSPredicate predicateWithFormat:@"theatre == %@",theatre];
            //see if the current theatre is in the showtime table
            showTimeRequest.predicate = showtimeTheatrePredicate;
            NSArray *result =[coreDataStack.managedObjectContext executeFetchRequest:showTimeRequest error:&error];
            if (result.count == 0){
                //re-add showtime entity
                showtime = [NSEntityDescription insertNewObjectForEntityForName:@"Showtime" inManagedObjectContext:coreDataStack.managedObjectContext];
            }
        }

        
        theatre.theatreID = object[@"id"];
        theatreID = theatre.theatreID;
        theatre.theatreName = object[@"name"];
        theatre.theatreAddress = object[@"address"];
        theatre.lat = [object[@"lat"] doubleValue];
        theatre.lng =  [object[@"lng"] doubleValue];
        NSDate *today = [NSDate date];
        showtime.lastUpdated = today;
        //theatre.theatreLocation = [[CLLocation alloc]initWithLatitude:theatre.lat longitude:theatre.lng];
        
        showtime.theatre = theatre;
        showtime.movie = self.currMovie;
        
            
    }
    
    self.theatreLocationArray = theatreArray;
    [coreDataStack saveContext];
    newUpdates = NO;
    
}

#pragma mark - map view methods

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    if (foundUserLocation == NO) {
        MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(currentLocation.coordinate, 2500, 2500);
        NSLog(@"region: %f", region.center.latitude);
        [self.mapView setRegion:[self.mapView regionThatFits:region] animated:YES];
    }
}

-(void)addTheatreAnnoations {
    
    NSFetchRequest *request = [self theatreListFetchRequest];
    TLCoreDataStack *coreDataStack = [TLCoreDataStack defaultStack];
    NSError *error;
    
    NSArray *results = [coreDataStack.managedObjectContext executeFetchRequest:request error:&error];
    int i=0;
    
    for (TheatreLocation * location in results) {
        UIImage *pin = [pinImageArray objectAtIndex:i];
        MapPin *myAnnotation = [[MapPin alloc]initWithCoordinates:CLLocationCoordinate2DMake(location.lat, location.lng) placeName:location.theatreName subtitle:location.theatreAddress andPinImage:pin];
        
        [self.mapView addAnnotation:myAnnotation];
        i++;
        
    }
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control {
    //show direction
    
    MapPin *myAnnotation = (MapPin *)view;
    MKDirectionsRequest *request = [[MKDirectionsRequest alloc] init];
    request.source = [MKMapItem mapItemForCurrentLocation];
    MKPlacemark *plmark = [[MKPlacemark alloc] initWithCoordinate: myAnnotation.coordinate addressDictionary:nil];
    MKMapItem *desItem = [[MKMapItem alloc] initWithPlacemark:plmark];
    request.destination = desItem;
    request.requestsAlternateRoutes = YES;
    request.transportType = MKDirectionsTransportTypeAutomobile;
    MKDirections *directions =
    [[MKDirections alloc] initWithRequest:request];
    __block typeof(self) weakSelf = self;
    [directions calculateDirectionsWithCompletionHandler:
     ^(MKDirectionsResponse *response, NSError *error) {
         if (error) {
             // Handle Error
         } else {
             route = [response.routes firstObject];
             [weakSelf.mapView addOverlay:route.polyline level:MKOverlayLevelAboveRoads];
         }
     }];
    
    
}

-(MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay{
    MKPolylineRenderer *polylineRender = [[MKPolylineRenderer alloc] initWithOverlay:overlay];
    polylineRender.lineWidth = 3.0f;
    polylineRender.strokeColor = [UIColor magentaColor];
    return polylineRender;
}



-(MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    
    if([annotation isKindOfClass:[MapPin class]]){
        
        MapPin *myLocation = (MapPin *)annotation;
        
        MKAnnotationView *annotationView = [mapView dequeueReusableAnnotationViewWithIdentifier:@"TheatreAnnotation"];
        
        if(annotationView == nil){
            annotationView = myLocation.annotationView;
        }
        else
            annotationView.annotation = annotation;
        
        return annotationView;
    }
    
    else {
        return nil;
    }
    
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view{
   
    NSLog(@"selected: %@", view.description);
    
    
}



#pragma mark - fetch request methods

- (NSFetchedResultsController *)fetchedResultsController {
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    TLCoreDataStack *coreDataStack = [TLCoreDataStack defaultStack];
    NSFetchRequest *fetchRequest = [self theatreListFetchRequest];
    
    _fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:coreDataStack.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    _fetchedResultsController.delegate = self;
    
    return _fetchedResultsController;
}


-(NSFetchRequest *)theatreListFetchRequest {
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"TheatreLocation"];
    
    fetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"theatreAddress" ascending:NO]];
    NSPredicate *theatrePredicate = [NSPredicate predicateWithFormat:@"ANY theatreShowtimes.movie.movieID == %@",self.currMovie.movieID];
    fetchRequest.predicate = theatrePredicate;
    
    return fetchRequest;
}


- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    switch (type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
        case NSFetchedResultsChangeUpdate:
            //[self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id<NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
    switch (type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView endUpdates];
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
