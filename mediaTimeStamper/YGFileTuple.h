//
//  YGFileTuple.h
//  photoTimestamper
//
//  Created by Ян on 31/01/2017.
//  Copyright © 2017 Yan Gerasimuk. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "YGFile.h"

@interface YGFileTuple : NSObject

@property NSString *baseName;

// Main init
-(YGFileTuple *)initWithName:(NSString *)name andItems:(NSArray *)items;

// Init new tuple, with default items == nil
-(YGFileTuple *)initWithName:(NSString *)name;

// Add new file to existing tuple
-(void)addFile:(YGFile *)file;

// Rename all files in tuple with timestamped base name
-(void)timeStamp;

@end
