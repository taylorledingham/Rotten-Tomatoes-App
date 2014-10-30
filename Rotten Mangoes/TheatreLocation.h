//
//  TheatreLocation.h
//  Rotten Mangoes
//
//  Created by Taylor Ledingham on 2014-10-30.
//  Copyright (c) 2014 Taylor Ledingham. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface TheatreLocation : NSObject

@property (strong, nonatomic) NSString *theatreID;
@property (strong, nonatomic) NSString *theatreName;
@property (strong, nonatomic) NSString *theatreAddress;
@property (strong, nonatomic) CLLocation *theatreLocation;
@property (nonatomic) double lat;
@property (nonatomic) double lng;

@end
