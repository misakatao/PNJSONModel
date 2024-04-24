//
//  PNJSONModel.m
//  PNJSONModel
//
//  Created by Misaka on 2024/4/24.
//

#import "PNJSONModel.h"
#import "NSObject+PNJSONModel.h"

@interface NSDictionary (PNJSONModel)

- (id)pn_keyForValue:(id)value;

@end

@implementation NSDictionary (PNJSONModel)

- (id)pn_keyForValue:(id)value {
    NSArray *keys = [self allKeys];
    for(id key in keys) {
        NSString *keyValue = self[key];
        if ([keyValue isEqual:value]) {
            return key;
        }
    }
    return nil;
}

@end

@interface NSArray (PNJSONModel)

- (instancetype)arrayWithModelClass:(Class)modelClass;

@end

@implementation NSArray (PNJSONModel)

- (instancetype)arrayWithModelClass:(Class)modelClass {
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:self.count];
    for (id obj in self) {
        if ([obj isKindOfClass:[NSArray class]]) {
            [array addObject:[obj arrayWithModelClass:modelClass]];
            
        } else if ([obj isKindOfClass:[NSDictionary class]]) {
            BOOL isModelClass = [modelClass isSubclassOfClass:[PNJSONModel class]];
            [array addObject:isModelClass ? [[modelClass alloc] initWithJSONDict:obj] : obj];
            
        } else {
            [array addObject:obj];
        }
    }
    return array;
}

@end

@interface PNPropertyType (PNJSONModel)

- (id)usedValueWithOriginValue:(id)originValue;

@end

@implementation PNPropertyType(PNJSONModel)

- (id)usedValueWithOriginValue:(id)originValue {
    id usedValue;
    if (self.objClass && originValue) {
        if ([self.objClass isSubclassOfClass:[NSArray class]] && [originValue isKindOfClass:[NSArray class]]) {
            usedValue = [originValue arrayWithModelClass:self.arrUsedClass];
            
        } else if ([originValue isKindOfClass:[NSDictionary class]]) {
            usedValue = [self.objClass isSubclassOfClass:[PNJSONModel class]] ? [[self.objClass alloc] initWithJSONDict:originValue] : ([self.objClass isSubclassOfClass:[NSDictionary class]] ? originValue : nil);
            
        } else if ([originValue isKindOfClass:self.objClass]) {
            usedValue = originValue;
            
        } else if([self.objClass isSubclassOfClass:[NSString class]]) {
            usedValue = [NSString stringWithFormat:@"%@", originValue];
            
        } else if([self.objClass isSubclassOfClass:[NSNumber class]] && [originValue isKindOfClass:[NSString class]]) {
            usedValue = @([originValue doubleValue]);
        }
    } else if (self.type >= PNEncodingTypeChar && self.type <= PNEncodingTypeDouble ) {
        if ([originValue isKindOfClass:[NSString class]]) {
            usedValue = @([originValue doubleValue]);
        } else {
            usedValue = originValue;
        }
    }
    return usedValue;
}

@end

@implementation PNJSONModel

- (instancetype)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (instancetype)initWithJSONDict:(NSDictionary *)dict
{
    self = [super init];
    if (self) {
        [self setValuesForKeysWithDictionary:dict];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super init];
    if (self) {
        NSArray *propertyValues = [[[self class] pn_cachedProperties] allValues];
        for (PNPropertyType *type in propertyValues) {
            id objToSet = [coder decodeObjectForKey:type.propertyName];
            if (objToSet) {
                [self setValue:objToSet forKey:type.propertyName];
            }
        }
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    NSArray *propertyValues = [[[self class] pn_cachedProperties] allValues];
    for (PNPropertyType *type in propertyValues) {
        id objToSet = [self valueForKey:type.propertyName];
        if ([objToSet conformsToProtocol:@protocol(NSCoding)]) {
            [coder encodeObject:objToSet forKey:type.propertyName];
        }
    }
}

- (id)copyWithZone:(NSZone *)zone {
    typeof(self) copyOne = [[[self class] alloc] init];
    [copyOne injectDataWithModel:self];
    return copyOne;
}

- (void)injectWithJSON:(NSString *)jsonString {
    if (jsonString == nil) {
        return;
    }
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingFragmentsAllowed | NSJSONReadingMutableContainers error:&err];
    if (!err) {
        [self injectJSONData:dic];
    } else {
        
    }
}

- (void)injectJSONData:(NSDictionary *)jsonData {
    if ([jsonData isKindOfClass:[NSDictionary class]]) {
        [self setValuesForKeysWithDictionary:jsonData];
    }
}

