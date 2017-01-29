//
//  main.m
//  photoTimestamper
//
//  Created by Ян on 27/01/2017.
//  Copyright © 2017 Yan Gerasimuk. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "YGFile.h"
#import "YGFileEnumerator.h"
#import "YGFileRenamer.h"
#import "YGPerformance.h"
#import "globals.h"

#define kAppVersion "0.2"
#define kAppBildDate "29 january 2017"

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
        
        NSArray *files = [[NSArray alloc] init];
        files = [YGFileEnumerator enumerateCurDir];
        
        for(YGFile *file in files){
#ifdef FUNC_DEBUG
            printf("\n%s", [[file description] cStringUsingEncoding:NSUTF8StringEncoding]);
#endif
            
            if(file.type & (YGFileTypePhoto | YGFileTypePhotoDepend) && (file.nameType == YGFileNameTypeRaw)){
                
                NSString *newFileName = @"";
                
                if(file.type == YGFileTypePhotoDepend && file.nameType == YGFileNameTypeRaw)
                    newFileName = [NSString stringWithFormat:@"%@", [file makeTimestampNameFromMainFile]];
                else if(file.type == YGFileTypePhoto && file.nameType == YGFileNameTypeRaw)
                    newFileName = [NSString stringWithFormat:@"%@", [file makeTimestampName]];
                
                if(newFileName != nil && [newFileName compare:@""] != NSOrderedSame){
                    YGFile *newFile = [[YGFile alloc] initWithFileName:newFileName];
                    
                    if(!newFile.isExistOnDisk){
                        if([YGFileRenamer copyFileFrom:file to:newFile]){
                            if([newFile isEqual:file]){
                                [YGFileRenamer removeFile:file];
                                renamedFilesCount++;
                                if(!isAppModeSilent)
                                    printf("\n...%s -> %s", [[file name] cStringUsingEncoding:NSUTF8StringEncoding], [[newFile name] cStringUsingEncoding:NSUTF8StringEncoding]);
                            }
                        }
                    }
                    else{
                        printf("\nWarning! File already exist on disk");
                    }
                }
            } //if
            else{
                if(!isAppModeSilent)
                    printf("\n...%s - skip file", [[file name] cStringUsingEncoding:NSUTF8StringEncoding]);
            }
        } // for
        
        // Set finish timestamp
        NSDate *finishDate = [NSDate date];
        NSString *timeOfExecute = [NSString stringWithFormat:@"%@", [YGPerformance timeExecutingFrom:startDate to:finishDate]];
        printf("\nStatistic. Enumerated files: %ld and renamed: %ld", (long)[files count], renamedFilesCount);
        printf("\nTime of execution. %s", [timeOfExecute cStringUsingEncoding:NSUTF8StringEncoding]);
        
    }
    printf("\n\n");
    return 0;
}
