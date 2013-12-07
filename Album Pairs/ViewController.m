//
//  ViewController.m
//  Album Pairs
//
//  Created by Iain on 07/12/2013.
//  Copyright (c) 2013 Iain Mullan. All rights reserved.
//

#import "ViewController.h"
#import "LastFm.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.

    [LastFm sharedInstance].apiKey = @"79de4922efbb54e68613e47d36de1b9f";
    [LastFm sharedInstance].apiSecret = @"ddf36276bf879232f93165598ce43c4c";
    [LastFm sharedInstance].username = @"ebotunes";

    // Get images for an artist
    [[LastFm sharedInstance] getTopAlbumsForUserOrNil:@"ebotunes" period:kLastFmPeriodOverall limit:8 successHandler:^(NSArray *result) {
        NSLog(@"result: %@", result);

        for (NSDictionary *album in result) {
            
            NSLog(@"Title: %@", [album valueForKey:@"image"]);
            
            NSURL *url =[album valueForKey:@"image"];
            
            NSData *imageData = [NSData dataWithContentsOfURL:url];
            UIImage *image = [UIImage imageWithData:imageData];
            
        }

    } failureHandler:^(NSError *error) {
        NSLog(@"error: %@", error);
    }];

    

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
