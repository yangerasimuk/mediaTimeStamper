//
//  YGFile.m
//  photoTimestamper
//
//  Created by Ян on 27/01/2017.
//  Copyright © 2017 Yan Gerasimuk. All rights reserved.
//

#import "YGFile.h"

// Permissible extensions for photo files
#define kPhotoExtensions @[@"jpeg",@"JPEG",@"jpg",@"JPG",@"png",@"PNG",@"gif",@"GIF"]

// Permissible extension for video files
#define kVideoExtensions @[@"mov",@"MOV",@"mpeg",@"MPEG",@"mp4",@"MP4"]

// Permissible extension for files depend to photo files
#define kDependFilesByReplacementExtensions @[@"AAE"]

// Permissible second extension for files depend to any files
#define kDependFilesByAddingExtensions @[@"ytags",@"YTAGS"]

@interface YGFile()
// Define file for this project: photo, file depends from photo (ex: .AAE), video and others
-(void) defineFileType;

// Define type of file name: raw (from camera) or timestamped (for example: '2017-01-27 21-26-51, IMG_0130.jpg')
-(void) defineFileNameType;

-(NSString *) nameOfFileType;
-(NSString *) nameOfFileNameType;
@end

@implementation YGFile

@synthesize name, extension, baseName, URL, type, nameType, isExistOnDisk;

-(NSString *)description{
    return [NSString stringWithFormat:@"%@ - %@ - %@", fullName, [self nameOfFileType], [self nameOfFileNameType]];
}

// Init object by filename in current dir
-(YGFile *)initWithName:(NSString *)filename{
    return [self initWithName:filename andDir:nil];
}

-(YGFile *)initWithBaseName:(NSString *)baseName andExtension:(NSString *)extension{
    NSString *filename = [NSString stringWithFormat:@"%@.%@", baseName, extension];
    return [self initWithName:filename];
}

// Init object by filename in specific dir
-(YGFile *)initWithName:(NSString *)filename andDir:(NSString *)filepath{
    if([super init]){

        if([dir isEqualTo:nil] || [dir compare:@""] == NSOrderedSame){
            NSFileManager *fm = [NSFileManager defaultManager];
            self->dir = [fm currentDirectoryPath];
        }
        else{
            self->dir = [filepath copy];
        }

        name = [filename copy];
        //self->nameWithoutExtension = [name stringByDeletingPathExtension];
        extension = [name pathExtension];
        self->fullName = [NSString stringWithFormat:@"%@/%@", self->dir, name];
        URL = [NSURL fileURLWithPath:self->fullName];
        
        [self defineFileType];
        [self defineFileNameType];
        
        // Base name, IMG_0224.JPG -> IMG_0244, IMG_0225.JPG.ytags -> IMG_0225
        if(type == YGFileTypeDependByAddingExt)
            baseName = [NSString stringWithFormat:@"%@", [[name stringByDeletingPathExtension] stringByDeletingPathExtension]];
        else
            baseName = [NSString stringWithFormat:@"%@", [name stringByDeletingPathExtension]];
        
        // File exist on disk?
        NSFileManager *fm = [NSFileManager defaultManager];
        isExistOnDisk = [fm fileExistsAtPath:self->fullName isDirectory:nil];
    }
    return self;
}

-(NSUInteger) sizeOfFileInBytes{
    NSUInteger resultSize = 0;
    
    return resultSize;
}

-(NSUInteger) crcOfFile{
    NSUInteger resultCRC = 0;
    
    return resultCRC;
}

-(NSString *)fileInfo{
    NSString *resultInfo = @"";
    
    resultInfo = [NSString stringWithFormat:@"%@ - %@", fullName, [self nameOfFileType]];
    
    return resultInfo;
}

-(NSString *) nameOfFileType{
    NSString *resultName = @"";
    
    if(type == YGFileTypePhoto)
        resultName = @"Photo file";
    else if(type == YGFileTypeDependByAddingExt)
        resultName = @"Depend file by adding new extension to target filename";
    else if(type == YGFileTypeDependByReplacementExt)
        resultName = @"Depend file by replacement extension of target filename";
    else if(type == YGFileTypeVideo)
        resultName = @"Video file";
    else if(type == YGFileTypeNone)
        resultName = @"File not processing by app";
    
    return resultName;
}

