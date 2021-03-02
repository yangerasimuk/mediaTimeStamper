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
#define kVideoExtensions @[@"mov",@"MOV",@"mpeg",@"MPEG",@"mp4",@"MP4",@"avi",@"AVI"]

// Permissible extension for files depend to photo files
#define kDependFilesByReplacementExtensions @[@"aae",@"AAE"]

// Permissible second extension for files depend to any files
#define kDependFilesByAddingExtensions @[@"ytags",@"YTAGS", @"mar.txt"]

@interface YGFile()
// Define file for this project: photo, file depends from photo (ex: .AAE), video and others
-(void) defineFileType;

// Define type of file name: raw (from camera) or timestamped (for example: '2017-01-27 21-26-51, IMG_0130.jpg')
-(void) defineFileNameType;

// Name of file type in human style, for debug
-(NSString *) nameOfFileType;

// Name of file name type in human style, for debug
-(NSString *) nameOfFileNameType;

// Get size of file
-(NSUInteger)getSizeOfFile;

// CRC of file for checking in isEqual
-(NSUInteger) crcOfFile;
@end

@implementation YGFile

static NSUInteger count = 0;
static NSString *curDir = nil;

@synthesize name, extension, baseName, URL, type, nameType, size, isExistOnDisk;


/* 
 Main init. Init object by filename in specific dir
 */
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
            [self updateFileInfo];
        }
    }
    @catch (NSException *ex) {
        printf("\nException in -[YGFile initWithName:andDir:]. Exception: %s", [[ex description] cStringUsingEncoding:NSUTF8StringEncoding]);
        @throw;
    }
    @finally {
        return self;
    }
}


/*
 Init object by filename in current dir
 */
-(YGFile *)initWithName:(NSString *)filename{
    return [self initWithName:filename andDir:nil];
}


/*
 Update info of new created file. Flag isExistOnDisk and size of file.
 */
-(void)updateFileInfo{
    
    @try{
        // File exist on disk?
        NSFileManager *fm = [NSFileManager defaultManager];
        isExistOnDisk = [fm fileExistsAtPath:self->fullName isDirectory:nil];
        
        if(isExistOnDisk)
            size = [self getSizeOfFile];
        else
            size = 0;
        
    }
    @catch (NSException *ex) {
        printf("\nException in -[YGFile updateFileInfo]. Exception: %s", [[ex description] cStringUsingEncoding:NSUTF8StringEncoding]);
        @throw;
    }
}


/* 
 Get CRC of file
 [reserved]
 */
-(NSUInteger) crcOfFile{
    
    NSUInteger resultCRC = 0;
    
    @try{
        @throw [NSException exceptionWithName:@"-[YGFile crcOfFile]->" reason:[NSString stringWithFormat:@"Message crcOfFile is not implemented"] userInfo:nil];
        
    }
    @catch(NSException *ex){
        printf("\nException in -[YGFile crcOfFile]. Exception: %s", [[ex description] cStringUsingEncoding:NSUTF8StringEncoding]);
        @throw;
    }
    @finally{
        return resultCRC;
    }
}

/*
 Get size of file in bytes.
 */
-(NSUInteger)getSizeOfFile{

    NSUInteger resultSize = 0;
    
    @try{
        NSError *error = nil;
        NSDictionary *attributes = [[NSDictionary alloc] init];
        NSFileManager *fm = [NSFileManager defaultManager];
        attributes = [fm attributesOfItemAtPath:[self name] error:&error];
        
        if(error)
            @throw [NSException exceptionWithName:@"-[YGFile getSizeOfFile]->" reason:[NSString stringWithFormat:@"Can not get attributes of file: %@", name] userInfo:nil];
        
        if(!attributes)
            @throw [NSException exceptionWithName:@"-[YGFile getSizeOfFile]->" reason:[NSString stringWithFormat:@"File attributes is equal nil. File: %@", name] userInfo:nil];

        if(!attributes[@"NSFileSize"])
            @throw [NSException exceptionWithName:@"-[YGFile getSizeOfFile]->" reason:[NSString stringWithFormat:@"Can not get file attribute NSFileSize. File: %@", name] userInfo:nil];

            resultSize = [attributes[@"NSFileSize"] unsignedIntegerValue];
    }
    @catch(NSException *ex){
        printf("\nException in -[YGFile getSizeOfFile]. Exception: %s", [[ex description] cStringUsingEncoding:NSUTF8StringEncoding]);
        @throw;
    }
    @finally{
        return resultSize;
    }
}


