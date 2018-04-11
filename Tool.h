//
//  Tool.h
//  BabywandDevice1
//
//  Created by hu on 15/8/10.
//  Copyright (c) 2015年 huweihong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Tool : NSObject
+(NSString *)timeToString:(NSString *)timeStamp andFormat:(NSString *)foramt;
+ (NSData*)dataForHexString:(NSString*)hexString;;
+ (NSString*)hexStringForData:(NSData*)data;
@end
