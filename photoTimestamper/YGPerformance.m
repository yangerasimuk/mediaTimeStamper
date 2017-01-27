//
//  YGPerformance.m
//  photoTimestamper
//
//  Created by Ян on 27/01/2017.
//  Copyright © 2017 Yan Gerasimuk. All rights reserved.
//

#import "YGPerformance.h"

@implementation YGPerformance

/*
 
 Info: https://developer.apple.com/library/content/documentation/Cocoa/Conceptual/DatesAndTimes/Articles/dtCalendricalCalculations.html#//apple_ref/doc/uid/TP40007836-SW1
 */
+(NSString *)timeExecutingFrom:(NSDate *)start to:(NSDate *)finish{
    
    NSString *resultTime = @"";
    
    NSCalendar *gregorian = [[NSCalendar alloc]
                             initWithCalendarIdentifier:NSGregorianCalendar];
    
    NSUInteger unitFlags = NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond | NSCalendarUnitNanosecond;
    
    NSDateComponents *components = [gregorian components:unitFlags
                                                fromDate:start
                                                  toDate:finish options:0];
    NSInteger months = [components month];
    NSInteger days = [components day];
    NSInteger hours = [components hour];
    NSInteger minutes = [components minute];
    NSInteger seconds = [components second];
    NSInteger nanoseconds = [components nanosecond];
    
    resultTime = [NSString stringWithFormat:@"month: %ld, days: %ld, hours: %ld, minutes: %ld, seconds: %ld, nanoseconds: %ld", (long)months, (long)days, (long)hours, (long)minutes, (long)seconds, (long)nanoseconds];
    return resultTime;
}

@end
