//
//  MapPin.h
//  Rotten Mangoes
//
//  Created by Taylor Ledingham on 2014-10-30.
//  Copyright (c) 2014 Taylor Ledingham. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>

@interface MapPin : NSObject <MKAnnotation>

@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;
@property (copy, nonatomic) NSString *title;
@property (copy, nonatomic) NSString *subtitle;
@property (copy, nonatomic) UIImage *pinImage;

- (id)initWithCoordinates:(CLLocationCoordinate2D)location placeName:(NSString *)placeName subtitle:(NSString *)subtitle andPinImage:(UIImage *)pinImage;

-(MKAnnotationView *)annotationView;

@end
