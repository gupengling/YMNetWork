//
//  NSDictionary+YMJSON.h
//  YMPodPrivateNetWork_Example
//
//  Created by 顾鹏凌 on 2018/12/28.
//  Copyright © 2018 gupengling. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSDictionary (YMJSON)
+ (NSString *)jsonStringWithDictionary:(NSDictionary *)dict;
+ (NSDictionary *)jsonDictWithString:(NSString *)string;
@end

NS_ASSUME_NONNULL_END
