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
                    [resultFiles addObject:file];
                    //printf("\n%s", [[file fileInfo] cStringUsingEncoding:NSUTF8StringEncoding]);
                }
            }
        }
    }
    
    return [resultFiles mutableCopy];
}

@end
