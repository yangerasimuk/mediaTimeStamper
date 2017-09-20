//
//  YGFileEnumerator.m
//  photoTimestamper
//
//  Created by Ян on 27/01/2017.
//  Copyright © 2017 Yan Gerasimuk. All rights reserved.
//

#import "YGFileEnumerator.h"

@implementation YGFileEnumerator

/*
 Enumerate all files in current directory. Function sort files witch can be processed.
 Depend files add to result array in beginning and picture filess add to end.
 Inner directories skiped.
 */
+(NSArray <YGFile *>*)enumerateCurDir{
    
    extern BOOL isAppModeSilent;
    
    NSMutableArray <YGFile *>*resultFiles = [[NSMutableArray alloc] init];
    
    @try{
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
                    else
                        if(!isAppModeSilent)
                            printf("\n%s - skip file, already have timestamped name", [file.name cStringUsingEncoding:NSUTF8StringEncoding]);
                }
            }
        } // while
    }
    @catch(NSException *ex){
        printf("\nException in -[YGFileEnumerator enumerateCurDir]. Exception: %s", [[ex description] cStringUsingEncoding:NSUTF8StringEncoding]);
        @throw;
    }
    @finally{
        return [resultFiles copy];
    }
}


/*
 Generate array of tuples from array of files.
 If tuple with base name exists, file add to inner array of this tuple, else creating new tuple.
 */
+(NSArray <YGFileTuple *>*)generateFileTuples:(NSArray <YGFile *>*)files{

    NSMutableDictionary *tuples = [[NSMutableDictionary alloc] init];
    
    @try{
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
    }
    @catch(NSException *ex){
        printf("\nException in -[YGFileEnumerator generateFileTuples:]. Exception: %s", [[ex description] cStringUsingEncoding:NSUTF8StringEncoding]);
        @throw;
        
    }
    @finally{
        return [tuples allValues];
    }
}

@end
