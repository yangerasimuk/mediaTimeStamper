//
//  YGFileEnumerator.m
//  photoTimestamper
//
//  Created by Ян on 27/01/2017.
//  Copyright © 2017 Yan Gerasimuk. All rights reserved.
//

#import "YGFileEnumerator.h"

@implementation YGFileEnumerator

+(NSArray <YGFile *>*)enumerateCurDir{
    NSMutableArray <YGFile *>*resultFiles = [[NSMutableArray alloc] init];
    
    NSFileManager *fm = [NSFileManager defaultManager];
    NSString *curDir = [fm currentDirectoryPath];
    NSString *fileName = [[NSString alloc] init];
    BOOL isDir = YES;
    NSDirectoryEnumerator *de = [fm enumeratorAtPath:curDir];
    
    while((fileName = [de nextObject]) != nil){
        [de skipDescendants];
                
        if([fm fileExistsAtPath:fileName isDirectory:&isDir]){
            if(!isDir){
                YGFile *file = [[YGFile alloc] initWithFileName:fileName];
                if(file != nil){
                    // files dependend from photo like .AAE must process first
                    if(file.type == YGFileTypePhotoDepend)
                        [resultFiles insertObject:file atIndex:0];
                    else
                        [resultFiles addObject:file];
                }
            }
        }
    } // while
    
    return [resultFiles mutableCopy];
}

@end
