//
//  AboutViewController.m
//  Album Pairs
//
//  Created by Iain Mullan on 17/12/2013.
//  Copyright (c) 2013 Iain Mullan. All rights reserved.
//

#import "AboutViewController.h"

@interface AboutViewController ()
@property (weak, nonatomic) IBOutlet UIWebView *contentView;
@end

@implementation AboutViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.contentView.delegate = self;

    NSString *path = [[NSBundle mainBundle] pathForResource:@"about" ofType:@"html"];
    NSString *htmlText = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];

    [self.contentView loadHTMLString:htmlText baseURL:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    
    if (navigationType == UIWebViewNavigationTypeLinkClicked) {
        [[UIApplication sharedApplication] openURL:[request URL]];
        return NO;
    }
    return YES;

}

@end