-(NSString *) nameOfFileNameType{
    NSString *resultName = @"";
    
    if(nameType == YGFileNameTypeRaw)
        resultName = @"File without timestamp";
    else if(nameType == YGFileNameTypeWithTimeStamp)
        resultName = @"File with timestamp";
    
    return resultName;
}

-(void) defineFileNameType{
    YGFileNameType resultNameType = YGFileNameTypeRaw;
    
    NSError *error = nil;
    NSString *pattern = @"^\\d{4}[-]\\d{2}[-]\\d{2}[_]\\d{2}[-]\\d{2}[-]\\d{2}[_].+$";
    NSRegularExpressionOptions regexOptions = NSRegularExpressionCaseInsensitive;
    NSMatchingOptions matchingOptions = NSMatchingReportProgress;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:regexOptions error:&error];
    
    if(error){
        NSLog(@"Cannot create regex-object, %@", [error description]);
    }
    
    if ([regex numberOfMatchesInString:name options:matchingOptions range:NSMakeRange(0, [name length])] >= 1)
        resultNameType = YGFileNameTypeWithTimeStamp;
    
    nameType = resultNameType;
}

+(NSArray <NSString *>*)photoExtensions{
    static NSArray <NSString *>*sharedInstance = nil;
    @synchronized (self) {
        if(!sharedInstance){
            sharedInstance = kPhotoExtensions;
        }
    }
    return sharedInstance;
}

+(NSArray <NSString *>*)videoExtensions{
    static NSArray <NSString *>*sharedInstance = nil;
    @synchronized (self) {
        if(!sharedInstance){
            sharedInstance = kVideoExtensions;
        }
    }
    return sharedInstance;
}

+(NSArray <NSString *>*)dependFileByAddingExtensions{
    static NSArray <NSString *>*sharedInstance = nil;
    @synchronized (self) {
        if(!sharedInstance){
            sharedInstance = kDependFilesByAddingExtensions;
        }
    }
    return sharedInstance;
}

+(NSArray <NSString *>*)dependFileByReplacementExtensions{
    static NSArray <NSString *>*sharedInstance = nil;
    @synchronized (self) {
        if(!sharedInstance){
            sharedInstance = kDependFilesByReplacementExtensions;
        }
    }
    return sharedInstance;
}

/*
 
 Q: We have additional files by replacing extensions for photo-files, ex - IMG_0115.AAE for IMG_0115.JPG. But do we have same files for video?
 */
-(void) defineFileType{
#ifdef FUNC_DEBUG
#undef FUNC_DEBUG
#endif
    
#ifdef FUNC_DEBUG
    printf("\n-[YGFile defineFileType]...");
#endif

    YGFileType resultType = YGFileTypeNone;
    NSArray *photoExtensions = [YGFile photoExtensions];
    NSArray *videoExtensions = [YGFile videoExtensions];
    NSArray *dependByReplacementExt = [YGFile dependFileByReplacementExtensions];
    NSArray *dependByAddingExt = [YGFile dependFileByAddingExtensions];
    
    if([photoExtensions indexOfObject:extension] != NSNotFound){
        resultType = YGFileTypePhoto;
    }
    else if([videoExtensions indexOfObject:extension] != NSNotFound){
        resultType = YGFileTypeVideo;
    }
    else if([dependByReplacementExt indexOfObject:extension] != NSNotFound){
        NSString *photoFileName = @"";
        NSString *onlyName = [NSString stringWithFormat:@"%@", [name stringByDeletingPathExtension]];
        
        for (NSString *photoExtension in photoExtensions){
            photoFileName = [NSString stringWithFormat:@"%@.%@", onlyName, photoExtension];
            NSFileManager *fm = [NSFileManager defaultManager];
            if([fm fileExistsAtPath:photoFileName]){
                resultType = YGFileTypeDependByReplacementExt;
                break;
            }
        }
    }
    else if([dependByAddingExt indexOfObject:extension] != NSNotFound){
        NSString *leadingFileName = [NSString stringWithFormat:@"%@", [name stringByDeletingPathExtension]];
        NSFileManager *fm = [NSFileManager defaultManager];
        if([fm fileExistsAtPath:leadingFileName]){
            resultType = YGFileTypeDependByAddingExt;
        }
    }
    
    type = resultType;
#ifdef FUNC_DEBUG
    printf("\n\t%s - %s", [name cStringUsingEncoding:NSUTF8StringEncoding], [[self nameOfFileType] cStringUsingEncoding:NSUTF8StringEncoding]);
#endif
}

