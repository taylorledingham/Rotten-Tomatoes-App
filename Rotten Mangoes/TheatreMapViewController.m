//
//  TheatreMapViewController.m
//  Rotten Mangoes
//
//  Created by Taylor Ledingham on 2014-10-30.
//  Copyright (c) 2014 Taylor Ledingham. All rights reserved.
//

#import "TheatreMapViewController.h"

@interface TheatreMapViewController ()

@property (strong, nonatomic) NSArray *theatreLocationArray;
@property (strong, nonatomic) NSString *movieTitleForURL;

@end

@implementation TheatreMapViewController {
    CLLocation *currentLocation;
    CLLocationManager *locationManager;
    CLPlacemark *userPlacemark;
    CLGeocoder *geoCoder;
    NSString *postalCode;
    BOOL foundUserLocation;
    NSURL *theatreURL;
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
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

//-(void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
//    
//    if(CLAuthorizationStatus == kCLAuthorizationStatusAuthorizedAlways) {
//        
//        [locationManager startUpdatingLocation];
//        
//    }
//    
//}

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    
    currentLocation = [locations firstObject];
    [locationManager stopUpdatingLocation];
     __weak typeof(self) weakSelf = self;
    
   // NSLog(@"%@ \n", currentLocation.description);

    
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
    
    
    //NSLog(@"%@", userPlacemark.description);
    
    
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
    
    
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.theatreLocationArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    TheatreLocation *loc = [self.theatreLocationArray objectAtIndex:indexPath.row];
    CLLocationDistance meters = [loc.theatreLocation distanceFromLocation:currentLocation ];
    cell.textLabel.text = loc.theatreName;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%.2f km away - %@", meters/1000, loc.theatreAddress];
    
    return cell;
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    TheatreLocation *loc = [self.theatreLocationArray objectAtIndex:indexPath.row];
    [self.mapView setRegion: MKCoordinateRegionMakeWithDistance(loc.theatreLocation.coordinate, 2000, 2000)];
    
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{

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
    
    for (id object in self.theatreLocationArray) {
        
        TheatreLocation *location = [[TheatreLocation alloc]init];
        location.theatreID = object[@"id"];
        location.theatreName = object[@"name"];
        location.theatreAddress = object[@"address"];
        location.lat = [object[@"lat"] doubleValue];
        location.lng =  [object[@"lng"] doubleValue];
        location.theatreLocation = [[CLLocation alloc]initWithLatitude:location.lat longitude:location.lng];
        
        [theatreArray addObject:location];
        
    }
    
    self.theatreLocationArray = theatreArray;
    
}

-(void)addTheatreAnnoations {
    
    for (TheatreLocation * location in self.theatreLocationArray) {
        //MKMapPointForCoordinate *coord = MKMapPointForCoordinate([location.theatreLocation coordinate]);
       // if ([self.mapView.ma ) check if in map view
        
        MKPointAnnotation *myAnnotation = [[MKPointAnnotation alloc]init];
        myAnnotation.coordinate = CLLocationCoordinate2DMake(location.lat, location.lng);
        myAnnotation.title = location.theatreName;
        myAnnotation.subtitle = location.theatreAddress;
        
        [self.mapView addAnnotation:myAnnotation];
        
        
        
    }
    
    
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view{
   
    NSLog(@"selected: %@", view.description);
    
    
}

-(void)getShowTimes {
    
    
    
    
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
