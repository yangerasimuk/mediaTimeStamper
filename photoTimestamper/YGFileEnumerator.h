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

//
+(NSArray <YGFile *>*)enumerateCurDir;

//
+(NSArray <YGFileTuple *>*)generateFileTuples:(NSArray <YGFile *>*)files;

@end
