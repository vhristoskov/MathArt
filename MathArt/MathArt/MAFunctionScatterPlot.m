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
@property (nonatomic, strong) NSMutableArray* functionPlotData;
@property (nonatomic, assign) CGPoint payoffPoint;
@property (nonatomic, strong) CPTScatterPlot* functionPlot;
@property (nonatomic, strong) CPTXYPlotSpace* plotSpace;

@end

@implementation MAFunctionScatterPlot


#pragma mark - Initialization methods

// Initialise the scatter plot in the provided hosting view with the provided data.
// The data array should contain NSValue objects each representing a CGPoint.
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
    self.graph.plotAreaFrame.paddingRight = kGraphPlotAreaFramePaddingRigth;
    
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
    CPTMutableLineStyle* functionPlotLineStyle = [CPTMutableLineStyle lineStyle];
    functionPlotLineStyle.lineColor = [CPTColor colorWithComponentRed:0.7f green:0.7f blue:0.7f alpha:0.7f];
    functionPlotLineStyle.lineWidth = 1.f;
    
    // Create the plot symbol we're going to use.
    CPTPlotSymbol* plotSymbol = [CPTPlotSymbol ellipsePlotSymbol];
    plotSymbol.lineStyle = functionPlotLineStyle;
    plotSymbol.size = CGSizeMake(8.0, 8.0);
    CPTColor* areaColor = [CPTColor colorWithComponentRed:0.7f green:0.7f blue:0.7f alpha:0.7f];
    CPTFill* areaFill = [CPTFill fillWithColor:areaColor];
    plotSymbol.fill = areaFill;
    
    // Add payoff Plot to the graph
    self.functionPlot = [[CPTScatterPlot alloc] init];
    self.functionPlot.identifier = kPayoffPlotName;
    self.functionPlot.dataSource = self.datasource;
    self.functionPlot.dataLineStyle = functionPlotLineStyle;
    self.functionPlot.plotSymbol = plotSymbol;
    self.functionPlot.areaFill = areaFill;
    self.functionPlot.areaBaseValue = CPTDecimalFromString(@"0");
    [self.graph addPlot:self.functionPlot];
    
    
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
    xAxis.minorTickLineStyle = gridLineStyle;
//    xAxis.minorGridLineStyle = gridLineStyle;
//    xAxis.minorTicksPerInterval = 1;
    xAxis.tickDirection = CPTSignNegative;
    
    // xAxis Title configuration
    CPTMutableTextStyle *titleStyle = [CPTMutableTextStyle textStyle];
    titleStyle.color = [[CPTColor whiteColor] colorWithAlphaComponent:0.5f];
    titleStyle.fontName = kDefaultNormalFont;
    titleStyle.fontSize = 15.0f;
    xAxis.titleTextStyle = titleStyle;
    xAxis.titleLocation =  CPTDecimalFromDouble(self.plotSpace.xRange.maxLimitDouble);
    xAxis.titleOffset = 10.f;
    xAxis.title = @"X";

    // xLabels configuration
    xAxis.labelingPolicy = CPTAxisLabelingPolicyFixedInterval;
    xAxis.labelTextStyle = textStyle;
    xAxis.majorIntervalLength = CPTDecimalFromFloat(2.0f);

    
    // yAxis Lines Configuration
    CPTAxis* yAxis = axisSet.yAxis;

    yAxis.axisLineStyle = gridLineStyle;
    yAxis.majorTickLineStyle = gridLineStyle;
    yAxis.majorTickLength = kMajorTickLengthYAxis;
    yAxis.majorGridLineStyle = gridLineStyle;
    yAxis.minorTickLineStyle = gridLineStyle;
//    yAxis.minorGridLineStyle = gridLineStyle;
//    yAxis.minorTicksPerInterval = 1;
    yAxis.tickDirection = CPTSignNegative;
    
    titleStyle.color = [[CPTColor whiteColor] colorWithAlphaComponent:0.5f];
    titleStyle.fontName = kDefaultNormalFont;
    titleStyle.fontSize = 15.0f;
    yAxis.titleTextStyle = titleStyle;
    yAxis.titleLocation =  CPTDecimalFromDouble(self.plotSpace.yRange.maxLimitDouble - 0.5f);
    yAxis.titleOffset = 40.f;
    yAxis.title = @"Y";
    
    // yLabels configuration
    yAxis.labelingPolicy = CPTAxisLabelingPolicyFixedInterval;
    yAxis.labelTextStyle = textStyle;
    yAxis.majorIntervalLength = CPTDecimalFromFloat(10.0f);
   
}

- (void)reloadData
{
    [self.functionPlot reloadData];
}
@end
