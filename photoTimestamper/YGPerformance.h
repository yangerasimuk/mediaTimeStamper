//
//  YGPerformance.h
//  photoTimestamper
//
//  Created by Ян on 27/01/2017.
//  Copyright © 2017 Yan Gerasimuk. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YGPerformance : NSObject

// Time of execution of app, formatted in human style
+(NSString *)timeExecutingFrom:(NSDate *)start to:(NSDate *)finish;

// Increment counter of renamed files
+(void)incrementRenamedSharedCounter;

// Value of counter of renamed files
+(NSUInteger)renamedSharedCounter;

// Add size of all renamed files
+(void)addSizeOfProcessedFile:(NSUInteger)size;

// Value of all renamed files, formatted in human style
+(NSString *)sizeOfProcessedFilesInHumanStyle;

// Value of all renamed files
+(NSUInteger)sizeOfProcessedFiles;

@end
