//
//  PNJSONModel.h
//  PNJSONModel
//
//  Created by Misaka on 2024/4/24.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface PNJSONModel : NSObject <NSCoding, NSCopying>

- (instancetype)initWithJSONDict:(NSDictionary *)dict;
//插入json字符串
- (void)injectWithJSON:(NSString *)jsonString;
//替换模型数据 只能处理字典
- (void)injectJSONData:(NSDictionary *)jsonData;
//替换模型数据
- (void)injectDataWithModel:(PNJSONModel *)model;
//不区分大小写
- (NSDictionary *)jsonDict;
//区分大小写
- (NSDictionary *)jsonDictCaseSensitive;
//请求
- (NSDictionary *)jsonDictRequest;

- (NSString *)jsonString;
//判断一致性
- (NSString *)bzJsonKeyString;

//键的map @{Json字段名称:属性名称} 都使用小写
+ (NSDictionary *)pn_jsonModelKeyMapper;

//忽略列表
+ (nullable NSDictionary *)bzIgnoreList;
//请求列表
+ (nullable NSDictionary *)bzRequestList;

@end

NS_ASSUME_NONNULL_END
