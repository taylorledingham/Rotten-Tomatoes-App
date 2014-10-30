//
//  MovieCollectionViewFooterCollectionReusableView.m
//  Rotten Mangoes
//
//  Created by Taylor Ledingham on 2014-10-29.
//  Copyright (c) 2014 Taylor Ledingham. All rights reserved.
//

#import "MovieCollectionViewFooterCollectionReusableView.h"

@implementation MovieCollectionViewFooterCollectionReusableView

-(void)startSpinner {
    
    [self.nextPageIndicator startAnimating];
    
}


-(void)stopSpinner {
    
    [self.nextPageIndicator stopAnimating];
    
}
@end
