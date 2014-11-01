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
    //[self loadTheatreArray];
    
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
    

    
}

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    if (foundUserLocation == NO) {
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(currentLocation.coordinate, 2500, 2500);
    NSLog(@"region: %f", region.center.latitude);
    [self.mapView setRegion:[self.mapView regionThatFits:region] animated:YES];
    }
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
    [self getTheatresFromPostalCode];
    
}

-(void) convertMovieTitleForArugments {
    

    self.movieTitleForURL = [self.movieTitle stringByReplacingOccurrencesOfString:@" " withString:@"+"];
    NSString *newPostalCode = [[NSString alloc]init];
    newPostalCode = [postalCode stringByReplacingOccurrencesOfString:@" " withString:@""];
    postalCode = newPostalCode;
    currLoc = currentLocation;
    
    
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


-(void) getTheatresFromPostalCode {
    
    [self convertMovieTitleForArugments];
    theatreURL = [NSURL URLWithString:[NSString stringWithFormat: @"http://lighthouse-movie-showtimes.herokuapp.com/theatres.json?address=%@&movie=%@", postalCode, self.movieTitleForURL ]];
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
           // NSLog(@"%@", self.theatreLocationArray.description);
            
            
            dispatch_async(dispatch_get_main_queue(), ^{
               // [self.mapView ];
                //add annoations
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
        }

        
        theatre.theatreID = object[@"id"];
        theatreID = theatre.theatreID;
        theatre.theatreName = object[@"name"];
        theatre.theatreAddress = object[@"address"];
        theatre.lat = [object[@"lat"] doubleValue];
        theatre.lng =  [object[@"lng"] doubleValue];
        //theatre.theatreLocation = [[CLLocation alloc]initWithLatitude:theatre.lat longitude:theatre.lng];
        
        showtime.theatre = theatre;
        showtime.movie = self.currMovie;
        
            
    }
    
    self.theatreLocationArray = theatreArray;
    [coreDataStack saveContext];
    
}

-(void)addTheatreAnnoations {
    
    NSFetchRequest *request = [self theatreListFetchRequest];
    TLCoreDataStack *coreDataStack = [TLCoreDataStack defaultStack];
    NSError *error;
    
    NSArray *results = [coreDataStack.managedObjectContext executeFetchRequest:request error:&error];
    int i=0;
    
    for (TheatreLocation * location in results) {
        //MKMapPointForCoordinate *coord = MKMapPointForCoordinate([location.theatreLocation coordinate]);
       // if ([self.mapView.ma ) check if in map view
        UIImage *pin = [pinImageArray objectAtIndex:i];
        MapPin *myAnnotation = [[MapPin alloc]initWithCoordinates:CLLocationCoordinate2DMake(location.lat, location.lng) placeName:location.theatreName subtitle:location.theatreAddress andPinImage:pin];
//        MKAnnotationView *myAnnotation = [[MKAnnotationView alloc]init];
//        myAnnotation.coordinate = CLLocationCoordinate2DMake(location.lat, location.lng);
//        myAnnotation.title = location.theatreName;
//        myAnnotation.subtitle = location.theatreAddress;
        
        [self.mapView addAnnotation:myAnnotation];
        i++;
        
        
        
    }
    
    
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control {
    //show direction
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



/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
