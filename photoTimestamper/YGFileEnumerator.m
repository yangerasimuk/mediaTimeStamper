//
//  YGFileEnumerator.m
//  photoTimestamper
//
//  Created by Ян on 27/01/2017.
//  Copyright © 2017 Yan Gerasimuk. All rights reserved.
//

#import "YGFileEnumerator.h"


@implementation YGFileEnumerator

+(NSArray <YGFileTuple *>*)generateFileTuples:(NSArray <YGFile *>*)files{
#ifdef FUNC_DEBUG
#undef FUNC_DEBUG
#endif
    
#ifdef FUNC_DEBUG
    printf("\n+[YGFileEnumerator generateFileTuples]...");
#endif
    
    NSMutableDictionary *tuples = [[NSMutableDictionary alloc] init];
    
    for(YGFile *file in files){
#ifdef FUNC_DEBUG
        printf("\n\t...%s", [file.name cStringUsingEncoding:NSUTF8StringEncoding]);
        printf("\n\t...%s", [file.baseName cStringUsingEncoding:NSUTF8StringEncoding]);
        printf("\n\t...%s", [[file description] cStringUsingEncoding:NSUTF8StringEncoding]);
        
        
#endif
        
        if([tuples objectForKey:file.baseName] == nil){
#ifdef FUNC_DEBUG
            printf("\n\tNew tuple, with base name: %s", [file.baseName cStringUsingEncoding:NSUTF8StringEncoding]);
#endif
            NSArray *arr = [[NSArray alloc] initWithObjects:file, nil];
            //YGFileTuple *tuple = [[YGFileTuple alloc] initWithName:file.baseName andItems:@[file]];
            YGFileTuple *tuple = [[YGFileTuple alloc] initWithName:file.baseName andItems:arr];
            printf("\n\t%s", [[tuple info] cStringUsingEncoding:NSUTF8StringEncoding]);
            [tuples setObject:tuple forKey:file.baseName];
#ifdef FUNC_DEBUG
            printf("\n\tTuples count: %ld", [tuples count]);
#endif
        }
        else{
            printf("\n\tAdd file to exist tuple, with base name: %s", [file.baseName cStringUsingEncoding:NSUTF8StringEncoding]);
            [tuples[file.baseName] addFile:file];
#ifdef FUNC_DEBUG
            printf("\n\tTuples count: %ld", [tuples count]);
#endif
        }
    } // for
    
#ifdef FUNC_DEBUG
    printf("\n\tTuples count: %ld", [tuples count]);
#endif
    
    return [tuples allValues];
}

+(NSArray <YGFile *>*)enumerateCurDir{
#ifdef FUNC_DEBUG
#undef FUNC_DEBUG
#endif
    
#ifdef FUNC_DEBUG
    printf("\n+[YGFileEnumerator enumerateCurDir]...");
#endif
    
    extern BOOL isAppModeSilent;
    
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
                YGFile *file = [[YGFile alloc] initWithName:fileName];
                if(file != nil && file.nameType != YGFileNameTypeWithTimeStamp){
                    // files dependend from photo like .AAE must process first
                    if(file.type & (YGFileTypeDependByAddingExt | YGFileTypeDependByReplacementExt))
                        [resultFiles insertObject:file atIndex:0];
                    else if(file.type & (YGFileTypePhoto | YGFileTypeVideo)) // skip YGFileTypeNone
                        [resultFiles addObject:file];
                    else
                        if(!isAppModeSilent && 1 != 1)
                            printf("\n%s - skip file", [file.name cStringUsingEncoding:NSUTF8StringEncoding]);
                }
            }
        }
    } // while
    
    return [resultFiles mutableCopy];
}

@end
