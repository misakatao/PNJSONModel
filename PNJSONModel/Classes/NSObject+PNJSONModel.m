//
//  NSObject+JSONModel.m
//  PNJSONModel
//
//  Created by Misaka on 2024/4/24.
//

#import "NSObject+PNJSONModel.h"

NSString *const kPNPropertyAttributeKeyTypeEncoding = @"T";
NSString *const kPNPropertyAttributeKeyBackingIvarName = @"V";
NSString *const kPNPropertyAttributeKeyReadOnly = @"R";
NSString *const kPNPropertyAttributeKeyCopy = @"C";
NSString *const kPNPropertyAttributeKeyRetain = @"&";
NSString *const kPNPropertyAttributeKeyNonAtomic = @"N";
NSString *const kPNPropertyAttributeKeyCustomGetter = @"G";
NSString *const kPNPropertyAttributeKeyCustomSetter = @"S";
NSString *const kPNPropertyAttributeKeyDynamic = @"D";
NSString *const kPNPropertyAttributeKeyWeak = @"W";
NSString *const kPNPropertyAttributeKeyGarbageCollectable = @"P";
NSString *const kPNPropertyAttributeKeyOldStyleTypeEncoding = @"t";

PNEncodingType PNEncodingGetType(const char *typeEncoding) {
    char *type = (char *)typeEncoding;
    if (!type) return PNEncodingTypeUnknown;
    size_t len = strlen(type);
    if (len == 0) return PNEncodingTypeUnknown;
    
    PNEncodingType qualifier = 0;
//    bool prefix = true;
//    while (prefix) {
//        switch (*type) {
//            case 'r': {
//                qualifier |= PNEncodingTypeQualifierConst;
//                type++;
//            } break;
//            case 'n': {
//                qualifier |= PNEncodingTypeQualifierIn;
//                type++;
//            } break;
//            case 'N': {
//                qualifier |= PNEncodingTypeQualifierInout;
//                type++;
//            } break;
//            case 'o': {
//                qualifier |= PNEncodingTypeQualifierOut;
//                type++;
//            } break;
//            case 'O': {
//                qualifier |= PNEncodingTypeQualifierBycopy;
//                type++;
//            } break;
//            case 'R': {
//                qualifier |= PNEncodingTypeQualifierByref;
//                type++;
//            } break;
//            case 'V': {
//                qualifier |= PNEncodingTypeQualifierOneway;
//                type++;
//            } break;
//            default: { prefix = false; } break;
//        }
//    }

    len = strlen(type);
    if (len == 0) return PNEncodingTypeUnknown | qualifier;

    switch (*type) {
        case 'c': return PNEncodingTypeChar | qualifier;
        case 'i': return PNEncodingTypeInt | qualifier;
        case 's': return PNEncodingTypeShort | qualifier;
        case 'l': return PNEncodingTypeLong | qualifier;
        case 'q': return PNEncodingTypeLongLong | qualifier;
        case 'C': return PNEncodingTypeUnsignedChar | qualifier;
        case 'I': return PNEncodingTypeUnsignedInt | qualifier;
        case 'S': return PNEncodingTypeUnsignedShort | qualifier;
        case 'L': return PNEncodingTypeUnsignedLong | qualifier;
        case 'Q': return PNEncodingTypeUnsignedLongLong | qualifier;
        case 'f': return PNEncodingTypeFloat | qualifier;
        case 'd': return PNEncodingTypeDouble | qualifier;
        case 'B': return PNEncodingTypeBool | qualifier;
        case 'v': return PNEncodingTypeVoid | qualifier;
        case 'b': return PNEncodingTypeBitField | qualifier;
        case 'D': return PNEncodingTypeLongDouble | qualifier;
        case '#': return PNEncodingTypeClass | qualifier;
        case ':': return PNEncodingTypeSelector | qualifier;
        case '*': return PNEncodingTypeCharString | qualifier;
        case '^': return PNEncodingTypePointer | qualifier;
        case '[': return PNEncodingTypeArray | qualifier;
        case '(': return PNEncodingTypeUnion | qualifier;
        case '{': return PNEncodingTypeStruct | qualifier;
        case '@': {
            if (len == 2 && *(type + 1) == '?')
                return PNEncodingTypeBlock | qualifier;
            else
                return PNEncodingTypeObject | qualifier;
        }
        default: return PNEncodingTypeUnknown | qualifier;
    }
}

@interface PNPropertyType ()

@property (nonatomic, assign) BOOL notManage;

@property (nullable, nonatomic, strong) NSArray<NSString *> *protocols;

- (instancetype)initWithAttributes:(NSString *)attributes;

@end

