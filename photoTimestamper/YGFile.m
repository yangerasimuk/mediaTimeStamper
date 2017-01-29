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
#define kDependPhotoExtensions @[@"AAE"]

@interface YGFile()
// Define file for this project: photo, file depends from photo (ex: .AAE), video and others
-(void) defineFileType;

// Define type of file name: raw (from camera) or timestamped (for example: '2017-01-27 21-26-51, IMG_0130.jpg')
-(void) defineFileNameType;

-(NSString *) nameOfFileType;
-(NSString *) nameOfFileNameType;
@end

@implementation YGFile

@synthesize name, URL, type, nameType, isExistOnDisk;

-(NSString *)description{
    return [NSString stringWithFormat:@"%@ - %@ - %@", fullName, [self nameOfFileType], [self nameOfFileNameType]];
}

// Init object by filename in current dir
-(YGFile *)initWithFileName:(NSString *)filename{
    return [self initWithFileName:filename andDir:nil];
}

// Init object by filename in specific dir
-(YGFile *)initWithFileName:(NSString *)filename andDir:(NSString *)filepath{
    if([super init]){

        if([dir isEqualTo:nil] || [dir compare:@""] == NSOrderedSame){
            NSFileManager *fm = [NSFileManager defaultManager];
            self->dir = [fm currentDirectoryPath];
        }
        else{
            self->dir = [filepath copy];
        }

        name = [filename copy];
        self->nameWithoutExtension = [name stringByDeletingPathExtension];
        self->extension = [name pathExtension];
        self->fullName = [NSString stringWithFormat:@"%@/%@", self->dir, name];
        URL = [NSURL fileURLWithPath:self->fullName];
        
        [self defineFileType];
        [self defineFileNameType];
        
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
    else if(type == YGFileTypePhotoDepend)
        resultName = @"File depend from photo file";
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


-(void) defineFileType{
    
    YGFileType resultType = YGFileTypeNone;
    NSArray *photoExtensions = kPhotoExtensions;
    NSArray *videoExtensions = kVideoExtensions;
    NSArray *dependPhotoExtensions = kDependPhotoExtensions;
    
    if([photoExtensions indexOfObject:extension] != NSNotFound){
        resultType = YGFileTypePhoto;

    }
    else if([videoExtensions indexOfObject:extension] != NSNotFound){
        resultType = YGFileTypeVideo;

    }
    else if([dependPhotoExtensions indexOfObject:extension] != NSNotFound){
        NSString *photoFileName = [NSString stringWithFormat:@"%@", nameWithoutExtension];
        
        for (NSString *dependExtension in dependPhotoExtensions){
            photoFileName = [NSString stringWithFormat:@"%@.%@", nameWithoutExtension, dependExtension];
            NSFileManager *fm = [NSFileManager defaultManager];
            if([fm fileExistsAtPath:photoFileName]){
                resultType = YGFileTypePhotoDepend;
            }
        }
        
    }
    
    type = resultType;
}

-(NSString *)makeTimestampName{
    
    NSString *resultName = @"";
    
    CGImageSourceRef source = CGImageSourceCreateWithURL((CFURLRef)URL, NULL); // 1
    if (source){
        
        NSDictionary *props = (NSDictionary*) CFBridgingRelease(CGImageSourceCopyPropertiesAtIndex(source, 0, NULL));
        NSDictionary *exif = props[@"{Exif}"];
        
        NSString *dateSrcString = [NSString stringWithFormat:@"%@", exif[@"DateTimeOriginal"]];
        NSDateFormatter *formatterFromSrc = [[NSDateFormatter alloc] init];
        [formatterFromSrc setDateFormat:@"yyyy:MM:dd HH:mm:ss"]; //2013:06:15 18:38:33
        
        NSDate *date = [formatterFromSrc dateFromString:dateSrcString];
        NSDateFormatter *formaterToDst = [[NSDateFormatter alloc] init];
        [formaterToDst setDateFormat:@"yyyy-MM-dd_HH-mm-ss"];
        NSString *dateDstString = [formaterToDst stringFromDate:date];
        
        resultName = [NSString stringWithFormat:@"%@_%@", dateDstString, name];
        
    }
    
    return resultName;
}

-(NSString *)makeTimestampNameFromMainFile{
#ifdef FUNC_DEBUG
#undef FUNC_DEBUG
#endif
    
    NSString *resultName = @"";
    NSString *baseName = [[NSString stringWithFormat:@"%@", name] stringByDeletingPathExtension];
    NSArray *photoExtensions = kPhotoExtensions;
        
    for(NSString *ext in photoExtensions){
        NSString *mainFileName = [NSString stringWithFormat:@"%@.%@", baseName, ext];
#ifdef FUNC_DEBUG
        printf("\nTrying photo name: %s", [mainFileName cStringUsingEncoding:NSUTF8StringEncoding]);
#endif
        YGFile *file = [[YGFile alloc] initWithFileName:mainFileName];
        if(file.isExistOnDisk){
            resultName = [NSString stringWithFormat:@"%@.%@", [[file makeTimestampName] stringByDeletingPathExtension], extension];
            break;
        }
    }
#ifdef FUNC_DEBUG
    printf("\nResult name from photo file: %s", [resultName cStringUsingEncoding:NSUTF8StringEncoding]);
#endif
    return resultName;
}


-(BOOL) isEqual:(YGFile *)otherFile{
#ifdef FUNC_DEBUG
#undef FUNC_DEBUG
#endif 
    
    BOOL resultCheck = NO;
    
    NSError *error = nil;
    NSFileManager *fm = [NSFileManager defaultManager];
    
    // check for same contents by system funcion
    if([fm contentsEqualAtPath:self->fullName andPath:otherFile->fullName])
        resultCheck = YES;
    
    // check for same size
    NSDictionary *attributes = [fm attributesOfItemAtPath:[URL path] error:&error];
    NSUInteger fileSize = [[attributes objectForKey:NSFileSize] unsignedIntegerValue];
    
    NSDictionary *attributesOther = [fm attributesOfItemAtPath:[otherFile.URL path] error:&error];
    NSUInteger fileSizeOther = [[attributesOther objectForKey:NSFileSize] unsignedIntegerValue];
    
    if(fileSize == fileSizeOther){
#ifdef FUNC_DEBUG
        printf("\nFiles have same size");
#endif
        resultCheck = YES;
    }
    else{
        printf("\nError! Files have different sizes");
        resultCheck = NO;
        
    }
    
    // check for same SRS
    
    return resultCheck;
}

@end