- (void)injectDataWithModel:(PNJSONModel *)model {
    if (![model isKindOfClass:[PNJSONModel class]]) {
        return;
    }
    NSArray *propertyValues = [[[model class] pn_cachedProperties] allValues];
    NSDictionary *igonreDict = [[model class] bzIgnoreList];
    NSDictionary *requestDict = [[model class] bzRequestList];
    for (PNPropertyType *type in propertyValues) {
        if (igonreDict && igonreDict[type.propertyName]) {
            continue;
        }
        if (requestDict && requestDict[type.propertyName]) {
            continue;
        }
        id objToSet = [model valueForKey:type.propertyName];
        if (objToSet) {
            [self setValue:objToSet forKey:type.propertyName];
        }
    }
}

- (NSString *)description {
    return [self jsonString];
}

- (void)setValue:(id)value forKey:(NSString *)key {
    NSDictionary *propertyMap = [[self class] pn_cachedProperties];
    NSString *usedKey = [key lowercaseString];
    PNPropertyType *propertyType = propertyMap[usedKey];
    if (!propertyType) {
        NSDictionary *keyMap = [self class].pn_jsonModelKeyMapper;
        NSString *modelKey = keyMap[usedKey];
        if (modelKey.length) {
            propertyType = propertyMap[modelKey];
        }
    }
    if (propertyType) {
        id usedValue = [propertyType usedValueWithOriginValue:value];
        if (usedValue) {
            [super setValue:usedValue forKey:propertyType.propertyName];
        }else{
            [self setNilValueForKey:propertyType.propertyName];
        }
    }else{
        [super setValue:value forKey:key];
    }
}

