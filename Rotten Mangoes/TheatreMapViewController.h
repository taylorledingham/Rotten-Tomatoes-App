//
//  TheatreMapViewController.h
//  Rotten Mangoes
//
//  Created by Taylor Ledingham on 2014-10-30.
//  Copyright (c) 2014 Taylor Ledingham. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import "TheatreLocation.h"
#import "MapPin.h"
#import "TLCoreDataStack.h"
#import "Movie.h"

@interface TheatreMapViewController : UIViewController <CLLocationManagerDelegate, MKMapViewDelegate, UITableViewDelegate, UITableViewDataSource>


@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (strong, nonatomic) NSString *movieTitle;
@property (strong, nonatomic) Movie *currMovie;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end
