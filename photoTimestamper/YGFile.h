//
//  YGFile.h
//  photoTimestamper
//
//  Created by Ян on 27/01/2017.
//  Copyright © 2017 Yan Gerasimuk. All rights reserved.
//

#import <Foundation/Foundation.h>

enum YGFileType {
    YGFileTypeNone          = 0,
    YGFileTypePhoto         = 1 << 0,
    YGFileTypePhotoDepend   = 1 << 1,
    YGFileTypeVideo         = 1 << 2

};
typedef enum YGFileType YGFileType;

enum YGFileNameType {
    YGFileNameTypeRaw,
    YGFileNameTypeWithTimeStamp
};
typedef enum YGFileNameType YGFileNameType;

@interface YGFile : NSObject {
    NSString *dir;
    NSString *nameWithoutExtension;
    NSString *extension;
    NSString *fullName;
}

@property NSString *name;
@property NSURL *URL;
@property YGFileType type;
@property YGFileNameType nameType;
@property BOOL isExistOnDisk;


// Init object by filename in current dir
-(YGFile *)initWithFileName:(NSString *)filename;

// Init object by filename in specific dir
-(YGFile *)initWithFileName:(NSString *)filename andDir:(NSString *)filepath;

//
-(NSString *)fileInfo;

//
-(NSUInteger) sizeOfFileInBytes;

//
-(NSUInteger) crcOfFile;

//
-(NSString *)makeTimestampName;

//
-(NSString *)makeTimestampNameFromMainFile;

//
-(BOOL) isEqual:(YGFile *)otherFile;

// checking for EXIF info availible
-(BOOL)isEXIFAvailible;

@end
