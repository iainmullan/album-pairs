//
//  StartViewController.m
//  Album Pairs
//
//  Created by Iain on 13/12/2013.
//  Copyright (c) 2013 Iain Mullan. All rights reserved.
//

#import "StartViewController.h"
#import "GameViewController.h"
#import "APGame.h"

@interface StartViewController ()

@property APArtworkSource gameType;

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
    self.screenName = @"Start Screen";

    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background.png"]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:@"NewGameSegue"]) {
        GameViewController *gameViewController = segue.destinationViewController;
        gameViewController.artworkSource = self.gameType;
    }

}

-(void)prepareGameWithSource:(APArtworkSource)source
{
    
    // if last fm - check username exists
    
    
    // if library - check enough artwork in library
    
    
    [self launchGame:source];
}

-(void)launchGame:(APArtworkSource)source
{
    self.gameType = source;
    [self performSegueWithIdentifier:@"NewGameSegue" sender:nil];
}

-(IBAction)gameWasSelected:(id)sender
{
    
    UIButton *button = (UIButton *) sender;
    NSString *text = button.titleLabel.text;
    
    if ([text isEqualToString:@"My Last FM Library"]) {
        
        self.gameType = APArtworkSourceLastFm;

        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Last FM" message:@"Please enter your username:" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:nil];
        
        alert.alertViewStyle = UIAlertViewStylePlainTextInput;
        alert.tag = 1;
        

        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSString *username = [defaults objectForKey:@"LastFmUsername"];

        if (username) {
            UITextField *textField = [alert textFieldAtIndex:0];
            textField.text = username;
        }

        [alert addButtonWithTitle:@"Go"];
        [alert show];
        
    } else if ([text isEqualToString:@"My Music Library"]) {
        [self launchGame:APArtworkSourceLibrary];
    } else if ([text isEqualToString:@"Classic Albums"]) {
        [self launchGame:APArtworkSourceDefault];
    }

}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{

    if (alertView.tag == 1) {
        if (buttonIndex == 1) {
            UITextField *textfield = [alertView textFieldAtIndex:0];
            NSString *username = textfield.text;
            
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            [defaults setObject:username forKey:@"LastFmUsername"];
            
            [self prepareGameWithSource:APArtworkSourceLastFm];
        }
    }
}


@end
