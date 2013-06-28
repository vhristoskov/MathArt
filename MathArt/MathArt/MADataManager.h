//
//  MADataManager.h
//  MathArt
//
//  Created by Victor Hristoskov on 6/28/13.
//  Copyright (c) 2013 MentorMate. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MADataManager : NSObject
+ (MADataManager*)sharedManager;

- (void)functionsWithCompletion:(void(^)(NSArray* functions, NSError* error))completion;

- (void)updateFunctionsWithArray:(NSArray*)functions completion:(void(^)(NSError* error))completion;
@end