@implementation PNPropertyType

+ (NSDictionary *)encodedTypesMap {
    static NSDictionary *encodedTypesMap = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        encodedTypesMap = @{
            @"c" : @(1),
            @"i" : @(2),
            @"s" : @(3),
            @"l" : @(4),
            @"q" : @(5),
            @"C" : @(6),
            @"I" : @(7),
            @"S" : @(8),
            @"L" : @(9),
            @"Q" : @(10),
            @"B" : @(11),
            @"f" : @(12),
            @"d" : @(13),
            @"v" : @(14),
            @"*" : @(15),
            @"@" : @(16),
            @"#" : @(17),
            @":" : @(18),
            @"[" : @(19),
            @"{" : @(20),
            @"(" : @(21),
            @"b" : @(22),
            @"^" : @(23),
            @"?" : @(24),
            @"D" : @(25),
            /*
            @(PNTypeEncodingChar)               : @(1),
            @(PNTypeEncodingInt)                : @(2),
            @(PNTypeEncodingShort)              : @(3),
            @(PNTypeEncodingLong)               : @(4),
            @(PNTypeEncodingLongLong)           : @(5),
            @(PNTypeEncodingUnsignedChar)       : @(6),
            @(PNTypeEncodingUnsignedInt)        : @(7),
            @(PNTypeEncodingUnsignedShort)      : @(8),
            @(PNTypeEncodingUnsignedLong)       : @(9),
            @(PNTypeEncodingUnsignedLongLong)   : @(10),
            @(PNTypeEncodingCBool)              : @(11),
            @(PNTypeEncodingFloat)              : @(12),
            @(PNTypeEncodingDouble)             : @(13),
            @(PNTypeEncodingVoid)               : @(14),
            @(PNTypeEncodingCString)            : @(15),
            @(PNTypeEncodingObjcObject)         : @(16),
            @(PNTypeEncodingObjcClass)          : @(17),
            @(PNTypeEncodingSelector)           : @(18),
            @(PNTypeEncodingArrayBegin)         : @(19),
            @(PNTypeEncodingStructBegin)        : @(20),
            @(PNTypeEncodingUnionBegin)         : @(21),
            @(PNTypeEncodingBitField)           : @(22),
            @(PNTypeEncodingPointer)            : @(23),
            @(PNTypeEncodingUnknown)            : @(24),
            @(PNTypeEncodingLongDouble)         : @(25),
             */
        };
      });
    return encodedTypesMap;
}

