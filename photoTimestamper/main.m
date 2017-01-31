//
//  main.m
//  photoTimestamper
//
//  Created by Ян on 27/01/2017.
//  Copyright © 2017 Yan Gerasimuk. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "YGFile.h"
#import "YGFileTuple.h"
#import "YGFileEnumerator.h"
#import "YGFileRenamer.h"
#import "YGPerformance.h"
#import "globals.h"

#define kAppVersion "0.3"
#define kAppBildDate "31 january 2017"

int main(int argc, const char * argv[]) {
#ifdef FUNC_DEBUG
#undef FUNC_DEBUG
#endif
    
    @autoreleasepool {
        
        // Set app working mode: silent or noisy
        extern BOOL isAppModeSilent;
        if((argc == 2) && ((strcmp(argv[1], "-i") || (strcmp(argv[1], "--info")))))
            isAppModeSilent = NO;
        else
            isAppModeSilent = YES;
        
        // info
        printf("\nphotoTimestamper. Version %s, build: %s. @Yan Gerasimuk", kAppVersion, kAppBildDate);
        
        // Set start timestamp
        NSDate *startDate = [NSDate date];
        
        // File processing counter
        NSUInteger renamedFilesCount = 0;
        
        NSArray <YGFile *>*files = [[NSArray alloc] init];
        files = [YGFileEnumerator enumerateCurDir];
        
        // Generate collection - tuples with main and depend files over one base name
        NSArray *tuples = [YGFileEnumerator generateFileTuples:files];
        
        for (YGFileTuple *tuple in tuples){
            if([tuple timeStamp])
                renamedFilesCount++;
        }
        
        // Set finish timestamp
        NSDate *finishDate = [NSDate date];
        NSString *timeOfExecute = [NSString stringWithFormat:@"%@", [YGPerformance timeExecutingFrom:startDate to:finishDate]];
        printf("\nStatistic. Enumerated files: %ld and renamed: %ld", (long)[files count], renamedFilesCount);
        printf("\nTime of execution. %s", [timeOfExecute cStringUsingEncoding:NSUTF8StringEncoding]);
        
    }
    printf("\n\n");
    return 0;
}