-(NSString *)makeTimestampName{
#ifdef FUNC_DEBUG
#undef FUNC_DEBUG
#endif
    
#ifdef FUNC_DEBUG
    printf("\n-[YGFile makeTimestampName:]...");
    printf("\n\tFor file: %s", [[self description] cStringUsingEncoding:NSUTF8StringEncoding]);
#endif
    
    NSString *resultName = @"";
    
    CGImageSourceRef source = CGImageSourceCreateWithURL((CFURLRef)URL, NULL); // 1
    if (source){
        
        NSDictionary *props = (NSDictionary*) CFBridgingRelease(CGImageSourceCopyPropertiesAtIndex(source, 0, NULL));
        NSDictionary *exif = props[@"{Exif}"];
        
        NSString *dateSrcString = [NSString stringWithFormat:@"%@", exif[@"DateTimeOriginal"]];
        NSDateFormatter *formatterFromSrc = [[NSDateFormatter alloc] init];
        [formatterFromSrc setDateFormat:@"yyyy:MM:dd HH:mm:ss"]; //2013:06:15 18:38:33
        NSDate *date = [formatterFromSrc dateFromString:dateSrcString];
        
#ifdef FUNC_DEBUG
        printf("\n\tSrc string: %s -> %@", [dateSrcString cStringUsingEncoding:NSUTF8StringEncoding], date);
#endif
        
        NSDateFormatter *formaterToDst = [[NSDateFormatter alloc] init];
        [formaterToDst setDateFormat:@"yyyy-MM-dd_HH-mm-ss"];
        NSString *dateDstString = [formaterToDst stringFromDate:date];

#ifdef FUNC_DEBUG
        printf("\n\tDst string: %s", [dateDstString cStringUsingEncoding:NSUTF8StringEncoding]);
#endif

        resultName = [NSString stringWithFormat:@"%@_%@", dateDstString, baseName];

#ifdef FUNC_DEBUG
        printf("\n\tResult string: %s", [resultName cStringUsingEncoding:NSUTF8StringEncoding]);
#endif

    }
    
    return resultName;
}

/*
 Function like isEqual: but in this compare only content of file, NOT name
 
 */
-(BOOL) isTheSame:(YGFile *)otherFile{
#ifdef FUNC_DEBUG
#undef FUNC_DEBUG
#endif
    
#ifdef FUNC_DEBUG
    printf("\n-[YGFile isTheSame:]...");
#endif
    
    // compare with nil
    if(otherFile == nil)
        return NO;
    
    // check for same contents by system funcion
    NSError *error = nil;
    NSFileManager *fm = [NSFileManager defaultManager];
    if(![fm contentsEqualAtPath:self->fullName andPath:otherFile->fullName])
        return NO;
    
    // check for same size
    NSDictionary *attributes = [fm attributesOfItemAtPath:[URL path] error:&error];
    NSUInteger fileSize = [[attributes objectForKey:NSFileSize] unsignedIntegerValue];
    NSDictionary *attributesOther = [fm attributesOfItemAtPath:[otherFile.URL path] error:&error];
    NSUInteger fileSizeOther = [[attributesOther objectForKey:NSFileSize] unsignedIntegerValue];
    if(fileSize != fileSizeOther)
        return NO;
    
    // check for same SRS
    
    return YES;
    
}

/*
 Attention! This function need for -[NSArray indexOfObject:]
 */
-(BOOL) isEqual:(YGFile *)otherFile{
#ifdef FUNC_DEBUG
#undef FUNC_DEBUG
#endif
    
#ifdef FUNC_DEBUG
    printf("\n-[YGFile isEqual:]...");
#endif
    
    // compare with nil
    if(otherFile == nil)
        return NO;
    
    // compare names
    if([name compare:otherFile.name] != NSOrderedSame)
        return NO;
    
    return YES;
}

