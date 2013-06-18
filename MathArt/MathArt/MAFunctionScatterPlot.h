//
//  FCPayoffScatterPlot.h
//  FarmChem
//
//  Created by Victor Hristoskov on 4/3/13.
//  Copyright (c) 2013 Stanimir Nikolov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CorePlot-CocoaTouch.h"
#import "MAFunctionScatterPlotConstants.h"

@interface MAFunctionScatterPlot : NSObject 

@property (nonatomic, strong) NSArray* xAxisLabels;
@property (nonatomic, strong) NSArray* yAxisLabels;
@property (nonatomic, strong) CPTXYGraph* graph;
@property (nonatomic, weak) id<CPTScatterPlotDataSource> datasource;

- (id)initWithHostingView:(CPTGraphHostingView *)hostingView payoffPlotData:(NSMutableArray *)payoffData payoffPoint:(CGPoint)payoffPoint;
- (id)initWithHostingView:(CPTGraphHostingView *)hostingView datasource:(id<CPTScatterPlotDataSource>)datasource;

- (void)initialisePlot;
- (void)reloadData;

@end
