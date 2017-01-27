//
//  YGPerformance.h
//  photoTimestamper
//
//  Created by Ян on 27/01/2017.
//  Copyright © 2017 Yan Gerasimuk. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YGPerformance : NSObject

+(NSString *)timeExecutingFrom:(NSDate *)start to:(NSDate *)finish;

@end
