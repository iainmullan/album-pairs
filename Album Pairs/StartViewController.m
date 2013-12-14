//
//  StartViewController.m
//  Album Pairs
//
//  Created by Iain on 13/12/2013.
//  Copyright (c) 2013 Iain Mullan. All rights reserved.
//

#import "StartViewController.h"
#import "GameViewController.h"

@interface StartViewController ()

@end

@implementation StartViewController

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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:@"NewGameSegue"]) {

        GameViewController *gameViewController = segue.destinationViewController;

        UIButton *button = (UIButton *) sender;
        NSString *text = button.titleLabel.text;

        if ([text isEqualToString:@"My Music Library"]) {
            gameViewController.artworkSource = APArtworkSourceLibrary;
        } else if ([text isEqualToString:@"My Last FM Library"]) {
            gameViewController.artworkSource = APArtworkSourceLastFm;
        } else if ([text isEqualToString:@"Classic Albums"]) {
            gameViewController.artworkSource = APArtworkSourceDefault;
        }
        
    }

}

-(IBAction)gameWasSelected:(id)sender
{
    [self performSegueWithIdentifier:@"NewGameSegue" sender:sender];
}

@end
