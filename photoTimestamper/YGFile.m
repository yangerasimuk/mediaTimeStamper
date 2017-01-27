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
#define kVideoExtensions @[@"mov",@"mpeg"]

// Permissible extension for files depend to photo files
#define kDependPhotoExtensions @[@"AAE"]

@interface YGFile()
// Define file for this project: photo, file depends from photo (ex: .AAE), video and others
-(YGFileType) defineFileType:(NSString *)extension;

// Define type of file name: raw (from camera) or timestamped (for example: '2017-01-27 21-26-51, IMG_0130.jpg')
-(YGFileNameType) defineFileNameType:(NSString *)filename;

-(NSString *) nameOfFileType;
-(NSString *) nameOfFileNameType;


@end

@implementation YGFile

@synthesize URL, type, nameType, isExistOnDisk;

// Init object by filename in current dir
-(YGFile *)initWithFileName:(NSString *)filename{
    return [self initWithFileName:filename andDir:nil];
}

// Init object by filename in specific dir
-(YGFile *)initWithFileName:(NSString *)filename andDir:(NSString *)filepath{
    if([super init]){
        //if(filepath == nil || [filepath compare:@""] == NSOrderedSame){
        if([dir isEqualTo:nil] || dir == nil || [dir compare:@""] == NSOrderedSame){
            NSFileManager *fm = [NSFileManager defaultManager];
            self->dir = [fm currentDirectoryPath];
        }
        else{
            self->dir = [filepath copy];
        }
        self->fileName = [filename copy];
        self->fileOnlyName = [self->fileName stringByDeletingPathExtension];
        self->fileExtension = [filename pathExtension];
        self->fullName = [NSString stringWithFormat:@"%@/%@", self->dir, self->fileName];
        
        //self->fileURL = [NSURL fileURLWithPath:self->fullName];
        URL = [NSURL fileURLWithPath:self->fullName];
        //NSLog(@"URL: %@", fileURL);
        
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
    NSFileManager *fm = [NSFileManager defaultManager];
    
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
    else if(type == YGFileTypePhotoNone)
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
    
    if ([regex numberOfMatchesInString:self->fileName options:matchingOptions range:NSMakeRange(0, [self->fileName length])] >= 1)
        resultNameType = YGFileNameTypeWithTimeStamp;
    
    nameType = resultNameType;
}


-(void) defineFileType{
    
    YGFileType resultType = YGFileTypePhotoNone;
    NSArray *photoExtensions = kPhotoExtensions;
    NSArray *videoExtensions = kVideoExtensions;
    NSArray *dependPhotoExtensions = kDependPhotoExtensions;
    
    if([photoExtensions indexOfObject:fileExtension] != NSNotFound){
        resultType = YGFileTypePhoto;

    }
    else if([videoExtensions indexOfObject:fileExtension] != NSNotFound){
        resultType = YGFileTypeVideo;

    }
    else if([dependPhotoExtensions indexOfObject:fileExtension] != NSNotFound){
        NSString *photoFileName = [NSString stringWithFormat:@"%@", fileOnlyName];
        
        for (NSString *dependExtension in dependPhotoExtensions){
            photoFileName = [NSString stringWithFormat:@"%@.%@", fileOnlyName, dependExtension];
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
        
        NSDictionary *props = (NSDictionary*) CFBridgingRelease(CGImageSourceCopyPropertiesAtIndex(source, 0, NULL)); // 2
        NSDictionary *exif = props[@"{Exif}"];
        
        NSString *dateSrcString = [NSString stringWithFormat:@"%@", exif[@"DateTimeOriginal"]];
        //NSLog(@"src string: %@", dateSrcString);
        NSDateFormatter *formatterFromSrc = [[NSDateFormatter alloc] init];
        [formatterFromSrc setDateFormat:@"yyyy:MM:dd HH:mm:ss"]; //2013:06:15 18:38:33
        
        NSDate *date = [formatterFromSrc dateFromString:dateSrcString];
        NSDateFormatter *formaterToDst = [[NSDateFormatter alloc] init];
        [formaterToDst setDateFormat:@"yyyy-MM-dd_HH-mm-ss"];
        NSString *dateDstString = [formaterToDst stringFromDate:date];
        
        resultName = [NSString stringWithFormat:@"%@_%@", dateDstString, fileName];
    }
    
    return resultName;
}


-(BOOL) isEqual:(YGFile *)otherFile{
#ifdef FUNC_DEBUG
#undef FUNC_DEBUG
#endif 
    
    BOOL resultCheck = NO;
    
    NSError *error = nil;
    NSFileManager *fm = [NSFileManager defaultManager];
    
    // проверяем системным методом
    if([fm contentsEqualAtPath:self->fullName andPath:otherFile->fullName])
        resultCheck = YES;
    
    // проверяем размер
    NSDictionary *attributes = [fm attributesOfItemAtPath:[URL path] error:&error];
    NSUInteger fileSize = [[attributes objectForKey:NSFileSize] unsignedIntegerValue];
    
    NSDictionary *attributesOther = [fm attributesOfItemAtPath:[otherFile.URL path] error:&error];
    NSUInteger fileSizeOther = [[attributesOther objectForKey:NSFileSize] unsignedIntegerValue];
    
    // check for error?
    
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
    
    for(NSObject *obj in attributes){
        NSLog(@"obj: %@ - %@", obj, [obj description]);
    }
    
    
    // проверяем CRC
    
    // what else?
    
    
    return resultCheck;
}

@end
