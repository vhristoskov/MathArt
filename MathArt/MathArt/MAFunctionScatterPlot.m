//
//  FCPayoffScatterPlot.m
//  FarmChem
//
//  Created by Victor Hristoskov on 4/3/13.
//  Copyright (c) 2013 Stanimir Nikolov. All rights reserved.
//

#import "MAFunctionScatterPlot.h"

@interface MAFunctionScatterPlot () <CPTScatterPlotDelegate>

@property (nonatomic, strong) CPTGraphHostingView* hostingView;
@property (nonatomic, strong) NSMutableArray* payoffPlotData;
@property (nonatomic, assign) CGPoint payoffPoint;
@property (nonatomic, strong) CPTScatterPlot* payoffPlot;
@property (nonatomic, strong) CPTScatterPlot* investmentPlot;
@property (nonatomic, strong) CPTXYPlotSpace* plotSpace;

@end

@implementation MAFunctionScatterPlot


#pragma mark - Initialization methods

// Initialise the scatter plot in the provided hosting view with the provided data.
// The data array should contain NSValue objects each representing a CGPoint.
- (id)initWithHostingView:(CPTGraphHostingView *)hostingView payoffPlotData:(NSMutableArray *)payoffData payoffPoint:(CGPoint)payoffPoint
{
    self = [super init];
    if(self){
        self.hostingView = hostingView;
        self.payoffPlotData = payoffData;
        self.payoffPoint = payoffPoint;
        self.graph = nil;
    }
    return self;
}

- (id)initWithHostingView:(CPTGraphHostingView *)hostingView datasource:(id<CPTScatterPlotDataSource>)datasource
{
    self = [super init];
    if(self){
        self.hostingView = hostingView;
        self.graph = nil;
        self.datasource = datasource;
    }
    return self;
}

// This does the actual work of creating the plot if we don't already have a graph object.
-(void)initialisePlot
{
    if( !self.hostingView || !self.datasource ){
        NSLog(@"Scatter Plot: Cannot initialise plot without hosting view and data!");
        return;
    }
    
    if(self.graph){
        NSLog(@"Scatter Plot: Graph object already exists.");
        return;
    }
    
    [self configureGraph];
    [self configurePlots];
    [self configureAxes];
}



#pragma mark - Utility methods

-(void)configureGraph
{
    // Create a graph object which we will use to host just one scatter plot.
    self.graph = [[CPTXYGraph alloc] initWithFrame:self.hostingView.bounds];
    self.graph.plotAreaFrame.masksToBorder = NO;
    self.graph.plotAreaFrame.masksToBounds = NO;
    
    self.graph.paddingTop = kGraphPaddingTop;
    self.graph.paddingRight = kGraphPaddingRight;
    self.graph.paddingBottom = kGraphPaddingBottom;
    self.graph.paddingLeft = kGraphPaddingLeft;

    // Add some padding to the graph, with more at the bottom for axis labels.
    self.graph.plotAreaFrame.paddingBottom = kGraphPlotAreaFramePaddingBottom;
    self.graph.plotAreaFrame.paddingLeft = kGraphPlotAreaFramePaddingLeft;
    
    // Setup the graph title
    CPTMutableTextStyle *titleStyle = [CPTMutableTextStyle textStyle];
    titleStyle.color = [[CPTColor whiteColor] colorWithAlphaComponent:0.5f];
    titleStyle.fontName = kDefaultNormalFont;
    titleStyle.fontSize = 30.0f;
    self.graph.titleTextStyle = titleStyle;
    self.graph.titlePlotAreaFrameAnchor = CPTRectAnchorBottomRight;
    self.graph.titleDisplacement = CGPointMake(-75.f, 50.0f);
    
    NSString *title = @"MathArt";
    self.graph.title = title;
    
    // Tie the graph we've created with the hosting view.
    self.hostingView.hostedGraph = self.graph;
    
}

-(void)configurePlots
{
    // Create a line style that we will apply to the payoff plot
    CPTMutableLineStyle* payoffPlotLineStyle = [CPTMutableLineStyle lineStyle];
    payoffPlotLineStyle.lineColor = [CPTColor colorWithComponentRed:0.7f green:0.7f blue:0.7f alpha:0.7f];
    payoffPlotLineStyle.lineWidth = 1.f;
    
    // Create the plot symbol we're going to use.
    CPTPlotSymbol* plotSymbol = [CPTPlotSymbol ellipsePlotSymbol];
    plotSymbol.lineStyle = payoffPlotLineStyle;
    plotSymbol.size = CGSizeMake(8.0, 8.0);
    CPTColor* areaColor = [CPTColor colorWithComponentRed:0.7f green:0.7f blue:0.7f alpha:0.7f];
    CPTFill* areaFill = [CPTFill fillWithColor:areaColor];
    plotSymbol.fill = areaFill;
    
    // Add payoff Plot to the graph
    self.payoffPlot = [[CPTScatterPlot alloc] init];
    self.payoffPlot.identifier = kPayoffPlotName;
    self.payoffPlot.dataSource = self.datasource;
    self.payoffPlot.dataLineStyle = payoffPlotLineStyle;
    self.payoffPlot.plotSymbol = plotSymbol;
    self.payoffPlot.areaFill = areaFill;
    self.payoffPlot.areaBaseValue = CPTDecimalFromString(@"0");
    [self.graph addPlot:self.payoffPlot];
    
    
    // We modify the graph's plot space to setup the axis' min / max values.
    self.plotSpace = (CPTXYPlotSpace*)self.graph.defaultPlotSpace;
    self.plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(kXAxisMinValue) length:CPTDecimalFromFloat(kXAxisMaxValue - kXAxisMinValue)];
    self.plotSpace.yRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(kYAxisMinValue) length:CPTDecimalFromFloat(kYAxisMaxValue - kYAxisMinValue)];
}

