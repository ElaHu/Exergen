//
//  SqlManager.m
//  ComperPro
//
//  Created by zhouweiming on 16/1/13.
//  Copyright © 2016年 zhouweiming. All rights reserved.
//

#import "SqlManager.h"
#import "FMDatabase.h"
#import "JSONKit.h"
#define DB_PATH [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/comper.db"]
@implementation SqlManager

#pragma mark - 返回格式是字典的方法
+(NSDictionary *)getDictDataFromSqliteWithTableKeyStr:(NSString *)keyStr {
    FMDatabase *db = [FMDatabase databaseWithPath:DB_PATH];
    [db open];
    id responseObject;
    FMResultSet *rs = [db executeQuery:[NSString stringWithFormat:@"select data from comper where keyStr = '%@'",keyStr]];
    while ([rs next]) {
        responseObject = [[rs stringForColumn:@"data"] objectFromJSONString];
    }
    [db close];
    return responseObject;
}

#pragma mark -  返回格式是数组的方法
+(NSMutableArray *)getArrayDataFromSqliteWithTableKeyStr:(NSString *)keyStr{
    FMDatabase *db = [FMDatabase databaseWithPath:DB_PATH];
    [db open];
    id responseObject;
    FMResultSet *rs = [db executeQuery:[NSString stringWithFormat:@"select data from comper where keyStr = '%@'",keyStr]];
    while ([rs next]) {
        responseObject = [[rs stringForColumn:@"data"] objectFromJSONString];
    }
    [db close];
    return responseObject;
}

#pragma mark -  保存数据
+(void)saveDataBase:(id)response withTableKeyStr:(NSString *)keyStr{
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSLog(@"%@",DB_PATH);

        FMDatabase *db = [FMDatabase databaseWithPath:DB_PATH];
        [db open];
        [db executeUpdate:@"create table if not exists comper(id Integer PRIMARY KEY,keyStr char unique,data)"];
        [db executeUpdate:@"replace into comper(keyStr,data) values(?,?)",keyStr,[response JSONString]];
        [db close];
//    });
}

@end
