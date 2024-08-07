//
//  NSObject+JSONModel.h
//  PNJSONModel
//
//  Created by Misaka on 2024/4/24.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, PNEncodingType) {
    PNEncodingTypeMask = 0xFF,           ///< mask of type value
    PNEncodingTypeChar = 1,              ///< `c` A char `int8_t`
    PNEncodingTypeInt = 2,               ///< `i` An int `int32_t`
    PNEncodingTypeShort = 3,             ///< `s` A short `int16_t`
    PNEncodingTypeLong = 4,              ///< `l` A long    l is treated as a 32-bit quantity on 64-bit programs.
    PNEncodingTypeLongLong = 5,          ///< `q` A long long `int64_t`
    PNEncodingTypeUnsignedChar = 6,      ///< `C` An unsigned char `uint8_t`
    PNEncodingTypeUnsignedInt = 7,       ///< `I` An unsigned int `uint32_t`
    PNEncodingTypeUnsignedShort = 8,     ///< `S` An unsigned short `uint16_t`
    PNEncodingTypeUnsignedLong = 9,      ///< `L` An unsigned long
    PNEncodingTypeUnsignedLongLong = 10, ///< `Q` An unsigned long long `uint64_t`
    PNEncodingTypeBool = 11,             ///< `B` A C++ bool or a C99 _Bool
    PNEncodingTypeFloat = 12,            ///< `f` A float
    PNEncodingTypeDouble = 13,           ///< `d` A double
    PNEncodingTypeVoid = 14,             ///< `v` A void
    PNEncodingTypeCharString = 15,       ///< `*` A character string (char *)
    PNEncodingTypeObject = 16,           ///< `@` An object (whether statically typed or typed id)
    PNEncodingTypeClass = 17,            ///< `#` A class object (Class)
    PNEncodingTypeSelector = 18,         ///< `:` A method selector (SEL)
    PNEncodingTypeArray = 19,            ///< `[` An array
    PNEncodingTypeStruct = 20,           ///< `{` A structure
    PNEncodingTypeUnion = 21,            ///< `(` A union
    PNEncodingTypeBitField = 22,         ///< `b` A bit field of num bits
    PNEncodingTypePointer = 23,          ///< `^` A pointer to type
    PNEncodingTypeUnknown = 24,          ///< `?` An unknown type (among other things, this code is used for function pointers)
    PNEncodingTypeBlock = 25,            ///< `@` A block
    PNEncodingTypeLongDouble = 26,       ///< `D` An long double
};

// See https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/ObjCRuntimeGuide/Articles/ocrtPropertyIntrospection.html#//apple_ref/doc/uid/TP40008048-CH101-SW6
FOUNDATION_EXPORT NSString *const kPNPropertyAttributeKeyTypeEncoding;
FOUNDATION_EXPORT NSString *const kPNPropertyAttributeKeyBackingIvarName;
FOUNDATION_EXPORT NSString *const kPNPropertyAttributeKeyReadOnly;
FOUNDATION_EXPORT NSString *const kPNPropertyAttributeKeyCopy;
FOUNDATION_EXPORT NSString *const kPNPropertyAttributeKeyRetain;
FOUNDATION_EXPORT NSString *const kPNPropertyAttributeKeyNonAtomic;
FOUNDATION_EXPORT NSString *const kPNPropertyAttributeKeyCustomGetter;
FOUNDATION_EXPORT NSString *const kPNPropertyAttributeKeyCustomSetter;
FOUNDATION_EXPORT NSString *const kPNPropertyAttributeKeyDynamic;
FOUNDATION_EXPORT NSString *const kPNPropertyAttributeKeyWeak;
FOUNDATION_EXPORT NSString *const kPNPropertyAttributeKeyGarbageCollectable;
FOUNDATION_EXPORT NSString *const kPNPropertyAttributeKeyOldStyleTypeEncoding;

typedef NS_ENUM(NSUInteger, PNPropertyAttribute) {
    PNPropertyAttributeTypeEncoding       = 'T',
    PNPropertyAttributeBackingIvarName    = 'V',
    PNPropertyAttributeCopy               = 'C',
    PNPropertyAttributeCustomGetter       = 'G',
    PNPropertyAttributeCustomSetter       = 'S',
    PNPropertyAttributeDynamic            = 'D',
    PNPropertyAttributeGarbageCollectible = 'P',
    PNPropertyAttributeNonAtomic          = 'N',
    PNPropertyAttributeOldTypeEncoding    = 't',
    PNPropertyAttributeReadOnly           = 'R',
    PNPropertyAttributeRetain             = '&',
    PNPropertyAttributeWeak               = 'W'
}; //NS_SWIFT_NAME(PN.PropertyAttribute);

typedef NS_ENUM(char, PNTypeEncoding) {
    // PNTypeEncodingNull             = '\0',
    PNTypeEncodingUnknown          = '?',
    PNTypeEncodingChar             = 'c',
    PNTypeEncodingInt              = 'i',
    PNTypeEncodingShort            = 's',
    PNTypeEncodingLong             = 'l',
    PNTypeEncodingLongLong         = 'q',
    PNTypeEncodingUnsignedChar     = 'C',
    PNTypeEncodingUnsignedInt      = 'I',
    PNTypeEncodingUnsignedShort    = 'S',
    PNTypeEncodingUnsignedLong     = 'L',
    PNTypeEncodingUnsignedLongLong = 'Q',
    PNTypeEncodingFloat            = 'f',
    PNTypeEncodingDouble           = 'd',
    PNTypeEncodingLongDouble       = 'D',
    PNTypeEncodingCBool            = 'B',
    PNTypeEncodingVoid             = 'v',
    PNTypeEncodingCString          = '*',
    PNTypeEncodingObjcObject       = '@',
    PNTypeEncodingObjcClass        = '#',
    PNTypeEncodingSelector         = ':',
    PNTypeEncodingArrayBegin       = '[',
    PNTypeEncodingArrayEnd         = ']',
    PNTypeEncodingStructBegin      = '{',
    PNTypeEncodingStructEnd        = '}',
    PNTypeEncodingUnionBegin       = '(',
    PNTypeEncodingUnionEnd         = ')',
    PNTypeEncodingBitField         = 'b',
    PNTypeEncodingPointer          = '^',
    // PNTypeEncodingConst            = 'r'
    // PNTypeEncodingQuote            = '\"',
}; //NS_SWIFT_NAME(PN.TypeEncoding);

@interface PNPropertyType : NSObject

@property (nonatomic, copy) NSString *propertyName;
// 数组内部使用 以协议标识
@property (nonatomic, assign) Class objClass;
// 正常的类型 当属性类型为对象的时候使用
@property (nonatomic, assign) Class arrUsedClass;
// 属性类型 上述情况并未完全处理
@property (nonatomic, assign) PNEncodingType type;

@end

@interface NSObject (PNJSONModel)

//存储的属性表 字典键为小写 只有基本数据类型 支持NSCoding协议的对象支持自动解析
+ (NSDictionary<NSString *, PNPropertyType *> *)pn_cachedProperties;
//存储数据库的主键名 不可随意更新 主键的更新需要优化 现在属性减少会重建表 小写
+ (NSString *)pn_primaryKeyPropertyName;
//不进行持久化保存和自动化解析的键 都要小写...
+ (NSArray<NSString *> *)pn_noManagePropertyNames;

@end

NS_ASSUME_NONNULL_END
