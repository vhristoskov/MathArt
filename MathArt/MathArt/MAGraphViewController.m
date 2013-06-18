//
//  MAGraphViewController.m
//  MathArt
//
//  Created by Victor Hristoskov on 6/18/13.
//  Copyright (c) 2013 MentorMate. All rights reserved.
//

#import "MAGraphViewController.h"

@interface MAGraphViewController ()


@end

@implementation MAGraphViewController

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
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Action methods
- (IBAction)backBarButtonTapped:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
