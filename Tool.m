//
//  Tool.m
//  BabywandDevice1
//
//  Created by hu on 15/8/10.
//  Copyright (c) 2015年 huweihong. All rights reserved.
//

#import "Tool.h"

@implementation Tool

//时间戳转换成时间
+(NSString *)timeToString:(NSString *)timeStamp andFormat:(NSString *)foramt
{
    
    NSTimeInterval tempTime = [timeStamp intValue];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    NSDate *confromTimesp = [NSDate dateWithTimeIntervalSince1970:tempTime];
    [formatter setDateFormat:foramt];
    NSString *confromTimespStr = [formatter stringFromDate:confromTimesp];
    return confromTimespStr;
}
//string类型数据转换层NSDate类型
+ (NSData*)dataForHexString:(NSString*)hexString
{
    if (hexString == nil) {
        
        return nil;
        
    }
    const char* ch = [[hexString lowercaseString] cStringUsingEncoding:NSUTF8StringEncoding];
    
    NSMutableData* data = [NSMutableData data];
    
    while (*ch) {
        
        if (*ch == ' ') {
            continue;
        }
        char byte = 0;
        
        if ('0' <= *ch && *ch <= '9') {
            
            byte = *ch - '0';
            
        }
        
        else if ('a' <= *ch && *ch <= 'f') {
            
            byte = *ch - 'a' + 10;
            
        }
        
        else if ('A' <= *ch && *ch <= 'F') {
            
            byte = *ch - 'A' + 10;
            
        }
        
        ch++;
        
        byte = byte << 4;
        
        if (*ch) {
            
            if ('0' <= *ch && *ch <= '9') {
                
                byte += *ch - '0';
                
            } else if ('a' <= *ch && *ch <= 'f') {
                
                byte += *ch - 'a' + 10;
                
            }
            
            else if('A' <= *ch && *ch <= 'F')
                
            {
                
                byte += *ch - 'A' + 10;
                
            }
            
            ch++;
            
        }
        
        [data appendBytes:&byte length:1];
        
    }
    
    return data;
    
}
//NSdata类型数据转换成string
+ (NSString*)hexStringForData:(NSData*)data
{
    if (data == nil) {
        return nil;
    }
    
    NSMutableString* hexString = [NSMutableString string];
    
    const unsigned char *p = [data bytes];
    
    for (int i=0; i < [data length]; i++) {
        [hexString appendFormat:@"%02x", *p++];
    }
    return hexString;
}

@end
