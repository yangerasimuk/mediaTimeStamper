//
//  YGFileTuple.m
//  photoTimestamper
//
//  Created by Ян on 31/01/2017.
//  Copyright © 2017 Yan Gerasimuk. All rights reserved.
//

#import "YGFileTuple.h"
#import "YGPerformance.h"

//#import "globals.h"

@interface YGFileTuple()
-(NSString *)getTimestampedBaseName;

@end

@implementation YGFileTuple

@synthesize baseName;

-(NSString *)info{
    NSMutableString *result = [[NSMutableString alloc] init];

    [result appendFormat:@"Name: %@", baseName];
    [result appendFormat:@" | %ld:", [files count]];
    for(YGFile *f in files){
        [result appendFormat:@" %@", f.name];
    }
    return [result copy];
}

-(NSString *)getTimestampedBaseName{
    
    extern BOOL isAppModeSilent;
    extern BOOL isAppModeProcessFilesWithoutMeta;
    extern BOOL isAppModeTest;
    
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

-(void)timeStamp{
    
    extern BOOL isAppModeSilent;
    extern BOOL isAppModeProcessFilesWithoutMeta;
    extern BOOL isAppModeTest;
    
    NSString *lastOperationInfo = @"";
    
    @try{
        NSString *newBaseName = [self getTimestampedBaseName];
        
        for (YGFile *oldFile in files){
            NSString *oldBaseName = [NSString stringWithFormat:@"%@", oldFile.baseName];
            NSString *newName = [oldFile.name stringByReplacingOccurrencesOfString:oldBaseName withString:newBaseName];
            
            YGFile *newFile = [[YGFile alloc] initWithName:newName];
            
            lastOperationInfo = [NSString stringWithFormat:@"Old file: %@ -> new file: %@", [oldFile description], [newFile description]];
            
            if(!newFile.isExistOnDisk){
                [oldFile copyToFile:newFile];
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
                [YGPerformance addSizeOfProcessedFile:[newFile size]];
            }
            else{
                if(!isAppModeSilent)
                    printf("\n%s - skip rename, target file '%s' exists on disk", [[oldFile name] cStringUsingEncoding:NSUTF8StringEncoding], [[newFile name] cStringUsingEncoding:NSUTF8StringEncoding]);
            }
        }
    }
    @catch(NSException *ex){
        printf("\nException in [YGFile timeStamp]. Exception: %s. Last operation: %s", [[ex description] cStringUsingEncoding:NSUTF8StringEncoding], [lastOperationInfo cStringUsingEncoding:NSUTF8StringEncoding]);
        @throw;
    }
}

-(NSString *)description{
    NSMutableString *resultDesc = [[NSMutableString alloc] init];
    [resultDesc appendFormat:@"Tuple name: %@", baseName];
    
    for(YGFile *file in files){
        [resultDesc appendFormat:@"\n\tFile: %@", [file description]];
    }
    return [resultDesc copy];
}

-(YGFileTuple *)initWithName:(NSString *)name{
    return [self initWithName:name andItems:nil];
}

-(YGFileTuple *)initWithName:(NSString *)name andItems:(NSArray *)items{
#ifdef FUNC_DEBUG
#undef FUNC_DEBUG
#endif
    
#ifdef FUNC_DEBUG
    printf("\n-[YGFileTuple intiWithName: andItems:]...");
    printf("\n\tBase name: %s", [name cStringUsingEncoding:NSUTF8StringEncoding]);
#endif

    if([super init]){
        baseName = name;
        files = [[NSMutableArray alloc] init];
        if(items){
            if([items[0] isMemberOfClass:[YGFile class]])
                files = [items mutableCopy];
            else if([items[0] isMemberOfClass:[NSString class]]){
                for(NSString *newName in items){
                    YGFile *newFile = [[YGFile alloc] initWithName:newName];
                    [files addObject:newFile];
                }
            }
        }
    }
    return self;
}

-(BOOL)addFile:(YGFile *)file{
#ifdef FUNC_DEBUG
#undef FUNC_DEBUG
#endif
    
#ifdef FUNC_DEBUG
    printf("\n-[YGFileTuple intiWithName: andItems:]...");
#endif
    if(!files)
        files = [[NSMutableArray alloc] init];
    if([files indexOfObject:file] == NSNotFound){
        [files addObject:file];
#ifdef FUNC_DEBUG
        printf("\nFile added to array");
#endif
        return YES;

    }
    else{
#ifdef FUNC_DEBUG
        printf("\nFile exist in array yet, adding cancel");
#endif
        return NO;

    }
}

@end
