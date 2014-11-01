//
//  Movie.h
//  Rotten Mangoes
//
//  Created by Taylor Ledingham on 2014-10-29.
//  Copyright (c) 2014 Taylor Ledingham. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "Showtime.h"

@interface Movie : NSManagedObject

@property (strong, nonatomic) NSString *movieTitle;
//@property (strong, nonatomic) NSString *yearMade;
@property (strong, nonatomic) NSString *releaseDate;
//@property (strong, nonatomic) NSString *rating;
@property (strong, nonatomic) NSString *movieSynopsis;
@property (strong, nonatomic) NSString *movieID;
@property (strong, nonatomic) NSString *criticRating;
@property (strong, nonatomic) NSString *audienceRating;
@property (strong, nonatomic) NSString *moviePosterURL;
@property (strong, nonatomic) NSString *movieThumbnailURL;
@property (strong, nonatomic) NSData *moviePoster;
@property (strong, nonatomic) NSData *movieThumbnail;
@property (retain, nonatomic) NSSet *movieShowtimes;
@property (retain, nonatomic) NSData *dateLastUpdated;



@end
