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

@interface MAFunctionsListViewController () <iCarouselDataSource, iCarouselDelegate>

@property (strong, nonatomic) IBOutlet UINavigationBar *navigationBar;
@property (strong, nonatomic) IBOutlet iCarousel *carousel;

@property (strong, nonatomic) NSMutableArray* functions;
@end

@implementation MAFunctionsListViewController

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.functions = @[@"x ** 2", @"(x + 1) / 5", @"sin(6x)", @"arctg(a + x)", @"f - 1"].mutableCopy;
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
    UILabel *label = nil;
    
    //create new view if no view is available for recycling
    if (!view)
    {
        view = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 240.0f, 380.0f)];
        
        ((UIImageView *)view).image = [UIImage imageNamed:@"page.png"];
        view.contentMode = UIViewContentModeScaleAspectFill;
        label = [[UILabel alloc] initWithFrame:view.bounds];
        label.backgroundColor = [UIColor clearColor];
        label.textAlignment = NSTextAlignmentCenter;
        label.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:22.f];
        label.tag = 1;
        [view addSubview:label];
    }
    else
    {
        //get a reference to the label in the recycled view
        label = (UILabel *)[view viewWithTag:1];
    }
    label.text = self.functions[index];
    
    return view;
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

- (IBAction)addFunction:(id)sender {
    NSInteger index = MAX(0, self.carousel.currentItemIndex);
    [self.functions insertObject:@"f(x) + g(xs)" atIndex:index];
    [self.carousel insertItemAtIndex:index animated:YES];
}

@end
