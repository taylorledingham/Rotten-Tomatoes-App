//
//  MovieCollectionViewFooterCollectionReusableView.h
//  Rotten Mangoes
//
//  Created by Taylor Ledingham on 2014-10-29.
//  Copyright (c) 2014 Taylor Ledingham. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MovieCollectionViewFooterCollectionReusableView : UICollectionReusableView

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *nextPageIndicator;

-(void)startSpinner;
-(void)stopSpinner;

@end
