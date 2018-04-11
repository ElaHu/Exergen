//
//  SqlManager.h
//  ComperPro
//
//  Created by zhouweiming on 16/1/13.
//  Copyright © 2016年 zhouweiming. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SqlManager : NSObject

/**
 *  @author 周维明, 16-01-13 15:01:10
 *
 *  @brief  缓存返回数据格式是字典的数据
 *
 *  @param tableName 表字段名称 （唯一区分）
 *
 *  @return 返回格式
 */
+(NSDictionary *)getDictDataFromSqliteWithTableKeyStr:(NSString *)keyStr;

/**
 *  @author 周维明, 16-01-13 15:01:35
 *
 *  @brief  缓存返回数据格式是数组的数据
 *
 *  @param tableName 表字段名称 （唯一区分）
 *
 *  @return 返回格式
 */
+(NSMutableArray *)getArrayDataFromSqliteWithTableKeyStr:(NSString *)keyStr;

/**
 *  @author 周维明, 16-01-13 15:01:00
 *
 *  @brief  保存数据
 *
 *  @param response  需要保存的数据
 *  @param tableName 表字段名称 （唯一区分）
 */
+(void)saveDataBase:(id)response withTableKeyStr:(NSString *)keyStr;

@end
