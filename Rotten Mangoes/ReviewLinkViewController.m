//
//  ReviewLinkViewController.m
//  Rotten Mangoes
//
//  Created by Taylor Ledingham on 2014-10-29.
//  Copyright (c) 2014 Taylor Ledingham. All rights reserved.
//

#import "ReviewLinkViewController.h"

@interface ReviewLinkViewController ()

@end

@implementation ReviewLinkViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:self.reviewURL];
    [self.reviewWebView loadRequest:urlRequest];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