- (instancetype)initWithAttributes:(NSString *)attributes
{
    self = [super init];
    if (self) {
        NSArray *typeStringComponents = [attributes componentsSeparatedByString:@","];
        if ([typeStringComponents count] > 0) {
            if ([typeStringComponents containsObject:@"R"]) {
                _notManage = YES;
                return self;
            }
            // 类型信息肯定是放在最前面的且以 'T' 打头
            NSString *typeInfo = [typeStringComponents objectAtIndex:0];
            NSScanner *scanner = [NSScanner scannerWithString:typeInfo];
            [scanner scanUpToString:@"T" intoString:NULL];
            [scanner scanString:@"T" intoString:NULL];
            NSUInteger scanLocation = scanner.scanLocation;
            if ([typeInfo length] > scanLocation) {
                NSString *typeCode = [typeInfo substringWithRange:NSMakeRange(scanLocation, 1)];
                NSNumber *indexNumber = [[self.class encodedTypesMap] objectForKey:typeCode];
                _type = (PNEncodingType)[indexNumber integerValue];
                // 当前的类型为对象的时候，解析出对象对应的类型的相关信息
                // T@"NSArray<PNJSONModel>"
                if (_type == PNEncodingTypeObject) {
                    scanner.scanLocation += 1;
                    if ([scanner scanString:@"\"" intoString:NULL]) {
                        
                        NSString *objectClassName = nil;
                        if ([scanner scanCharactersFromSet:[NSCharacterSet alphanumericCharacterSet] intoString:&objectClassName]) {
                            if (objectClassName.length) _objClass = NSClassFromString(objectClassName);
                        }
                        
                        if (![_objClass conformsToProtocol:@protocol(NSCoding)]) {
                            _notManage = YES;
                            return self;
                        }
                        
                        NSMutableArray *protocols = nil;
                        while ([scanner scanString:@"<" intoString:NULL]) {
                            NSString* protocol = nil;
                            if ([scanner scanUpToString:@">" intoString: &protocol]) {
                                if (protocol.length) {
                                    if (!protocols) protocols = [NSMutableArray new];
                                    [protocols addObject:protocol];
                                }
                            }
                            [scanner scanString:@">" intoString:NULL];
                        }
                        _protocols = protocols;
                        
                        if ([_objClass isSubclassOfClass:[NSArray class]]) {
                            if (protocols && protocols.count > 0) {
                                for (NSString *protocol in protocols) {
                                    Class protocalClass = NSClassFromString(protocol);
                                    if (protocalClass) {
                                        _arrUsedClass = protocalClass;
                                        break;
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    return self;
}

@end

@interface _SafeManager : NSObject

@property (nonatomic, strong) NSMutableDictionary *dictClassStore;

+ (instancetype)sharedManager;

@end

@implementation _SafeManager

+ (instancetype)sharedManager {
    static _SafeManager *manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[_SafeManager alloc] init];
    });
    return manager;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _dictClassStore = [@{} mutableCopy];
    }
    return self;
}

@end

@implementation NSObject (PNJSONModel)

+ (NSDictionary<NSString *, PNPropertyType *> *)pn_cachedProperties {
    
    NSMutableDictionary *dict = nil;
    NSString *str = NSStringFromClass(self);
    // NSMutableDictionary *propertyMap = objc_getAssociatedObject(self, &PropertiesMapDictionaryKey);
    NSMutableDictionary *propertyMap = nil;
    @synchronized([_SafeManager sharedManager].dictClassStore) {
        propertyMap = [_SafeManager sharedManager].dictClassStore[str];
    }
    if (!propertyMap) {
        Class class = self;
        propertyMap = [NSMutableDictionary dictionary];
        while (class != [NSObject class]) {
            unsigned int count;
            objc_property_t *properties = class_copyPropertyList(class, &count);
            NSArray *noManagerArr = [self pn_noManagePropertyNames];
            for (int i = 0; i < count; i++) {
                objc_property_t property = properties[i];
                NSString *propertyName = [NSString stringWithUTF8String:property_getName(property)];
                if ([noManagerArr containsObject:propertyName]) {
                    continue;
                }
                /*
                 PNEncodingType type = 0;
                 unsigned int attrCount;
                 objc_property_attribute_t *attrs = property_copyAttributeList(property, &attrCount);
                 for (unsigned int i = 0; i < attrCount; i++) {
                     switch (attrs[i].name[0]) {
                         case 'T': { // Type encoding
                             if (attrs[i].value) {
                                 NSString *typeEncoding = [NSString stringWithUTF8String:attrs[i].value];
                                 type = PNEncodingGetType(attrs[i].value);
                                 
                                 if ((type & PNEncodingTypeMask) == PNEncodingTypeObject && typeEncoding.length) {
                                     NSScanner *scanner = [NSScanner scannerWithString:typeEncoding];
                                     if (![scanner scanString:@"@\"" intoString:NULL]) continue;
                                     
                                     NSString *clsName = nil;
                                     if ([scanner scanUpToCharactersFromSet: [NSCharacterSet characterSetWithCharactersInString:@"\"<"] intoString:&clsName]) {
                                         if (clsName.length) objc_getClass(clsName.UTF8String);
                                     }
                                     
                                     NSMutableArray *protocols = nil;
                                     while ([scanner scanString:@"<" intoString:NULL]) {
                                         NSString* protocol = nil;
                                         if ([scanner scanUpToString:@">" intoString: &protocol]) {
                                             if (protocol.length) {
                                                 if (!protocols) protocols = [NSMutableArray new];
                                                 [protocols addObject:protocol];
                                             }
                                         }
                                         [scanner scanString:@">" intoString:NULL];
                                     }
                                 }
                             }
                         } break;
                         default: break;
                     }
                 }
                 if (attrs) {
                     free(attrs);
                     attrs = NULL;
                 }
                 */
                NSString *propertyAttributes = [NSString stringWithUTF8String:property_getAttributes(property)];
                PNPropertyType *propertyType = [[PNPropertyType alloc] initWithAttributes:propertyAttributes];
                if (!propertyType.notManage) {
                    propertyType.propertyName = propertyName;
                    propertyMap[[propertyName lowercaseString]] = propertyType;
                }
            }
            free(properties);
            class = [class superclass];
        }
        // objc_setAssociatedObject(self, &PropertiesMapDictionaryKey, propertyMap, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        @synchronized([_SafeManager sharedManager].dictClassStore) {
            [[_SafeManager sharedManager].dictClassStore setObject:propertyMap forKey:str];
        }
    }
    dict = [propertyMap mutableCopy];
    return dict;
}

+ (NSString *)pn_primaryKeyPropertyName {
    return @"";
}

+ (NSArray<NSString *> *)pn_noManagePropertyNames {
    return @[];
}

@end