/*
 Info: https://en.wikipedia.org/wiki/Exif
 */
-(BOOL)isEXIFAvailible{
#ifdef FUNC_DEBUG
#undef FUNC_DEBUG
#endif
    
#ifdef FUNC_DEBUG
    printf("\n-[YGFile isEXIFAvailible]...");
    printf("\n...%s", [name cStringUsingEncoding:NSUTF8StringEncoding]);
#endif
    
    if(type != YGFileTypePhoto)
        return NO;
    
    CGImageSourceRef source = CGImageSourceCreateWithURL((CFURLRef)URL, NULL); // 1
    if (source){
        
        NSDictionary *props = (NSDictionary*) CFBridgingRelease(CGImageSourceCopyPropertiesAtIndex(source, 0, NULL));
        
        NSDictionary *exif = props[@"{Exif}"];
        
        if(props == nil || [props count] == 0 || exif == nil || [exif count] == 0)
            return NO;
        
        NSString *dateSrcString = [NSString stringWithFormat:@"%@", exif[@"DateTimeOriginal"]];
#ifdef FUNC_DEBUG
        printf("\n\tdateSrcString: %s", [dateSrcString cStringUsingEncoding:NSUTF8StringEncoding]);
#endif
        NSDateFormatter *formatterFromSrc = [[NSDateFormatter alloc] init];
        [formatterFromSrc setDateFormat:@"yyyy:MM:dd HH:mm:ss"]; //2013:06:15 18:38:33
        
        NSDate *date = [formatterFromSrc dateFromString:dateSrcString];
        NSDateFormatter *formaterToDst = [[NSDateFormatter alloc] init];
        [formaterToDst setDateFormat:@"yyyy-MM-dd_HH-mm-ss"];
        NSString *dateDstString = [formaterToDst stringFromDate:date];
#ifdef FUNC_DEBUG
        printf("\n\tdateDstString: %s", [dateDstString cStringUsingEncoding:NSUTF8StringEncoding]);
#endif
        
        if([dateDstString length] == 19)
            return YES;
    }
    
    return NO;
}



-(BOOL)copyToFile:(YGFile *)newFile{
#ifdef FUNC_DEBUG
#undef FUNC_DEBUG
#endif
    
#ifdef FUNC_DEBUG
    printf("\n-[YGFile copyToFile:]...");
    printf("\n\tFrom: %s to: %s", [URL cStringUsingEncoding:NSUTF8StringEncoding]], [newFile.URL cStringUsingEncoding:NSUTF8StringEncoding]);
#endif
    
    BOOL resultFunc = NO;
    NSError *error = nil;
    NSFileManager *fm = [NSFileManager defaultManager];
    
    if([fm copyItemAtURL:URL toURL:newFile.URL error:&error]){
        resultFunc = YES;
    }
    else{
        printf("\nError! Can not copy file: %s to: %s", [name cStringUsingEncoding:NSUTF8StringEncoding], [newFile.name cStringUsingEncoding:NSUTF8StringEncoding]);
        if(error != nil)
            printf("\nError: %s", [[error description] cStringUsingEncoding:NSUTF8StringEncoding]);
    }
    
    return resultFunc;
}

-(BOOL) removeFromDisk{
#ifdef FUNC_DEBUG
#undef FUNC_DEBUG
#endif
    
    BOOL resultFunc = NO;
    NSError *error = nil;
    NSFileManager *fm = [NSFileManager defaultManager];
    
    if([fm removeItemAtURL:URL error:&error]){
#ifdef FUNC_DEBUG
        printf("\n%s - successfully removed from disk", [URL cStringUsingEncoding:NSUTF8StringEncoding]);
#endif
        resultFunc = YES;
    }
    else{
        printf("\nError! Can not remove old file: %s", [name cStringUsingEncoding:NSUTF8StringEncoding]);
        if(error != nil)
            printf("\nError: %s", [[error description] cStringUsingEncoding:NSUTF8StringEncoding]);
    }
    
    return resultFunc;
}

@end
