//
//  MAFunctionsListViewController.m
//  MathArt
//
//  Created by Victor Hristoskov on 6/17/13.
//  Copyright (c) 2013 MentorMate. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "iCarousel.h"
#import "MAFunctionsListViewController.h"
#import "MAFunctionGraphViewController.h"
#import "MACarouselItemView.h"
#import "MADataManager.h"


static NSString* const kDefaultFuncion = @"x + 1";

@interface MAFunctionsListViewController () <iCarouselDataSource, iCarouselDelegate, UITextFieldDelegate>

@property (strong, nonatomic) IBOutlet UINavigationBar *navigationBar;
@property (strong, nonatomic) IBOutlet iCarousel *carousel;

@property (strong, nonatomic) NSMutableArray* functions;
@end

@implementation MAFunctionsListViewController

- (void)awakeFromNib
{
    [super awakeFromNib];
    [[MADataManager sharedManager] functionsWithCompletion:^(NSArray *functions, NSError *error) {
        if(!error){
            self.functions = [NSMutableArray arrayWithArray:functions];
            [self.carousel reloadData];
        }else{
            NSLog(@"Error while reading the functions %@", error.localizedDescription);
        }
    }];
}

- (void)viewDidLoad
{
    [super viewDidLoad];    
    self.carousel.type = iCarouselTypeCoverFlow;
//    self.carousel.vertical = YES;
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background"]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    _carousel.delegate = nil;
    _carousel.dataSource = nil;
}


#pragma mark - iCarousel Datasource methods

- (NSUInteger)numberOfItemsInCarousel:(iCarousel *)carousel
{
    return self.functions.count;
}

- (UIView *)carousel:(iCarousel *)carousel viewForItemAtIndex:(NSUInteger)index reusingView:(UIView *)view
{
    MACarouselItemView* carouselItemView = (MACarouselItemView*)view;
    if (!carouselItemView)
    {
        
        carouselItemView = [[NSBundle mainBundle] loadNibNamed:@"MACarouselItemView" owner:self options:nil][0];
        [carouselItemView.deleteButton addTarget:self action:@selector (removeFunctionItem:) forControlEvents:UIControlEventTouchUpInside];
        
        [carouselItemView.editButton addTarget:self action:@selector (editFunctionItem:) forControlEvents:UIControlEventTouchUpInside];
        carouselItemView.functionTextField.delegate = self;
        carouselItemView.functionTextField.userInteractionEnabled = NO;
    }
    
    carouselItemView.functionTextField.text = self.functions[index];
    return carouselItemView;
}

- (CGFloat)carouselItemWidth:(iCarousel *)carousel;
{
    return 200.f;
}


#pragma mark - iCarousel Delegate methods

- (void)carousel:(iCarousel *)carousel didSelectItemAtIndex:(NSInteger)index
{
    if(carousel.decelerating == NO && index == carousel.currentItemIndex){
        
        MAFunctionGraphViewController* graphVC = [[MAFunctionGraphViewController alloc] initWithNibName:@"MAFunctionGraphViewController" bundle:nil];
        graphVC.functionString = self.functions[index];
        
        [graphVC setModalTransitionStyle:UIModalTransitionStyleFlipHorizontal];
        [self presentViewController:graphVC animated:YES completion:nil];
    }
}


#pragma mark - Action methods

- (IBAction)addFunctionItem:(id)sender {
    NSInteger index = MAX(0, self.carousel.currentItemIndex);
    [self.functions insertObject:kDefaultFuncion atIndex:index];
    [self.carousel insertItemAtIndex:index animated:YES];
    
    [[MADataManager sharedManager] updateFunctionsWithArray:self.functions completion:nil];
}

- (IBAction)removeFunctionItem:(id)sender
{
    if (self.carousel.numberOfItems > 0)
    {
        NSInteger index = self.carousel.currentItemIndex;
        [self.carousel removeItemAtIndex:index animated:YES];
        [self.functions removeObjectAtIndex:index];
        [[MADataManager sharedManager] updateFunctionsWithArray:self.functions completion:nil];
    }
}

- (IBAction)editFunctionItem:(id)sender
{
    MACarouselItemView* carouselItemView = (MACarouselItemView*)((UIButton*)sender).superview;
    
    carouselItemView.functionTextField.userInteractionEnabled = YES;
    [carouselItemView.functionTextField becomeFirstResponder];
    self.carousel.scrollEnabled = NO;
}


#pragma mark - UITextField Delegate methods

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    CGSize offset = CGSizeMake(0.0f, 90.f);
    [UIView animateWithDuration:0.25f animations:^{
        self.carousel.viewpointOffset = offset;
    }];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    MACarouselItemView* carouselItemView = (MACarouselItemView*)textField.superview;
    carouselItemView.functionTextField.userInteractionEnabled = NO;
        
    NSInteger index = self.carousel.currentItemIndex;
    self.functions[index] = textField.text;
    [[MADataManager sharedManager] updateFunctionsWithArray:self.functions completion:nil];

    CGSize offset = CGSizeMake(0.0f, 0.f);
    [UIView animateWithDuration:0.5f animations:^{
        self.carousel.viewpointOffset = offset;
    }completion:^(BOOL finished) {
        if(finished){
            self.carousel.scrollEnabled = YES;
        }
    } ];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return  YES;
}


@end
