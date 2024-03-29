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
#import "YGPerformance.h"
#import "globals.h"

#define kAppVersion "0.2"
#define kAppBildDate "April 4, 2023"

// Process command line of app, to set app mode
void processArgs(int argc, const char * argv[]);

// Handler for all exceptions
void handleUncaughtException(NSException *exception);

int main(int argc, const char * argv[]) {
    
    @autoreleasepool {

        // Info
        printf("\nmediaTimeStamper. v%s, %s. @Yan Gerasimuk", kAppVersion, kAppBildDate);

        // Set app working modes
        processArgs(argc, argv);
        
        // Set own function to handle uncaught exceptions
        NSSetUncaughtExceptionHandler(handleUncaughtException);
        
        // Set start timestamp
        NSDate *startDate = [NSDate date];
        
        NSArray <YGFile *>*files = [[NSArray alloc] init];
        files = [YGFileEnumerator enumerateCurDir];
        
        if([files count] > 0){
            // Generate collection - tuples with main and depend files over one base name
            NSArray *tuples = [YGFileEnumerator generateFileTuples:files];
            
            for (YGFileTuple *tuple in tuples)
                [tuple timeStamp];
                
                printf("\nEnumerated for rename: %ld and renamed: %ld files", [files count], [YGPerformance renamedSharedCounter]);
                printf("\nSize of renamed files: %s (=%ld B)", [[YGPerformance sizeOfProcessedFilesInHumanStyle] cStringUsingEncoding:NSUTF8StringEncoding], [YGPerformance sizeOfProcessedFiles]);
        }
        else{
            printf("\nNo files for processing");
        }
        
        // Set finish timestamp for statistic
        NSDate *finishDate = [NSDate date];
        NSString *timeOfExecute = [NSString stringWithFormat:@"%@", [YGPerformance timeExecutingFrom:startDate to:finishDate]];
        printf("\nTime of execution: %s", [timeOfExecute cStringUsingEncoding:NSUTF8StringEncoding]);
        
    }
    printf("\n\n");
    return 0;
}

/*
 Process command line of app, to set app mode
 */
void processArgs(int argc, const char * argv[]){
    // defaults
    isAppModeSilent = YES;
    isAppModeTest = NO;
    
    for(int i = 1; i < argc; i++){
        
        if(argv[i][1] == '-'){  // --info --metaonly
            if(!strcmp(argv[i], "--info"))
                isAppModeSilent = NO;
            else if(!strcmp(argv[i], "--test"))
                isAppModeTest = YES;
        }
        else{                   // -imt
            for(int j = 1; j < strlen(argv[i]); j++){
                if(argv[i][j] == 'i')
                    isAppModeSilent = NO;
                else if(argv[i][j] == 't')
                    isAppModeTest = YES;
            }
        }
    } // for
}

/*
 Handler for all exceptions
 */
void handleUncaughtException(NSException *exception){
    printf("\nUncaught earlier exception in main(). Exception: %s\n\n", [[exception description] cStringUsingEncoding:NSUTF8StringEncoding]);
    exit(EXIT_FAILURE);
}