/*
 Define type of file: photo, video, depend file with replaced extension, depend file with added extention and other - none processed files.
 
 Q: We have additional files by replacing extensions for photo-files, ex - IMG_0115.AAE for IMG_0115.JPG. But do we have same files for video?
 */
-(void) defineFileType{
    
    YGFileType resultType = YGFileTypeNone;
    
    @try{
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
//		Код правилно определяет спецСуффикс, но потом меняет базовое имя для вспом.файла
//		else
//		{
//			for(NSString *suffix in dependByAddingExt)
//			{
//				if([name hasSuffix:suffix])
//				{
//					NSUInteger len = [name length];
//					NSUInteger loc = len - [suffix length];
//					NSRange range = NSMakeRange(loc - 1, [suffix length] + 1); // dot included
//					NSString *leading = [name stringByReplacingCharactersInRange:range
//																	  withString:@""];
//					NSFileManager *fm = [NSFileManager defaultManager];
//					if([fm fileExistsAtPath:leading]){
//						resultType = YGFileTypeDependByAddingExt;
//					}
//				}
//			}
//		}
    }
    @catch(NSException *ex){
        printf("\nException in -[YGFile defineFileType]. Exception: %s", [[ex description] cStringUsingEncoding:NSUTF8StringEncoding]);
        @throw;
    }
    @finally{
        type = resultType;
    }
}


/*
 Define name of file type in human style. Debug only.
 */
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


/*
 Define file name type: raw, such as, IMG_0788.JPG and timestamped one - 2015-07-08_18-01-02_IMG_0788.JPG
 */
-(void) defineFileNameType{
    
    YGFileNameType resultNameType = YGFileNameTypeRaw;
    NSError *error = nil;
    NSString *pattern = @"^\\d{4}[-]\\d{2}[-]\\d{2}[_]\\d{2}[-]\\d{2}[-]\\d{2}[_].+$";
    
    @try{
        
        NSRegularExpressionOptions regexOptions = NSRegularExpressionCaseInsensitive;
        NSMatchingOptions matchingOptions = NSMatchingReportProgress;
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:regexOptions error:&error];
        
        if(error)
            @throw [NSException exceptionWithName:@"-YGFile defineFileNameType]->" reason:[NSString stringWithFormat:@"Error in creating regex object. Error: %@", [error description]] userInfo:nil];
        
        if ([regex numberOfMatchesInString:name options:matchingOptions range:NSMakeRange(0, [name length])] >= 1)
            resultNameType = YGFileNameTypeWithTimeStamp;
        
    }
    @catch(NSException *ex){
        printf("\nException in -[YGFile defineFileNameType]. Exception: %s", [[ex description] cStringUsingEncoding:NSUTF8StringEncoding]);
        @throw;
    }
    @finally{
        nameType = resultNameType;
    }
}


/*
 String with name of file name type in human style. For debug only.
 */
-(NSString *) nameOfFileNameType{
    NSString *resultName = @"";
    
    if(nameType == YGFileNameTypeRaw)
        resultName = @"File without timestamp";
    else if(nameType == YGFileNameTypeWithTimeStamp)
        resultName = @"File with timestamp";
    
    return resultName;
}


/*
 [reserved] Make timestamp name from depend file with meta info, such as, IMG_9457.JPG.ytags
 */
-(NSString *)makeTimestampNameFromYTags{

    NSString *resultName = @"";
    
    @try{
        @throw [NSException exceptionWithName:@"-[YGFile makeTimestampNameFromYTags]->" reason:@"Message is not implemented now" userInfo:nil];
        
    }
    @catch(NSException *ex){
        printf("\nException in [YGFile makeTimestampNameFromYTags]. Exception: %s", [[ex description] cStringUsingEncoding:NSUTF8StringEncoding]);
        @throw;
    }
    @finally{
        return resultName;
    }
}

// Make timestamp name from file attributes
-(NSString *)makeTimestampNameFromAttributes
{
	extern BOOL isAppModeSilent;

    NSString *resultName = nil;
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
        [formatterFrom setDateFormat:@"yyyy-MM-dd HH:mm:ss Z"]; //"2016-09-17 16:56:49 +0000"
		NSDate *creationDate = [formatterFrom dateFromString:creationDateString];
		NSDate *modificationDate = [formatterFrom dateFromString:modificationDateString];

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
	@catch(NSException *ex)
	{
		if (!isAppModeSilent)
		{
			printf("\nException in [YGFile makeTimestampNameFromAttributes]. Exception: %s",
				   [[ex description] cStringUsingEncoding:NSUTF8StringEncoding]);
			printf("\n%s - not renamed.", [name cStringUsingEncoding:NSUTF8StringEncoding]);
		}
		@throw;
	}
	@finally
	{
		return resultName;
	}
}

