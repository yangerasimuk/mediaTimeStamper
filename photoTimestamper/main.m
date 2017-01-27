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

void getEXIF(NSURL *url);

int main(int argc, const char * argv[]) {
    printf(" ");
    
    @autoreleasepool {
        
        printf("\n\nphotoTimestamper. Yan Gerasimuk");
        
        // Set start timestamp
        NSDate *startDate = [NSDate date];
        
        // File processing counter
        NSUInteger renamedFilesCount = 0;
        
        NSArray *files = [[NSArray alloc] init];
        files = [YGFileEnumerator enumerateCurDir];
        printf("\nFiles enumerate count: %ld", (long)[files count]);
        
        for(YGFile *file in files){
            
            if(file.type == YGFileTypePhoto && file.nameType == YGFileNameTypeRaw){
                printf("\n%s", [[file.URL absoluteString] cStringUsingEncoding:NSUTF8StringEncoding]);
                
                YGFile *newFile = [[YGFile alloc] initWithFileName:[file makeTimestampName]];
                
                if(!newFile.isExistOnDisk){
                    if([YGFileRenamer copyFileFrom:file to:newFile]){
                        if([newFile isEqual:file]){
                            [YGFileRenamer removeFile:file];
                            renamedFilesCount++;
                        }
                    }
                }
                else{
                    printf("\nWarning! File already exist on disk");
                }
            }
        }
        
        // Set finish timestamp
        NSDate *finishDate = [NSDate date];
        NSString *timeOfExecute = [NSString stringWithFormat:@"%@", [YGPerformance timeExecutingFrom:startDate to:finishDate]];
        printf("\nRenamed photo count: %ld", renamedFilesCount);
        printf("\nTime of execution: %s", [timeOfExecute cStringUsingEncoding:NSUTF8StringEncoding]);
        
    }
    printf("\n");
    return 0;
}
