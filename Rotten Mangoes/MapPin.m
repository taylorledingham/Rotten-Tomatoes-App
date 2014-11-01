//
//  MapPin.m
//  Rotten Mangoes
//
//  Created by Taylor Ledingham on 2014-10-30.
//  Copyright (c) 2014 Taylor Ledingham. All rights reserved.
//

#import "MapPin.h"

@implementation MapPin
@synthesize coordinate;

- (id)initWithCoordinates:(CLLocationCoordinate2D)location placeName:(NSString *)placeName subtitle:(NSString *)subtitle andPinImage:(UIImage *)pinImage;
{
    self = [super init];
    if (self) {
        
        _title = placeName;
        coordinate = location;
        _subtitle = subtitle;
        _pinImage = pinImage;
        
    }
    return self;
}

-(MKAnnotationView *)annotationView {
   
    MKAnnotationView *annotationView = [[MKAnnotationView alloc]initWithAnnotation:self reuseIdentifier:@"TheatreAnnotation"];
    annotationView.enabled = YES;
    annotationView.backgroundColor = [UIColor magentaColor];
    annotationView.canShowCallout = YES;
    //annotaionView.image = //some image
    annotationView.rightCalloutAccessoryView = [UIButton buttonWithType: UIButtonTypeDetailDisclosure];
    annotationView.calloutOffset = CGPointMake(-5, 5);
//    UIImage *pinImage = [UIImage imageNamed:@"checkmarkicon@x2"];
    [annotationView setImage:self.pinImage];
    
    return annotationView;
    
}

@end
