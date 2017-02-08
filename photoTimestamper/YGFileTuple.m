//
//  YGFileTuple.m
//  photoTimestamper
//
//  Created by Ян on 31/01/2017.
//  Copyright © 2017 Yan Gerasimuk. All rights reserved.
//

#import "YGFileTuple.h"
#import "YGPerformance.h"

@interface YGFileTuple()
-(NSString *)getTimestampedBaseName;
@end

@implementation YGFileTuple {
    NSMutableArray <YGFile *>*files;
}

@synthesize baseName;


/*
 Main init for file tuple.
 Enter items in array may be NSString *filenames or YGFile *files.
 */
-(YGFileTuple *)initWithName:(NSString *)name andItems:(NSArray *)items{
    
    @try{
        if([super init]){
            baseName = name;
            files = [[NSMutableArray alloc] init];
            if(items){
                if([items[0] isMemberOfClass:[YGFile class]]){
                    for(YGFile *file in items){ // files = [items mutableCopy];
                        [files addObject:file];
                    }
                }
                else if([items[0] isMemberOfClass:[NSString class]]){
                    for(NSString *newName in items){
                        YGFile *newFile = [[YGFile alloc] initWithName:newName];
                        [files addObject:newFile];
                    }
                }
            }
        }
    }
    @catch(NSException *ex){
        printf("\nException in -[YGFileTuple initWithName:andItems:]. Exception: %s", [[ex description] cStringUsingEncoding:NSUTF8StringEncoding]);
        @throw;
    }
    @finally{
        return self;
    }
}


/*
 Init for tuple, without items
 */
-(YGFileTuple *)initWithName:(NSString *)name{
    return [self initWithName:name andItems:nil];
}


/*
 Override standart message for debug purposes.
 */
-(NSString *)description{
    NSMutableString *resultDesc = [[NSMutableString alloc] init];
    [resultDesc appendFormat:@"Tuple name: %@", baseName];
    
    if([files count] > 0)
        [resultDesc appendFormat:@" | with %li files:", [files count]];
    
    for(YGFile *file in files)
        [resultDesc appendFormat:@" %@", [file description]];
    
    return [resultDesc copy];
}


/*
 Add files to existing tuple. If tuple with same base name exists, we don't need new one.
 */
-(void)addFile:(YGFile *)file{
    
    @try{
        if([files indexOfObject:file] == NSNotFound)
            [files addObject:file];
    }
    @catch(NSException *ex){
        printf("\nException in -[YGFileTuple addFile:]. Exception: %s", [[ex description] cStringUsingEncoding:NSUTF8StringEncoding]);
        @throw;
    }
}


/*
 Return timestamped base name for tuple, this name will be the same for all files in tuple.
 */
-(NSString *)getTimestampedBaseName{
    
    extern BOOL isAppModeSilent;
    
    NSString *resultName = @"";
    
    @try{
        for(YGFile *f in files){
            if(f.type == YGFileTypePhoto && [f isEXIFAvailible]){
                resultName = [NSString stringWithFormat:@"%@", [f makeTimestampNameFromEXIF]];
                break;
            }
            else if([resultName compare:@""] == NSOrderedSame)
                resultName = [NSString stringWithFormat:@"%@", [f makeTimestampNameFromAttributes]];
        }
        
        if([resultName isEqualTo:nil] || [resultName compare:@""] == NSOrderedSame || [resultName length] < 19){
            @throw [NSException exceptionWithName:@"-[YGFile getTimestampedBaseName]->"
                                           reason:@"Can not make result timestamped base name of tuple"
                                         userInfo:nil];
        }
        
    }
    @catch(NSException *ex){
        printf("\nException in [YGFile getTimestampedBaseName]. Exception: %s", [[ex description] cStringUsingEncoding:NSUTF8StringEncoding]);
        @throw;
    }
    @finally{
        return resultName;
    }
}


/*
 Rename each file in tuple by timestamped base name. If app work in test mode old file don't remove.
 
 Q1: If new file don't equal old one, what to do? Now I'm simple don't remove old file. May be mark new file, some extention? .bak, .old?
 */
-(void)timeStamp{
    
    extern BOOL isAppModeSilent;
    extern BOOL isAppModeTest;
    
    @try{
        NSString *newBaseName = [self getTimestampedBaseName];
        
        for (YGFile *oldFile in files){
            NSString *oldBaseName = [NSString stringWithFormat:@"%@", oldFile.baseName];
            NSString *newName = [oldFile.name stringByReplacingOccurrencesOfString:oldBaseName withString:newBaseName];
            
            YGFile *newFile = [[YGFile alloc] initWithName:newName];
            
            if(!newFile.isExistOnDisk){
                [oldFile copyToFile:newFile];
                [newFile updateFileInfo];
                if([oldFile isEqual:newFile]){
                    if(!isAppModeTest)
                        [oldFile removeFromDisk];
                    if(!isAppModeSilent)
                        printf("\n%s -> %s - OK", [[oldFile name] cStringUsingEncoding:NSUTF8StringEncoding], [[newFile name] cStringUsingEncoding:NSUTF8StringEncoding]);
                }
                else{
                    if(!isAppModeSilent)
                        printf("\n%s != %s", [[oldFile name] cStringUsingEncoding:NSUTF8StringEncoding], [[newFile name] cStringUsingEncoding:NSUTF8StringEncoding]);
                }
        
                // ++
                [YGPerformance incrementRenamedSharedCounter];
                [YGPerformance addSizeOfProcessedFile:newFile.size];
            }
            else{
                if(!isAppModeSilent)
                    printf("\n%s - skip rename, target file '%s' exists on disk", [[oldFile name] cStringUsingEncoding:NSUTF8StringEncoding], [[newFile name] cStringUsingEncoding:NSUTF8StringEncoding]);
            }
        }
    }
    @catch(NSException *ex){
        printf("\nException in -[YGFile timeStamp]. Exception: %s", [[ex description] cStringUsingEncoding:NSUTF8StringEncoding]);
        @throw;
    }
}

@end
