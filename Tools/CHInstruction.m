//
//  Instruction.m
//  额温枪
//
//  Created by hu on 2018/4/11.
//  Copyright © 2018年 huweihong. All rights reserved.
//

#import "CHInstruction.h"

@implementation CHInstruction
+(NSString *)getNowDateString{

//例如 18-04-11 09：23：24  转成16进制数据  12 04 0b 09 17 18
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"yyMMddHHmmss"];
    NSString *currentDateStr = [formatter stringFromDate:[NSDate date]];

    NSLog(@"%@",currentDateStr);

    NSMutableString * dateMutableStr = [[NSMutableString alloc]init];
    for (int i = 0; i < currentDateStr.length; i+=2) {
        NSString * subStr = [currentDateStr substringWithRange:NSMakeRange(i, 2)];
        [dateMutableStr appendFormat:@"%02lx",(long)[subStr integerValue]];
    }

    return dateMutableStr;
}
+(NSString *)timeAnalyse:(NSData *)data{

    Byte *byte = (Byte *)[data bytes];

    NSString *timeStr =[NSString stringWithFormat:@"20%02d-%02d-%02d %02d:%02d:%02d",byte[0],byte[1],byte[2],byte[3],byte[4],byte[5]];

    return timeStr;
}
+(NSString *)tempAnalyse:(NSData *)data{

    Byte *byte = (Byte *)[data bytes];
    int a=*byte*16*16;
    int b =*++byte;
    int temp =a+b;
    NSLog(@"温度是：%d",temp);
    return [NSString stringWithFormat:@"%f",temp/100.0];

}
+(NSInteger)getHistroyNum:(NSData *)data{

    Byte *byte = (Byte *)[data bytes];
    int a=*byte*16*16;
    int b =*++byte;
    int num =a+b;
    NSLog(@"历史数据条数=======%d",num);
    return num;
    
}
@end
