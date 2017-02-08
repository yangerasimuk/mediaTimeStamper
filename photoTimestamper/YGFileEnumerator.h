//
//  YGFileEnumerator.h
//  photoTimestamper
//
//  Created by Ян on 27/01/2017.
//  Copyright © 2017 Yan Gerasimuk. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "YGFile.h"
#import "YGFileTuple.h"

@interface YGFileEnumerator : NSObject

// Enumerate files in current directory and sort need to process files
+(NSArray <YGFile *>*)enumerateCurDir;

// Generate tuple, type stored info about general, base name and array with base and depend files, for example, IMG_4975.JPG and IMG_4975.AAE
+(NSArray <YGFileTuple *>*)generateFileTuples:(NSArray <YGFile *>*)files;

@end
