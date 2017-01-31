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

// Types of filename raw (without processing) and name with timestamp
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
@property BOOL isExistOnDisk;

// Init object by filename in current dir
-(YGFile *)initWithName:(NSString *)filename;

// Init object by filename in specific dir
-(YGFile *)initWithName:(NSString *)filename andDir:(NSString *)filepath;

//
-(YGFile *)initWithBaseName:(NSString *)baseName andExtension:(NSString *)extension;

//
-(BOOL) copyToFile:(YGFile *)targetFile;

//
-(BOOL) removeFromDisk;

//
-(NSString *)fileInfo;

//
-(NSUInteger) sizeOfFileInBytes;

//
-(NSUInteger) crcOfFile;

//
-(NSString *)makeTimestampName;

//
-(BOOL) isEqual:(YGFile *)otherFile;

-(BOOL) isTheSame:(YGFile *)otherFile;

// checking for EXIF info availible
-(BOOL)isEXIFAvailible;

+(NSArray <NSString *>*)photoExtensions;
+(NSArray <NSString *>*)videoExtensions;
+(NSArray <NSString *>*)dependFileByAddingExtensions;
+(NSArray <NSString *>*)dependFileByReplacementExtensions;

@end
