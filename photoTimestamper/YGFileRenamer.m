//
//  YGFileRenamer.m
//  photoTimestamper
//
//  Created by Ян on 27/01/2017.
//  Copyright © 2017 Yan Gerasimuk. All rights reserved.
//

#import "YGFileRenamer.h"

@implementation YGFileRenamer

+(BOOL)copyFileFrom:(YGFile *)srcFile to:(YGFile *)dstFile{
#ifdef FUNC_DEBUG
#undef FUNC_DEBUG
#endif
    
#ifdef FUNC_DEBUG
    NSLog(@"From: %@", srcFile.URL);
    NSLog(@"To: %@", dstFile.URL);
#endif
    
    BOOL resultFunc = NO;
    NSError *error = nil;
    NSFileManager *fm = [NSFileManager defaultManager];

    if([fm copyItemAtURL:srcFile.URL toURL:dstFile.URL error:&error]){
        resultFunc = YES;
    }
    else{
        printf("\nError! Can not copy file: %s to: %s", [srcFile.name cStringUsingEncoding:NSUTF8StringEncoding], [dstFile.name cStringUsingEncoding:NSUTF8StringEncoding]);
        if(error != nil)
            printf("\nError: %s", [[error description] cStringUsingEncoding:NSUTF8StringEncoding]);
    }

    return resultFunc;
}

+(BOOL) removeFile:(YGFile *)file{
#ifdef FUNC_DEBUG
#undef FUNC_DEBUG
#endif
    
    BOOL resultFunc = NO;
    NSError *error = nil;
    NSFileManager *fm = [NSFileManager defaultManager];
    
    if([fm removeItemAtURL:file.URL error:&error]){
#ifdef FUNC_DEBUG
        printf("\nOld file successfully removed from disk");
#endif
        resultFunc = YES;
    }
    else{
        printf("\nError! Can not remove old file: %s", [file.name cStringUsingEncoding:NSUTF8StringEncoding]);
        if(error != nil)
            printf("\nError: %s", [[error description] cStringUsingEncoding:NSUTF8StringEncoding]);
    }
    
    return resultFunc;
}

@end
