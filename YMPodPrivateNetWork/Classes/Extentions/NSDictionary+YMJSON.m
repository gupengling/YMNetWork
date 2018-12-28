//
//  NSDictionary+YMJSON.m
//  YMPodPrivateNetWork_Example
//
//  Created by 顾鹏凌 on 2018/12/28.
//  Copyright © 2018 gupengling. All rights reserved.
//

#import "NSDictionary+YMJSON.h"

@implementation NSDictionary (YMJSON)

+ (NSString *)jsonStringWithDictionary:(NSDictionary *)dict
{
    if (dict && 0 != dict.count)
    {
        NSError *error = nil;
        // NSJSONWritingOptions 是"NSJSONWritingPrettyPrinted"的话有换位符\n；是"0"的话没有换位符\n。
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:0 error:&error];
        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        return jsonString;
    }

    return nil;
}

// json字符串转dict字典
+ (NSDictionary *)jsonDictWithString:(NSString *)string
{
    if (string && 0 != string.length)
    {
        NSError *error;
        NSData *jsonData = [string dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&error];

        if (error)
        {
            NSLog(@"json解析失败：%@", error);
            return nil;
        }

        return jsonDict;
    }

    return nil;
}

@end
