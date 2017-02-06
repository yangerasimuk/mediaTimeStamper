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
#define kDependFilesByReplacementExtensions @[@"aae",@"AAE"]

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

static NSUInteger count = 0;
static NSString *curDir = nil;

@synthesize name, extension, baseName, URL, type, nameType, isExistOnDisk;

+(NSString *)currentDirectory{
    @synchronized (self) {
        if(!curDir){
            NSFileManager *fm = [NSFileManager defaultManager];
            curDir = [NSString stringWithFormat:@"%@", [fm currentDirectoryPath]];
        }
        return curDir;
    }
}

-(NSString *)description{
    return [NSString stringWithFormat:@"%@ - %@ - %@", fullName, [self nameOfFileType], [self nameOfFileNameType]];
}

// Init object by filename in current dir
-(YGFile *)initWithName:(NSString *)filename{
    return [self initWithName:filename andDir:nil];
}

/*
-(YGFile *)initWithBaseName:(NSString *)baseName andExtension:(NSString *)extension{
    NSString *filename = [NSString stringWithFormat:@"%@.%@", baseName, extension];
    return [self initWithName:filename];
}
 */

// Init object by filename in specific dir
-(YGFile *)initWithName:(NSString *)filename andDir:(NSString *)filepath{
    
    @try {
        if([super init]){
            
            if([dir isEqualTo:nil] || [dir compare:@""] == NSOrderedSame){
                dir = [YGFile currentDirectory];
                count++;
            }
            else{
                dir = [filepath copy];
            }
            
            if(!dir || [dir compare:@"(null)"] == NSOrderedSame || [dir compare:@""] == NSOrderedSame){
                @throw [NSException exceptionWithName:@"-[YTFile initWihtName:andDir:]->" reason:[NSString stringWithFormat:@"Error in -[YTFile initWihtName:andDir:]. Dir can not be nil or empty. File, name: %@, dir: %@. Count: %ld", filename, dir, (long)count] userInfo:nil];
            }
            
            name = [filename copy];
            extension = [name pathExtension];
            fullName = [NSString stringWithFormat:@"%@/%@", self->dir, name];
            URL = [NSURL fileURLWithPath:self->fullName];
            
            [self defineFileType];
            [self defineFileNameType];
            
            // Base name, IMG_0224.JPG -> IMG_0244, IMG_0225.JPG.ytags -> IMG_0225
            if(type == YGFileTypeDependByAddingExt)
                baseName = [NSString stringWithFormat:@"%@", [[name stringByDeletingPathExtension] stringByDeletingPathExtension]];
            else
                baseName = [NSString stringWithFormat:@"%@", [name stringByDeletingPathExtension]];
            
            if([baseName isEqualTo:nil] || [baseName compare:@""] == NSOrderedSame){
                @throw [NSException exceptionWithName:@"-[YGFile makeTimestampNameFromEXIF]->"
                                               reason:@"Base name can not be empty"
                                             userInfo:nil];
            }
            
            // File exist on disk?
            NSFileManager *fm = [NSFileManager defaultManager];
            isExistOnDisk = [fm fileExistsAtPath:self->fullName isDirectory:nil];
        }

    }
    @catch (NSException *ex) {
        printf("\nException in [YGFile initWithName:andDir:]. Exception: %s", [[ex description] cStringUsingEncoding:NSUTF8StringEncoding]);
        @throw;
    }
    @finally {
        return self;
    }
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

-(NSInteger)size{
    
    NSInteger resultSize = 0;
    NSError *error = nil;
    NSDictionary *attributes = [[NSDictionary alloc] init];
    NSFileManager *fm = [NSFileManager defaultManager];
    attributes = [fm attributesOfItemAtPath:[self name] error:&error];
    
    if(attributes){
        resultSize = [attributes[@"NSFileSize"] integerValue];
    }
    
    return resultSize;
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
}

-(NSString *)makeTimestampNameFromYTags{
#ifdef FUNC_DEBUG
#undef FUNC_DEBUG
#endif
    
#ifdef FUNC_DEBUG
    printf("\n-[YGFile makeTimestampNameFromYTags]...");
    printf("\n\tFor file: %s", [[self description] cStringUsingEncoding:NSUTF8StringEncoding]);
#endif
    
    NSString *resultName = @"";
    
    
    return resultName;
}


-(NSString *)makeTimestampNameFromAttributes{

    NSString *resultName = @"noName";
    NSDate *resultDate = [[NSDate alloc] init];
    NSError *error = nil;
    
    @try{

        NSFileManager *fm = [NSFileManager defaultManager];
        NSDictionary *attributes = [[NSDictionary alloc] initWithDictionary:[fm attributesOfItemAtPath:name error:&error]];
        
        if([attributes isEqual:nil] || [attributes count] == 0 || error != nil){
            @throw [NSException exceptionWithName:@"-[YGFile makeTimestampNameFromAttributes]->"
                                           reason:@"Failure of reading attributes of file"
                                         userInfo:nil];
        }
        
        NSString *creationDateString = [NSString stringWithFormat:@"%@", attributes[@"NSFileCreationDate"]];
        NSString *modificationDateString = [NSString stringWithFormat:@"%@", attributes[@"NSFileModificationDate"]];
        
        NSDateFormatter *formatterFrom = [[NSDateFormatter alloc] init];
        [formatterFrom setDateFormat:@"yyyy-MM-dd HH:mm:ss +zzzz"]; //"2016-09-17 16:56:49 +0000"
        NSDate *creationDate = [[NSDate alloc] init];
        creationDate = [formatterFrom dateFromString:creationDateString];
        NSDate *modificationDate = [[NSDate alloc] init];
        modificationDate = [formatterFrom dateFromString:modificationDateString];
        
        if(creationDate == nil || modificationDate == nil){
            @throw [NSException exceptionWithName:@"-[YGFile makeTimestampNameFromAttributes]->"
                                           reason:@"Error in format from NSString to NSDate"
                                         userInfo:nil];
        }
        
        // what about @"2000-01-01 03:00:00 +3000"
        NSDate *defaultDate = [[NSDate alloc] init];
        defaultDate = [formatterFrom dateFromString:@"2000-01-01 00:00:00 +0000"];
        
        // logic
        if(([creationDate compare:modificationDate] == NSOrderedAscending)
           && ([creationDateString compare:@"2000-01-01 00:00:00 +0000"] != NSOrderedSame)
           && ([creationDate compare:defaultDate] != NSOrderedSame)
           && (creationDate != nil)){
            resultDate = creationDate;
        }
        else if([creationDate compare:modificationDate] == NSOrderedDescending
                || ([creationDateString compare:@"2000-01-01 00:00:00 +0000"] == NSOrderedSame)
                || ([creationDate compare:defaultDate] == NSOrderedSame)){
            resultDate = modificationDate;
        }
        else{
            resultDate = creationDate;
        }
        
        NSDateFormatter *formatterTo = [[NSDateFormatter alloc] init];
        [formatterTo setDateFormat:@"yyyy-MM-dd_HH-mm-ss"];
        resultName = [formatterTo stringFromDate:resultDate];
        resultName = [NSString stringWithFormat:@"%@_%@", resultName, baseName];
        
        if([resultName isEqualTo:nil] || [resultName compare:@""] == NSOrderedSame || [resultName length] < 20){
            @throw [NSException exceptionWithName:@"-[YGFile makeTimestampNameFromAttributes]->"
                                           reason:@"Can not make result name with timestamp and base name of file"
                                         userInfo:nil];
        }
        
    }
    @catch(NSException *ex){
        printf("\nException in [YGFile makeTimestampNameFromAttributes]. Exception: %s", [[ex description] cStringUsingEncoding:NSUTF8StringEncoding]);
        @throw;
    }
    @finally{
        return resultName;
    }
}


-(NSString *)makeTimestampNameFromEXIF{
    
    NSString *resultName = @"";
    
    @try{
        CGImageSourceRef source = CGImageSourceCreateWithURL((CFURLRef)URL, NULL);
        if (source){
            
            NSDictionary *props = (NSDictionary*) CFBridgingRelease(CGImageSourceCopyPropertiesAtIndex(source, 0, NULL));
            
            // Free Core Foundation obj
            CFRelease(source);
            
            NSDictionary *exif = props[@"{Exif}"];
            
            if(exif == nil || [exif count] == 0){
                @throw [NSException exceptionWithName:@"-[YGFile makeTimestampNameFromEXIF]->"
                                               reason:@"Failure of reading EXIF dictionary from image"
                                             userInfo:nil];
            }
            
            NSString *dateSrcString = [NSString stringWithFormat:@"%@", exif[@"DateTimeOriginal"]];
            
            if([dateSrcString isEqualTo:nil] || [dateSrcString compare:@""] == NSOrderedSame){
                @throw [NSException exceptionWithName:@"-[YGFile makeTimestampNameFromEXIF]->"
                                               reason:@"Can not get date string from EXIF"
                                             userInfo:nil];
            }
            
            NSDateFormatter *formatterFromSrc = [[NSDateFormatter alloc] init];
            [formatterFromSrc setDateFormat:@"yyyy:MM:dd HH:mm:ss"]; //2013:06:15 18:38:33
            NSDate *date = [formatterFromSrc dateFromString:dateSrcString];
            
            NSDateFormatter *formaterToDst = [[NSDateFormatter alloc] init];
            [formaterToDst setDateFormat:@"yyyy-MM-dd_HH-mm-ss"];
            NSString *dateDstString = [formaterToDst stringFromDate:date];
            
            if([dateDstString isEqualTo:nil] || [dateDstString compare:@""] == NSOrderedSame || [dateSrcString length] != 19){
                @throw [NSException exceptionWithName:@"-[YGFile makeTimestampNameFromEXIF]->"
                                               reason:@"Can not convert source date string to result formatted date string"
                                             userInfo:nil];
            }
            
            resultName = [NSString stringWithFormat:@"%@_%@", dateDstString, baseName];
            
            if([resultName isEqualTo:nil] || [resultName compare:@""] == NSOrderedSame || [resultName length] < 20){
                @throw [NSException exceptionWithName:@"-[YGFile makeTimestampNameFromEXIF]->"
                                               reason:@"Can not make result name with timestamp and base name of file"
                                             userInfo:nil];
            }
            
        }
        else{
            @throw [NSException exceptionWithName:@"-[YGFile makeTimestampNameFromEXIF]->"
                                           reason:@"Can not get image source"
                                         userInfo:nil];
        }
    }
    @catch(NSException *ex){
        printf("\nException in [YGFile makeTimestampNameFromEXIF]. Exception: %s", [[ex description] cStringUsingEncoding:NSUTF8StringEncoding]);
        @throw;
    }
    @finally{
        return resultName;
    }
}

/*
 Function like isEqual: but in this compare only content of file, NOT name
 
 Attention: same by content and different by extentions files will be DIFFERENT == NO
 In real life, it is impossible, becouse files with same base name and diff extension can not same content
 for example: IMG_2015.JPG.ytags and IMG_2015.AAE and IMG_2015.JPG??? Is they have same role and content?
 */
-(BOOL) isEqual:(YGFile *)otherFile{
    
    @try{
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
        
        // Crutch
        if([self.extension compare:otherFile.extension] != NSOrderedSame)
            return NO;
        
        return YES;
        
    }
    @catch(NSException *ex){
        printf("\nException in -[YGFile isEqual:]. Exception: %s", [[ex description] cStringUsingEncoding:NSUTF8StringEncoding]);
        @throw;
    }
}


/*
 Info: https://en.wikipedia.org/wiki/Exif
 */
-(BOOL)isEXIFAvailible{
    
    if(type != YGFileTypePhoto)
        return NO;
    
    @try{
        CGImageSourceRef source = CGImageSourceCreateWithURL((CFURLRef)URL, NULL);
        if (source){
            
            NSDictionary *props = (NSDictionary*) CFBridgingRelease(CGImageSourceCopyPropertiesAtIndex(source, 0, NULL));
            
            // Free Core Foundation obj
            CFRelease(source);
            
            NSDictionary *exif = props[@"{Exif}"];
            
            // Why isn't work?
            if(props == nil || [props count] == 0 || exif == nil || [exif count] == 0)
                return NO;
            
            if([exif[@"DateTimeOriginal"] compare:@"(null)"] == NSOrderedSame)
                return NO;
            
            NSString *dateSrcString = [NSString stringWithFormat:@"%@", exif[@"DateTimeOriginal"]];
            NSDateFormatter *formatterFromSrc = [[NSDateFormatter alloc] init];
            [formatterFromSrc setDateFormat:@"yyyy:MM:dd HH:mm:ss"]; //2013:06:15 18:38:33
            
            NSDate *date = [formatterFromSrc dateFromString:dateSrcString];
            NSDateFormatter *formaterToDst = [[NSDateFormatter alloc] init];
            [formaterToDst setDateFormat:@"yyyy-MM-dd_HH-mm-ss"];
            NSString *dateDstString = [formaterToDst stringFromDate:date];
            
            if(dateDstString
               && [dateDstString compare:@"(null)"] != NSOrderedSame
               && [dateDstString length] == 19)
                return YES;
        }
        
    }
    @catch(NSException *ex){
        printf("\nException in -[YGFile isEXIFAvailible]. Exception: %s", [[ex description] cStringUsingEncoding:NSUTF8StringEncoding]);
        @throw;
    }
}


-(void)copyToFile:(YGFile *)newFile{
    
    extern BOOL isAppModeSilent;
    
    NSError *error = nil;
    
    @try{
        NSFileManager *fm = [NSFileManager defaultManager];
        
        if(![fm copyItemAtURL:URL toURL:newFile.URL error:&error])
            @throw [NSException exceptionWithName:@"-[YGFile copyToFile]->"
                                           reason:[NSString stringWithFormat:@"+[NSFileManager copyItemAtURL:toURL:error:] return NO. Error: %@. File: %@", [error description], name]
                                         userInfo:nil];
    }
    @catch(NSException *ex){
        printf("\nException in [YGFile copyToFile]. Exception: %s. File: %s", [[ex description] cStringUsingEncoding:NSUTF8StringEncoding], [name cStringUsingEncoding:NSUTF8StringEncoding]);
        @throw;
    }
}

-(void) removeFromDisk{
    
    extern BOOL isAppModeSilent;
    
    NSError *error = nil;
    
    @try{
        NSFileManager *fm = [NSFileManager defaultManager];
        
        if(![fm removeItemAtURL:URL error:&error]){
            if(!isAppModeSilent)
                printf("\n%s - can not remove old file", [name cStringUsingEncoding:NSUTF8StringEncoding]);

            @throw [NSException exceptionWithName:@"-[YGFile removeFromDisk]->"
                                               reason:[NSString stringWithFormat:@"Error in removing file. Error: %@", [error description]]
                                             userInfo:nil];
        }
        else{
            if(!isAppModeSilent)
                printf("\n%s - removed from disk", [name cStringUsingEncoding:NSUTF8StringEncoding]);
        }
    }
    @catch(NSException *ex){
        printf("\nException in [YGFile removeFromDisk]. Exception: %s", [[ex description] cStringUsingEncoding:NSUTF8StringEncoding]);
        @throw;
    }
}

@end
