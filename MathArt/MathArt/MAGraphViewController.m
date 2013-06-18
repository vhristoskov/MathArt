//
//  MAGraphViewController.m
//  MathArt
//
//  Created by Victor Hristoskov on 6/18/13.
//  Copyright (c) 2013 MentorMate. All rights reserved.
//

#import "MAGraphViewController.h"
#import "DDMathParser.h"

static const NSInteger kDefaultVariableVal = 5;

@interface MAGraphViewController ()
@property (strong, nonatomic) NSRegularExpression* regex;
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
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background"]];

    NSError* error = nil;
    self.regex = [[NSRegularExpression alloc] initWithPattern:@"([a-z])" options:NSRegularExpressionCaseInsensitive error:&error];
    if(error){
        NSLog(@"Regex initialization error: %@", [error localizedDescription]);
    }

    NSDictionary* argsDict = [self variablesOfFunction:self.functionString];
    self.functionString = [self.regex stringByReplacingMatchesInString:self.functionString options:0 range:NSMakeRange(0, self.functionString.length) withTemplate:@"$$1"];

    error = nil;
    NSString* result = [[self.functionString numberByEvaluatingStringWithSubstitutions:argsDict error:&error] stringValue];
    NSLog(@"%@", result);
    
    if (error) {
        UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Function evaluation problem" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
    }

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


#pragma mark - Utility methods

- (NSDictionary*)variablesOfFunction:(NSString*)functionSting
{
    __block NSMutableDictionary* args = nil;
    
    if(functionSting){
        args = [NSMutableDictionary dictionaryWithCapacity:1];
        [self.regex enumerateMatchesInString:functionSting options:0 range:NSMakeRange(0, functionSting.length) usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
            
            NSString* matchedStr = [self.functionString substringWithRange:result.range];
            if(![args valueForKey:matchedStr]){
                [args setValue:@(kDefaultVariableVal) forKey:matchedStr];
            }
        }];
    }
    
    return args;
}
@end
