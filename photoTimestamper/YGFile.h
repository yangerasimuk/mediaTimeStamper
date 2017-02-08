//
//  YGFile.h
//  photoTimestamper
//
//  Created by Ян on 27/01/2017.
//  Copyright © 2017 Yan Gerasimuk. All rights reserved.
//

#import <Foundation/Foundation.h>

enum YGFileType {
    YGFileTypeNone                      = 0,
    YGFileTypePhoto                     = 1 << 0,
    YGFileTypeVideo                     = 1 << 1,
    YGFileTypeDependByReplacementExt    = 1 << 2,
    YGFileTypeDependByAddingExt         = 1 << 3
};
typedef enum YGFileType YGFileType;

// Types of filename: raw, without processing - IMG_9754.JPG, and with timestamp - 2017-01-02_18-20-56_IMG_9754.JPG
enum YGFileNameType {
    YGFileNameTypeRaw,
    YGFileNameTypeWithTimeStamp
};
typedef enum YGFileNameType YGFileNameType;

@interface YGFile : NSObject {
    NSString *dir;
    NSString *extensionSecond;
    NSString *fullName;
}

@property NSString *name;
@property NSString *baseName;
@property NSString *extension;
@property NSURL *URL;
@property YGFileType type;
@property YGFileNameType nameType;
@property NSUInteger size;
@property BOOL isExistOnDisk;

// Init object by filename in current dir
-(YGFile *)initWithName:(NSString *)filename;

// Main init object by filename in specific dir
-(YGFile *)initWithName:(NSString *)filename andDir:(NSString *)filepath;

// Checking for EXIF info availible
-(BOOL)isEXIFAvailible;

// Make timestamp name from EXIF
-(NSString *)makeTimestampNameFromEXIF;

// Make timestamp name from file attributes
-(NSString *)makeTimestampNameFromAttributes;

// [reserved] Make timestamp name from YTags file
-(NSString *)makeTimestampNameFromYTags;

// Copy current instance to target file
-(void) copyToFile:(YGFile *)targetFile;

// Remove current instance from disk
-(void) removeFromDisk;

// Update info for new copied file - flag isExistOnDisk = true and set file size
-(void) updateFileInfo;

// Is current instance equal other YGFile *file?
-(BOOL) isEqual:(YGFile *)otherFile;

// Singleton for getting current directory
+(NSString *)currentDirectory;

// Singletons for db of extensions
+(NSArray <NSString *>*)photoExtensions;
+(NSArray <NSString *>*)videoExtensions;
+(NSArray <NSString *>*)dependFileByAddingExtensions;
+(NSArray <NSString *>*)dependFileByReplacementExtensions;

@end
