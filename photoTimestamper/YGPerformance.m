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
    
    NSMutableString *resultTime = [[NSMutableString alloc] init];
    
    NSCalendar *gregorian = [[NSCalendar alloc]
                             initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    
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
    
    if(months > 0)
        [resultTime appendString:[NSString stringWithFormat:@"%ld months", months]];
    if(days > 0){
        if([resultTime compare:@""] != NSOrderedSame)
            [resultTime appendString:@", "];
        [resultTime appendString:[NSString stringWithFormat:@"%ld days", days]];
    }
    if(hours > 0){
        if([resultTime compare:@""] != NSOrderedSame)
            [resultTime appendString:@", "];
        [resultTime appendString:[NSString stringWithFormat:@"%ld hours", hours]];
    }
    if(minutes > 0){
        if([resultTime compare:@""] != NSOrderedSame)
            [resultTime appendString:@", "];
        [resultTime appendString:[NSString stringWithFormat:@"%ld minutes", minutes]];
    }
    if(seconds > 0){
        if([resultTime compare:@""] != NSOrderedSame)
            [resultTime appendString:@", "];
        [resultTime appendString:[NSString stringWithFormat:@"%ld seconds", seconds]];
    }
    if(nanoseconds > 0){
        if([resultTime compare:@""] != NSOrderedSame)
            [resultTime appendString:@", "];
        [resultTime appendString:[NSString stringWithFormat:@"%ld nanoseconds", nanoseconds]];
    }
    
    return [resultTime copy];
}

@end
