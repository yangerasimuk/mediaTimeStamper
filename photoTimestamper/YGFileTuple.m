//
//  YGFileTuple.m
//  photoTimestamper
//
//  Created by Ян on 31/01/2017.
//  Copyright © 2017 Yan Gerasimuk. All rights reserved.
//

#import "YGFileTuple.h"

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

-(BOOL)timeStamp{
#ifdef FUNC_DEBUG
#undef FUNC_DEBUG
#endif
    
#ifdef FUNC_DEBUG
    printf("\n-[YGFileTuple timeStamp]...");
    printf("\n%s", [[self info] cStringUsingEncoding:NSUTF8StringEncoding]);
#endif
    
    extern BOOL isAppModeSilent;
    
    BOOL resultFunc = NO;
    NSString *newBaseName = @"";
    
    // find main file
    for(YGFile *f in files){
        if(f.type == YGFileTypePhoto){
#ifdef FUNC_DEBUG
            printf("\n\t%s - base/main file", [f.name cStringUsingEncoding:NSUTF8StringEncoding]);
#endif
            if([f isEXIFAvailible]){
                newBaseName = [NSString stringWithFormat:@"%@", [f makeTimestampName]];
                
            }
            else{
                // get dateTime from file attributes
#ifdef FUNC_DEBUG
                printf("\n%s -> skip, because EXIF meta-data unavailible", [[f name] cStringUsingEncoding:NSUTF8StringEncoding]);
#endif
            }
            break;
        }
    }
#ifdef FUNC_DEBUG
    printf("\n\tbase name %s -> %s", [self.baseName cStringUsingEncoding:NSUTF8StringEncoding], [newBaseName cStringUsingEncoding:NSUTF8StringEncoding]);
#endif
    if([newBaseName compare:@""] == NSOrderedSame && newBaseName == nil){
        return NO;
    }

    for (YGFile *f in files){
        NSString *oldBaseName = [NSString stringWithFormat:@"%@", f.baseName];
        NSString *newName = [f.name stringByReplacingOccurrencesOfString:oldBaseName withString:newBaseName];
        
        YGFile *newFile = [[YGFile alloc] initWithName:newName];
        
        if(!newFile.isExistOnDisk){
            [f copyToFile:newFile];
            if([newFile isTheSame:f]){
                [f removeFromDisk];
                if(!isAppModeSilent)
                    printf("\n%s -> %s - OK", [[f name] cStringUsingEncoding:NSUTF8StringEncoding], [[newFile name] cStringUsingEncoding:NSUTF8StringEncoding]);
            }
            else{
                if(!isAppModeSilent)
                    printf("\n%s != %s", [[f name] cStringUsingEncoding:NSUTF8StringEncoding], [[newFile name] cStringUsingEncoding:NSUTF8StringEncoding]);
            }
        }
        else{
            if(!isAppModeSilent)
                printf("\n%s - skip rename, because target file - '%s' exist on disk", [[f name] cStringUsingEncoding:NSUTF8StringEncoding], [[newFile name] cStringUsingEncoding:NSUTF8StringEncoding]);
        }
        
     
    }
    return YES;
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
