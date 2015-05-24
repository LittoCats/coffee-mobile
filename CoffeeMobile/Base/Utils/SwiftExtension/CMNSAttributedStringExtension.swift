////
////  NSAttributedStringExtension.swift
////  CoffeeMobile
////
////  Created by 程巍巍 on 5/21/15.
////  Copyright (c) 2015 Littocats. All rights reserved.
////
//
//import Foundation
//
//
//extension NSAttributedString {
//    
//    
//    private class HTMLReader: NSObject {
//        var parser = NSXMLParser()
//        var output = NSMutableAttributedString()
//        var styleStack = [[String: AnyObject]]()
//    }
//}
//
//private let CMAttrColor = "color"
//private let CMAttrBackgroundColor = "backgroundColor"
//private let CMAttrFont = "font"
//private let CMAttrLink = "link"
//private let CMAttrParagraph = "paragraph"
//private let CMAttrStrikethrough = "strikethrough"
//private let CMAttrStrikethroughColor = "strikethroughColor"
//private let CMAttrUnderline = "underline"
//private let CMAttrUnderlineColor = "underlineColor"
//private let CMAttrVerticalAlign = "verticalAlign"
//private let CMAttrBaselineOffset = "baselineOffset"
//
//private let CMFontAttrTraitBold = "traitBold"
//private let CMFontAttrTraitItalic = "traitItalic"
//private let CMFontAttrFeatures = "features"
//private let CMFontAttrPointSize = "pointSize"
//private let CMFontAttrFamilyName = "familyName"
//private let CMFontAttrPostScriptName = "postScriptName"
//
//private let CMParagraphAttrTextAlignment = "textAlignment"
//private let CMParagraphAttrTextAlignmentStyleLeft = "left"
//private let CMParagraphAttrTextAlignmentStyleRight = "right"
//private let CMParagraphAttrTextAlignmentStyleCenter = "center"
//private let CMParagraphAttrTextAlignmentStyleJustified = "justified"
//
//private let CMStrikethroughStyleSingle = "single"
//private let CMStrikethroughStyleThick = "thick"
//private let CMStrikethroughStyleDouble = "double"
//
//private let CMUnderlineStyleSingle = "single"
//private let CMUnderlineStyleThick = "thick"
//private let CMUnderlineStyleDouble = "double"
//
//extension NSAttributedString.HTMLReader: NSXMLParserDelegate {
//    
//    
////    - (NSDictionary *)attributesForStyleString:(NSString *)styleString href:(NSString *)href {
//    func attributesForStyleString(style: String, href: String?)-> [String: AnyObject]{
//        return [String: AnyObject]()
//    }
//    
//    // Merge AshtonAttrFont if it already exists (e.g. if -cocoa-font-features: happened before font:)
//    func mergeFontAttributes(new: [String: AnyObject], into existing: [String: AnyObject]?) -> [String: AnyObject]{
//        if existing == nil {return new}
//        var merged = existing!
//        
//        var fontFeatures: [AnyObject]?
//        if merged[CMFontAttrFeatures] != nil && new[CMFontAttrFeatures] != nil {
//            if var mergedFeatures = merged[CMFontAttrFeatures] as? [AnyObject]{
//                fontFeatures = mergedFeatures
//                if var newFeatures = merged[CMFontAttrFeatures] as? [AnyObject]{
//                    for feature in newFeatures {
//                        fontFeatures!.append(feature)
//                    }
//                }
//            }
//        }
//        
//        for (key,value) in new {
//            merged[key] = value
//        }
//        if fontFeatures != nil {
//            merged[CMFontAttrFeatures] = fontFeatures
//        }
//        
//        return merged
//    }
//
//    func currentAttributes()->[String: AnyObject] {
//        var attrs = [String: AnyObject]()
//        for attr in self.styleStack {
//            for (key, value) in attr {
//                attrs[key] = value
//            }
//        }
//        return attrs
//    }
//
//    private func parserDidStartDocument(parser: NSXMLParser) {
//        output.beginEditing()
//    }
//
//    private func parserDidEndDocument(parser: NSXMLParser) {
//        output.endEditing()
//    }
//
//    private func parser(parser: NSXMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [NSObject : AnyObject]) {
//        if elementName.lowercaseString == "html" {return}
//        if output.length > 0 {
//            if elementName == "p" {
//                output.appendAttributedString(NSAttributedString(string: "\n", attributes: output.attributesAtIndex(output.length-1, effectiveRange: nil)))
//            }
//        }
//        if let style = attributeDict["style"] as? String {
//            self.styleStack.append(self.attributesForStyleString(style, href: attributeDict["href"] as? String))
//        }
//    }
//    
//    
//    private func parser(parser: NSXMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
//        if elementName.lowercaseString == "html" {return}
//        self.styleStack.removeLast()
//    }
//    
//    private func parser(parser: NSXMLParser, parseErrorOccurred parseError: NSError) {
//        println("NSAttributedString HTMLReader ERROR: \(parseError)")
//    }
//    
//    private func parser(parser: NSXMLParser, foundCharacters string: String?) {
//        if string == nil {return}
//        var fragment = NSAttributedString(string: string!, attributes: self.currentAttributes())
//    }
//}