/*
 Checking EXIF availible in current instance.
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


/*
 Make timestamp name from EXIF. 
 Before send this message, check exist of EXIF by -[YGFile isEXIFAvailible].
 */
-(NSString *)makeTimestampNameFromEXIF{
    
    NSString *resultName = nil;
    
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
 Function like isEqual: but in this compare only content of file, NOT name. Checking is redundant, system function is enough.
 
 Attention: same by content and different by extentions files will be DIFFERENT == NO
 In real life, it is impossible, becouse files with same base name and diff extension can not same content
 for example: IMG_2015.JPG.ytags and IMG_2015.AAE and IMG_2015.JPG??? Is they have same role and content?
 
 [+] Add checking for same CRC
 */
-(BOOL) isEqual:(YGFile *)otherFile{
    
    @try{
        // Compare with nil
        if(otherFile == nil)
            return NO;
        
        // Check for same contents by system funcion
        NSError *error = nil;
        NSFileManager *fm = [NSFileManager defaultManager];
        if(![fm contentsEqualAtPath:self->fullName andPath:otherFile->fullName])
            return NO;
        
        // Check for same size
        NSDictionary *attributes = [fm attributesOfItemAtPath:[URL path] error:&error];
        NSUInteger fileSize = [[attributes objectForKey:NSFileSize] unsignedIntegerValue];
        NSDictionary *attributesOther = [fm attributesOfItemAtPath:[otherFile.URL path] error:&error];
        NSUInteger fileSizeOther = [[attributesOther objectForKey:NSFileSize] unsignedIntegerValue];
        if(fileSize != fileSizeOther)
            return NO;
        
        // Check for same CRC
        
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
 Copy current instant to new file
 */
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
        printf("\nException in -[YGFile copyToFile]. Exception: %s. File: %s", [[ex description] cStringUsingEncoding:NSUTF8StringEncoding], [name cStringUsingEncoding:NSUTF8StringEncoding]);
        @throw;
    }
}


/*
 Remove current instance from disk
 */
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
        printf("\nException in -[YGFile removeFromDisk]. Exception: %s. File: %s", [[ex description] cStringUsingEncoding:NSUTF8StringEncoding], [name cStringUsingEncoding:NSUTF8StringEncoding]);
        @throw;
    }
}


/*
 Override standart message. For debug.
 */
-(NSString *)description{
    return [NSString stringWithFormat:@"%@ - %@ - %@", fullName, [self nameOfFileType], [self nameOfFileNameType]];
}


/*
 Singleton for current directory info
 */
+(NSString *)currentDirectory{
    @synchronized (self) {
        if(!curDir){
            NSFileManager *fm = [NSFileManager defaultManager];
            curDir = [NSString stringWithFormat:@"%@", [fm currentDirectoryPath]];
        }
        return curDir;
    }
}

/*
 Singleton for photo extentions db
 */
+(NSArray <NSString *>*)photoExtensions{
    static NSArray <NSString *>*sharedInstance = nil;
    @synchronized (self) {
        if(!sharedInstance){
            sharedInstance = kPhotoExtensions;
        }
    }
    return sharedInstance;
}


/*
 Singleton for video extentions db
 */
+(NSArray <NSString *>*)videoExtensions{
    static NSArray <NSString *>*sharedInstance = nil;
    @synchronized (self) {
        if(!sharedInstance){
            sharedInstance = kVideoExtensions;
        }
    }
    return sharedInstance;
}


/*
 Singleton for depend files with adding extention
 */
+(NSArray <NSString *>*)dependFileByAddingExtensions{
    static NSArray <NSString *>*sharedInstance = nil;
    @synchronized (self) {
        if(!sharedInstance){
            sharedInstance = kDependFilesByAddingExtensions;
        }
    }
    return sharedInstance;
}


/*
 Singleton for depend files with replaced extention
 */
+(NSArray <NSString *>*)dependFileByReplacementExtensions{
    static NSArray <NSString *>*sharedInstance = nil;
    @synchronized (self) {
        if(!sharedInstance){
            sharedInstance = kDependFilesByReplacementExtensions;
        }
    }
    return sharedInstance;
}

@end
