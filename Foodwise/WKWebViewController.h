//
//  WKWebViewController.h
//  Foodwise
//
//  Created by Brian Wong on 8/31/16.
//  Copyright © 2016 Brian Wong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>

@interface WKWebViewController : UIViewController

@property (nonatomic, strong) WKWebView *webView;
@property (nonatomic, strong) NSURL *url;

- (void)loadURL:(NSURL*)url;

@end