-(void)configureAxes
{
    // Create a text style that we will use for the axis labels.
    CPTMutableTextStyle* textStyle = [CPTMutableTextStyle textStyle];
    textStyle.fontName = kDefaultBoldFont;
    textStyle.fontSize = 12.f;
    textStyle.color = [CPTColor whiteColor];
    
    // Create a line style that we will apply to the axis
    CPTMutableLineStyle* axisLineStyle = [CPTMutableLineStyle lineStyle];
    axisLineStyle.lineColor = [CPTColor whiteColor];
    axisLineStyle.lineWidth = 1.f;
    
    CPTMutableLineStyle* gridLineStyle = [CPTMutableLineStyle lineStyle];
    gridLineStyle.lineColor = [CPTColor lightGrayColor];
    gridLineStyle.lineWidth = 1.f;

  
    // xAxis Lines Configuration
    CPTXYAxisSet* axisSet = (CPTXYAxisSet*)self.graph.axisSet;
    CPTAxis* xAxis = axisSet.xAxis;
    xAxis.axisLineStyle = gridLineStyle;
    xAxis.majorTickLineStyle = gridLineStyle;
    xAxis.majorTickLength = kMajorTickLengthXAxis;
    xAxis.majorGridLineStyle = gridLineStyle;
    xAxis.minorTicksPerInterval = 0;
    xAxis.tickDirection = CPTSignNegative;
    
    // xAxis Title configuration
    CPTMutableTextStyle *titleStyle = [CPTMutableTextStyle textStyle];
    titleStyle.color = [[CPTColor whiteColor] colorWithAlphaComponent:0.5f];
    titleStyle.fontName = kDefaultNormalFont;
    titleStyle.fontSize = 12.0f;
    xAxis.titleTextStyle = titleStyle;
    xAxis.titleLocation =  CPTDecimalFromDouble(self.plotSpace.xRange.maxLimitDouble - 0.5f);
    xAxis.titleOffset = 25.f;
    xAxis.title = @"X";


    // xLabels configuration
    xAxis.labelingPolicy = CPTAxisLabelingPolicyNone;
    xAxis.labelTextStyle = textStyle;
    NSMutableSet* xLabels = [[NSMutableSet alloc] initWithCapacity:self.xAxisLabels.count];
    NSMutableSet* xLocations = [[NSMutableSet alloc] initWithCapacity:self.xAxisLabels.count];
    int labelLocation = 0;
    for (NSString* xLabel in self.xAxisLabels) {
        CPTAxisLabel* label = [[CPTAxisLabel alloc] initWithText:xLabel textStyle:xAxis.labelTextStyle];
        label.tickLocation = @(labelLocation + .5f).decimalValue;
        label.offset = 2.f;
        if(label){
            [xLabels addObject:label];
            [xLocations addObject:@(labelLocation)];
        }
        ++labelLocation;
    }
    xAxis.axisLabels = xLabels;
    [xLocations addObject:@(labelLocation)];
    xAxis.majorTickLocations = xLocations;
    
    // yAxis Lines Configuration
    CPTAxis* yAxis = axisSet.yAxis;
    yAxis.axisLineStyle = gridLineStyle;
    yAxis.majorTickLineStyle = gridLineStyle;
    yAxis.majorTickLength = kMajorTickLengthYAxis;
    yAxis.majorGridLineStyle = gridLineStyle;
    yAxis.minorTicksPerInterval = 0;
    yAxis.tickDirection = CPTSignNegative;
    
    // yLabels configuration
    yAxis.labelingPolicy = CPTAxisLabelingPolicyNone;
    yAxis.labelTextStyle = textStyle;
    NSMutableSet* yLabels = [[NSMutableSet alloc] initWithCapacity:self.yAxisLabels.count];
    NSMutableSet* yLocations = [[NSMutableSet alloc] initWithCapacity:self.yAxisLabels.count];
    labelLocation = 0;
    for (NSString* yLabel in self.yAxisLabels) {
        CPTAxisLabel* label = [[CPTAxisLabel alloc] initWithText:yLabel textStyle:yAxis.labelTextStyle];
        label.tickLocation = @(labelLocation + .5f).decimalValue;
        label.offset = 6.f;
        if(label){
            [yLabels addObject:label];
            [yLocations addObject:@(labelLocation)];
        }
        ++labelLocation;
    }
    yAxis.axisLabels = yLabels;
    yAxis.majorTickLocations = yLocations;
   
}

- (void)reloadData
{
    [self.payoffPlot reloadData];
    [self.investmentPlot reloadData];
}
@end
