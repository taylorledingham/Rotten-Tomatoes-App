//
//  Showtime.h
//  Rotten Mangoes
//
//  Created by Taylor Ledingham on 2014-10-31.
//  Copyright (c) 2014 Taylor Ledingham. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Movie;
@class TheatreLocation;

@interface Showtime : NSManagedObject

@property (nonatomic, retain) NSDate * lastUpdated;
@property (nonatomic, retain) NSString * movieTime;
@property (nonatomic, retain) Movie *movie;
@property (nonatomic, retain) NSManagedObject *theatre;

@end
