//
//  YGFile.h
//  photoTimestamper
//
//  Created by Ян on 27/01/2017.
//  Copyright © 2017 Yan Gerasimuk. All rights reserved.
//

#import <Foundation/Foundation.h>

enum YGFileType {
    YGFileTypePhotoNone    = 0,
    YGFileTypePhoto        = 1 << 1,
    YGFileTypePhotoDepend  = 1 << 2,
    YGFileTypeVideo        = 1 << 3

};
typedef enum YGFileType YGFileType;

enum YGFileNameType {
    YGFileNameTypeRaw,
    YGFileNameTypeWithTimeStamp
};
typedef enum YGFileNameType YGFileNameType;

@interface YGFile : NSObject {
    NSString *dir;
    NSString *fileName;
    NSString *fileOnlyName;
    NSString *fileExtension;
    NSString *fullName;
}

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
//+(YGFile *)fileWithTimestampNameFrom:(YGFile *)file;

-(NSString *)makeTimestampName;

-(BOOL) isEqual:(YGFile *)otherFile;

@end
