//
//  YGFileRenamer.h
//  photoTimestamper
//
//  Created by Ян on 27/01/2017.
//  Copyright © 2017 Yan Gerasimuk. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "YGFile.h"

@interface YGFileRenamer : NSObject

+(BOOL) copyFileFrom:(YGFile *)srcFile to:(YGFile *)dstFile;
+(BOOL) removeFile:(YGFile *)file;

@end
