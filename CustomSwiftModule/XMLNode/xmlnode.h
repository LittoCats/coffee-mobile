//
//  XMLNode.h
//  XMLNode
//
//  Created by 程巍巍 on 5/23/15.
//  Copyright (c) 2015 Littocats. All rights reserved.
//

#import <Foundation/Foundation.h>

@class NSArray, NSDictionary, NSError, NSString, NSURL;
@class XMLElement, XMLDocument;

typedef NS_ENUM(NSInteger, XMLNodeKind) {
    XMLNodeKindInvalid = 0,
    XMLNodeKindDocument,
    XMLNodeKindElement,
    XMLNodeKindAttribute,
    XMLNodeKindNamespace,
    XMLNodeKindProcessingInstruction,
    XMLNodeKindComment,
    XMLNodeKindText,
    XMLNodeKindDTD,
    XMLNodeKindEntityDeclaration,
    XMLNodeKindAttributeDeclaration,
    XMLNodeKindElementDeclaration,
    XMLNodeKindNotationDeclaration
};

@interface XMLNode : NSObject <NSCopying>

+ (XMLElement *)elementWithName:(NSString *)name;
+ (XMLElement *)elementWithName:(NSString *)name stringValue:(NSString *)value;
+ (XMLElement *)elementWithName:(NSString *)name URI:(NSString *)value;

+ (id)attributeWithName:(NSString *)name stringValue:(NSString *)value;
+ (id)attributeWithName:(NSString *)name URI:(NSString *)attributeURI stringValue:(NSString *)value;

+ (id)namespaceWithName:(NSString *)name stringValue:(NSString *)value;

+ (id)textWithStringValue:(NSString *)value;

- (NSString *)stringValue;
- (void)setStringValue:(NSString *)str;

- (NSUInteger)childCount;
- (NSArray *)children;
- (XMLNode *)childAtIndex:(unsigned)index;

- (NSString *)localName;
- (NSString *)name;
- (NSString *)prefix;
- (NSString *)URI;

- (XMLNodeKind)kind;

- (NSString *)xmlString;

+ (NSString *)localNameForName:(NSString *)name;
+ (NSString *)prefixForName:(NSString *)name;

// This is the preferred entry point for nodesForXPath.  This takes an explicit
// namespace dictionary (keys are prefixes, values are URIs).
- (NSArray *)nodesForXPath:(NSString *)xpath namespaces:(NSDictionary *)namespaces error:(NSError **)error;

// This implementation of nodesForXPath registers namespaces only from the
// document's root node.  _def_ns may be used as a prefix for the default
// namespace, though there's no guarantee that the default namespace will
// be consistenly the same namespace in server responses.
- (NSArray *)nodesForXPath:(NSString *)xpath error:(NSError **)error;

// access to the underlying libxml node; be sure to release the cached values
// if you change the underlying tree at all
- (void)releaseCachedValues;

@end


@interface XMLElement : XMLNode

- (id)initWithXMLString:(NSString *)str error:(NSError **)error;

- (NSArray *)namespaces;
- (void)setNamespaces:(NSArray *)namespaces;
- (void)addNamespace:(XMLNode *)aNamespace;

// addChild adds a copy of the child node to the element
- (void)addChild:(XMLNode *)child;
- (void)removeChild:(XMLNode *)child;

- (NSArray *)elementsForName:(NSString *)name;
- (NSArray *)elementsForLocalName:(NSString *)localName URI:(NSString *)URI;

- (NSArray *)attributes;
- (XMLNode *)attributeForName:(NSString *)name;
- (XMLNode *)attributeForLocalName:(NSString *)name URI:(NSString *)attributeURI;
- (void)addAttribute:(XMLNode *)attribute;

- (NSString *)resolvePrefixForNamespaceURI:(NSString *)namespaceURI;

@end

@interface XMLDocument : NSObject 
- (id)initWithXMLString:(NSString *)str options:(unsigned int)mask error:(NSError **)error;
- (id)initWithData:(NSData *)data options:(unsigned int)mask error:(NSError **)error;

// initWithRootElement uses a copy of the argument as the new document's root
- (id)initWithRootElement:(XMLElement *)element;

- (XMLElement *)rootElement;

- (NSData *)xmlData;

- (void)setVersion:(NSString *)version;
- (void)setCharacterEncoding:(NSString *)encoding;

// This is the preferred entry point for nodesForXPath.  This takes an explicit
// namespace dictionary (keys are prefixes, values are URIs).
- (NSArray *)nodesForXPath:(NSString *)xpath namespaces:(NSDictionary *)namespaces error:(NSError **)error;

// This implementation of nodesForXPath registers namespaces only from the
// document's root node.  _def_ns may be used as a prefix for the default
// namespace, though there's no guarantee that the default namespace will
// be consistenly the same namespace in server responses.
- (NSArray *)nodesForXPath:(NSString *)xpath error:(NSError **)error;

- (NSString *)description;
@end