//
//  WKWebViewController.m
//  Foodwise
//
//  Created by Brian Wong on 8/31/16.
//  Copyright © 2016 Brian Wong. All rights reserved.
//

#import "WKWebViewController.h"

@interface WKWebViewController()<WKNavigationDelegate>

@property (strong, nonatomic) UIActivityIndicatorView *activityIndicator;

@end

@implementation WKWebViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"Menu";
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[[UIImage imageNamed:@"back_arrow"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStylePlain target:self action:@selector(exitMenu)];
    
    self.activityIndicator = [[UIActivityIndicatorView alloc]initWithFrame:CGRectMake(self.view.frame.size.width/2 - 22.0, self.view.frame.size.height/2, 44.0, 44.0)];
    self.activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
    self.activityIndicator.color = [UIColor grayColor];
    
    self.webView = [[WKWebView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    self.webView.navigationDelegate = self;
    self.webView.allowsBackForwardNavigationGestures = YES;
    [self.webView loadRequest:[NSURLRequest requestWithURL:self.url]];
    [self.view addSubview:self.webView];

}

- (void)exitMenu
{
    [self.navigationController popViewControllerAnimated:YES];
}


//Activity indic
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation
{
    [self.view addSubview:self.activityIndicator];
    [self.activityIndicator startAnimating];
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation
{
    [self.activityIndicator stopAnimating];
    [self.activityIndicator removeFromSuperview];
}

@end
