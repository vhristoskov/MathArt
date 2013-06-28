//
//  MADataManager.m
//  MathArt
//
//  Created by Victor Hristoskov on 6/28/13.
//  Copyright (c) 2013 MentorMate. All rights reserved.
//

static NSString* const kFunctionsDataFileName = @"functionsData.plist";

#import "MADataManager.h"
static dispatch_queue_t q;

static MADataManager* sharedDataManager = nil;

@implementation MADataManager

+ (MADataManager*)sharedManager
{
    if(!sharedDataManager){
        @synchronized(self){
            if(!sharedDataManager){
                q = dispatch_queue_create("MAMathArt Worker Queue", NULL);
                sharedDataManager = [[super allocWithZone:NULL] init];
            }
        }
    }
    return sharedDataManager;
}

+(id)allocWithZone:(NSZone *)zone
{
    return [self sharedManager];
}

- (id)init
{
    if (sharedDataManager){
        return sharedDataManager;
    }
    self = [super init];
    if (self) {
    }
    return self;
}

- (void)functionsWithCompletion:(void(^)(NSArray* functions, NSError* error))completion
{
    dispatch_async(q, ^{
        
        NSError* error = nil;
        NSString* functionsDataPath =  [self pathForFileName:@"functionsData.plist"];
        
        NSFileManager* fileManager = [NSFileManager defaultManager];
        
        if (! [fileManager fileExistsAtPath:functionsDataPath]) {
            NSString* defaultFunctionsPath = [[NSBundle mainBundle] pathForResource:@"defaultFunctions" ofType:@"plist"];
            [fileManager copyItemAtPath:defaultFunctionsPath toPath:functionsDataPath error:&error];
        }

        NSArray* functionsArray = [NSArray arrayWithContentsOfFile:functionsDataPath];
        if (completion) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(functionsArray, error);
            });
        }
    });
}

- (void)updateFunctionsWithArray:(NSArray*)functions completion:(void(^)(NSError* error))completion
{
    dispatch_async(q, ^{
        
        NSString* functionsDataPath = [self pathForFileName:kFunctionsDataFileName];
        BOOL isSuccessfully = [functions writeToFile:functionsDataPath atomically:YES];
        NSError* error = isSuccessfully ? nil : [NSError errorWithDomain:@"CannotWriteInPlist" code:212 userInfo:nil];
        if (completion) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(error);
            });
        }
    });
}

- (NSString*)pathForFileName:(NSString*)filename
{
    NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString* documentDir = paths[0];
    NSString* functionsDataPath = [documentDir stringByAppendingPathComponent:filename];
    return functionsDataPath;
}
@end
