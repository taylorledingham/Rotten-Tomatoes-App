//
//  ReviewLinkViewController.h
//  Rotten Mangoes
//
//  Created by Taylor Ledingham on 2014-10-29.
//  Copyright (c) 2014 Taylor Ledingham. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ReviewLinkViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIWebView *reviewWebView;
@property (strong, nonatomic) NSURL *reviewURL;

@end
