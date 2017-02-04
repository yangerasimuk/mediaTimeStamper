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

    
    NSMutableDictionary *tuples = [[NSMutableDictionary alloc] init];
    
    for(YGFile *file in files){
        
        if([tuples objectForKey:file.baseName] == nil){

            NSArray *arr = [[NSArray alloc] initWithObjects:file, nil];
            //YGFileTuple *tuple = [[YGFileTuple alloc] initWithName:file.baseName andItems:@[file]];
            YGFileTuple *tuple = [[YGFileTuple alloc] initWithName:file.baseName andItems:arr];
            [tuples setObject:tuple forKey:file.baseName];
        }
        else{
            [tuples[file.baseName] addFile:file];
        }
    } // for
    
    return [tuples allValues];
}

+(NSArray <YGFile *>*)enumerateCurDir{
    
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
                        if(!isAppModeSilent)
                            printf("\n%s - skip file", [file.name cStringUsingEncoding:NSUTF8StringEncoding]);
                }
            }
        }
    } // while
    
    return [resultFiles mutableCopy];
}
 
@end
