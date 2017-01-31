//
//  YGFileTuple.h
//  photoTimestamper
//
//  Created by Ян on 31/01/2017.
//  Copyright © 2017 Yan Gerasimuk. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "YGFile.h"

@interface YGFileTuple : NSObject {
    NSMutableArray <YGFile *>*files;
}

@property NSString *baseName;

//
-(YGFileTuple *)initWithName:(NSString *)name;

//
-(YGFileTuple *)initWithName:(NSString *)name andItems:(NSArray *)items;

//
-(BOOL)addFile:(YGFile *)file;

//
-(BOOL)timeStamp;

//
-(NSString *)info;

@end
