//
//  MAFunctionGraphViewController.m
//  MathArt
//
//  Created by Victor Hristoskov on 6/18/13.
//  Copyright (c) 2013 MentorMate. All rights reserved.
//

#import "MAFunctionGraphViewController.h"
#import "DDMathParser.h"
#import "MAFunctionScatterPlot.h"

static const NSInteger kDefaultVariableVal = 5;

@interface MAFunctionGraphViewController () <CPTScatterPlotDataSource>
@property (strong, nonatomic) NSRegularExpression* regex;
//@property (strong, nonatomic) NSArray* xAxisLabels;
//@property (strong, nonatomic) NSMutableArray* yAxisLabels;
@property (strong, nonatomic) NSMutableArray* graphData;
@property (strong, nonatomic) NSString* parsedFunctionString;

@property (strong, nonatomic) MAFunctionScatterPlot* functionScatterPlot;
@property (strong, nonatomic) IBOutlet CPTGraphHostingView *graphHostingView;
@property (strong, nonatomic) IBOutlet UILabel *functionLabel;
@end

@implementation MAFunctionGraphViewController

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
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background"]];

    self.functionLabel.text = self.functionString;
    self.parsedFunctionString = [self parseFunctionString:self.functionString];
    
    [self initializeGraphData];
    self.functionScatterPlot = [[MAFunctionScatterPlot alloc] initWithHostingView:self.graphHostingView datasource:self];
//    self.functionScatterPlot.xAxisLabels = self.xAxisLabels;
//    self.functionScatterPlot.yAxisLabels = self.yAxisLabels;
    [self.functionScatterPlot initialisePlot];
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


#pragma mark - Core Plot Data Source methods

- (NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plot
{
    return self.graphData.count;
}

// Delegate method that returns a single X or Y value for a given plot
- (NSNumber *)numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)idx
{
    
    if([plot.identifier isEqual:kPayoffPlotName]){
        
        NSValue* value = self.graphData[idx];
        CGPoint point = [value CGPointValue];
        
        if (fieldEnum == CPTScatterPlotFieldX) {
            return @(point.x);
        }else{
            return @(point.y);
        }
    }
    return @(0.0);
}


#pragma mark - Utility methods

- (void)initializeGraphData{
    
    //Graph Data initialization
    self.graphData = [NSMutableArray arrayWithCapacity:10];
//    [self.graphData addObject:[NSValue valueWithCGPoint:CGPointMake(.0f, .0f)]];
  
    NSMutableDictionary* argsDict = [self variablesOfFunction:self.functionString withRegex:self.regex];
    
    
    //Axis Data initialization
//    self.xAxisLabels = @[@"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9", @"10"];
//    self.yAxisLabels = [NSMutableArray arrayWithCapacity:10];
    
    for (int xAxisVal = kXAxisMinValue; xAxisVal <= kXAxisMaxValue; ++xAxisVal) {
        
        for (NSString* variable in [argsDict allKeys]) {
            argsDict[variable] = @(xAxisVal);
        }
        NSNumber* yVal = [self evaluateParsedString:self.parsedFunctionString withArgValues:argsDict];
//        [self.yAxisLabels addObject:[yVal stringValue]];
        [self.graphData addObject:[NSValue valueWithCGPoint:CGPointMake(xAxisVal, [yVal doubleValue])]];
    }

    
}

- (NSString*)parseFunctionString:(NSString*)functionStr
{
    NSError* error = nil;
    self.regex = [[NSRegularExpression alloc] initWithPattern:@"([a-z])" options:NSRegularExpressionCaseInsensitive error:&error];
    if(error){
        NSLog(@"Regex initialization error: %@", [error localizedDescription]);
    }
    
    NSString* parsedString = [self.regex stringByReplacingMatchesInString:functionStr options:0 range:NSMakeRange(0, functionStr.length) withTemplate:@"$$1"];
    return parsedString;
}


- (NSNumber*)evaluateParsedString:(NSString*)parsedString withArgValues:(NSDictionary*)argValues
{
    NSError* error = nil;
    NSNumber* result = [parsedString numberByEvaluatingStringWithSubstitutions:argValues error:&error];
    
    if (error) {
        UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Function evaluation problem" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
    }
    
    return result;
}

- (NSMutableDictionary*)variablesOfFunction:(NSString*)functionSting withRegex:(NSRegularExpression*)regex
{
    __block NSMutableDictionary* args = nil;
    
    if(functionSting){
        args = [NSMutableDictionary dictionaryWithCapacity:1];
        [regex enumerateMatchesInString:functionSting options:0 range:NSMakeRange(0, functionSting.length) usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
            
            NSString* matchedStr = [functionSting substringWithRange:result.range];
            if(![args valueForKey:matchedStr]){
                [args setValue:@(kDefaultVariableVal) forKey:matchedStr];
            }
        }];
    }
    
    return args;
}
@end