- (id)valueForKey:(NSString *)key {
    return [super valueForKey:key];
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key {
    NSDictionary *propertyMap = [[self class] pn_cachedProperties];
    NSString *usedKey = [key lowercaseString];
    PNPropertyType *propertyType = propertyMap[usedKey];
    if (!propertyType) {
        NSDictionary *keyMap = [self class].pn_jsonModelKeyMapper;
        NSString *modelKey = keyMap[usedKey];
        if (modelKey.length) {
            propertyType = propertyMap[modelKey];
        }
    }
    if (propertyType) {
        id usedValue = [propertyType usedValueWithOriginValue:value];
        if (usedValue) {
            [super setValue:usedValue forKey:propertyType.propertyName];
        } else {
            [self setNilValueForKey:propertyType.propertyName];
        }
    }
}

- (void)setNilValueForKey:(NSString *)key {
    NSDictionary *propertyMap = [[self class] pn_cachedProperties];
    NSString *usedKey = [key lowercaseString];
    PNPropertyType *propertyType = propertyMap[usedKey];
    if (!propertyType) {
        NSDictionary *keyMap = [self class].pn_jsonModelKeyMapper;
        NSString *modelKey = keyMap[usedKey];
        if (modelKey.length) {
            propertyType = propertyMap[modelKey];
        }
    }
    id value;
    if (propertyType) {
        if (propertyType.type == PNEncodingTypeObject) {
            if ([propertyType.objClass isSubclassOfClass:[NSArray class]]) {
                value = @[];
            } else if ([propertyType.objClass isSubclassOfClass:[NSString class]]) {
                value = @"";
            } else if ([propertyType.objClass isSubclassOfClass:[NSNumber class]]) {
                value = @(0);
            }
        } else {
            value = @(0);
        }
    }
    if (value) {
        [super setValue:value forKey:propertyType.propertyName];
    }
}


- (NSDictionary *)jsonDict {
    NSDictionary *propertyMap = [[self class] pn_cachedProperties];
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    NSArray *allProperties = [propertyMap allValues];
    NSDictionary *keyMapper = [[self class] pn_jsonModelKeyMapper];
    for (PNPropertyType *propertyType in allProperties) {
        id obj = [self valueForKey:propertyType.propertyName];
        NSString *key = [propertyType.propertyName lowercaseString];
        NSString *maperKey = [keyMapper pn_keyForValue:key];
        if (maperKey.length) {
            key = maperKey;
        }
        if ([obj isKindOfClass:[PNJSONModel class]]) {
            [dict setObject:[obj jsonDict] forKey:key];
            
        } else if ([obj isKindOfClass:[NSArray class]] && [propertyType.arrUsedClass isSubclassOfClass:[PNJSONModel class]]) {
            NSArray *items = (NSArray *)obj;
            NSMutableArray *jsonList = [NSMutableArray array];
            for (id item in items) {
                if ([item isKindOfClass:[PNJSONModel class]]) {
                    [jsonList addObject:[item jsonDict]];
                }
            }
            [dict setObject:jsonList forKey:key];
        } else {
            if (obj) {
                [dict setValue:obj forKey:key];
            }
        }
    }
    return dict;
}

- (NSString *)bzJsonKeyString {
    NSDictionary *propertyMap = [[self class] pn_cachedProperties];
    NSMutableString *str = [NSMutableString string];
    NSArray *allProperties = [propertyMap allValues];
    NSDictionary *keyMapper = [[self class] pn_jsonModelKeyMapper];
    for (PNPropertyType *propertyType in allProperties) {
        id obj = [self valueForKey:propertyType.propertyName];
        NSString *key = [propertyType.propertyName lowercaseString];
        NSString *maperKey = [keyMapper pn_keyForValue:key];
        if (maperKey.length) {
            key = maperKey;
        }
        if ([obj isKindOfClass:[PNJSONModel class]]) {
            [str appendString:[obj bzJsonKeyString]];
        } else if ([obj isKindOfClass:[NSArray class]] && [propertyType.arrUsedClass isSubclassOfClass:[PNJSONModel class]]) {
            NSArray *items = (NSArray *)obj;
            for (id item in items) {
                if ([item isKindOfClass:[PNJSONModel class]]) {
                    [str appendString:[item jsonString]];
                }
            }
        } else {
            if (obj) {
                [str appendFormat:@"%@",obj];
            }
        }
    }
    return str;
}

- (NSDictionary *)jsonDictCaseSensitive {
    NSDictionary *propertyMap = [[self class] pn_cachedProperties];
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    NSArray *allProperties = [propertyMap allValues];
    NSDictionary *keyMapper = [[self class] pn_jsonModelKeyMapper];
    for (PNPropertyType *propertyType in allProperties) {
        id obj = [self valueForKey:propertyType.propertyName];
        NSString *key = propertyType.propertyName;
        NSString *maperKey = [keyMapper pn_keyForValue:key];
        if (maperKey.length) {
            key = maperKey;
        }
        if ([obj isKindOfClass:[PNJSONModel class]]) {
            [dict setObject:[obj jsonDictCaseSensitive] forKey:key];
        } else if ([obj isKindOfClass:[NSArray class]] && [propertyType.arrUsedClass isSubclassOfClass:[PNJSONModel class]]) {
            NSArray *items = (NSArray *)obj;
            NSMutableArray *jsonList = [NSMutableArray array];
            for (id item in items) {
                if ([item isKindOfClass:[PNJSONModel class]]) {
                    [jsonList addObject:[item jsonDictCaseSensitive]];
                }
            }
            [dict setObject:jsonList forKey:key];
        } else {
            if (obj) {
                [dict setValue:obj forKey:key];
            }
        }
    }
    return dict;
}

- (NSDictionary *)jsonDictRequest {
    NSDictionary *propertyMap = [[self class] pn_cachedProperties];
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    NSArray *allProperties = [propertyMap allValues];
    NSDictionary *keyMapper = [[self class] pn_jsonModelKeyMapper];
    NSDictionary *requestDict = [[self class] bzRequestList];
    for (PNPropertyType *propertyType in allProperties) {
        NSString *key = [propertyType.propertyName lowercaseString];
        NSString *ignorekey = propertyType.propertyName;
        NSString *maperKey = [keyMapper pn_keyForValue:key];
        if (maperKey.length) {
            key = maperKey;
            ignorekey = maperKey;
        }
        if (requestDict && requestDict[ignorekey]) {
            id obj = [self valueForKey:propertyType.propertyName];
            if ([obj isKindOfClass:[PNJSONModel class]]) {
                [dict setObject:[obj jsonDictRequest] forKey:ignorekey];
                
            } else if ([obj isKindOfClass:[NSArray class]] && [propertyType.arrUsedClass isSubclassOfClass:[PNJSONModel class]]) {
                NSArray *items = (NSArray *)obj;
                NSMutableArray *jsonList = [NSMutableArray array];
                for (id item in items) {
                    if ([item isKindOfClass:[PNJSONModel class]]) {
                        [jsonList addObject:[item jsonDict]];
                    }
                }
                [dict setObject:jsonList forKey:ignorekey];
            } else {
                if (obj) {
                    [dict setValue:obj forKey:ignorekey];
                }
            }
        }
    }
    return dict;
}

- (NSString *)jsonString {
    NSDictionary *dic = [self jsonDict];
    NSString *str = @"";
    if ([NSJSONSerialization isValidJSONObject:dic]) {
        NSError *error;
        NSData *data = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted | NSJSONWritingFragmentsAllowed error:&error];
        if (!error) {
            str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        }
    }
    return str;
}

+ (NSDictionary *)pn_jsonModelKeyMapper {
    return @{
        @"id" : @"bzid"
    };
}

+ (nullable NSDictionary *)bzIgnoreList {
    return nil;
}

+ (nullable NSDictionary *)bzRequestList {
    return nil;
}

@end
