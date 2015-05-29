//
//  CMNSAttributedStringExtension.swift
//  CoffeeMobile
//
//  Created by 程巍巍 on 5/25/15.
//  Copyright (c) 2015 Littocats. All rights reserved.
//

import Foundation
import UIKit
import XMLNode

extension NSAttributedString {
    
    
    /**
    MARK: 由自定义的 xml 字符串生成  attributedString
    支持的 属性参照 NSAttributedString.XMLParser.ExpressionMap
    */
    convenience init(xml: String){
        self.init(xml:xml, defaultAttribute: [String: AnyObject]())
    }
    
    convenience init(xml: String, defaultAttribute: [String: AnyObject]){
        self.init(attributedString: XMLParser(xml: xml,defaultAttribute: defaultAttribute).start().maString)
    }
    
    private class XMLParser: NSObject, NSXMLParserDelegate {
        private var maString = NSMutableAttributedString()
        private var xml: String!
        private var attrStack = [[String: AnyObject]]()
        
        
        init(xml: String, defaultAttribute: [String: AnyObject]){
            super.init()
            attrStack.append(defaultAttribute)
            self.xml = "<xml a='b'>\(xml)</xml>"
        }
        
        func start()-> XMLParser {
            let parser = NSXMLParser(data: xml.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)!)
            parser.delegate = self
            var flag = parser.parse()
            return self
        }
        
        
        //MARK: 解析标签

        @objc func parserDidStartDocument(parser: NSXMLParser){
            if attrStack.isEmpty {
                attrStack.append([String: AnyObject]())
            }
        }
        
        @objc func parserDidEndDocument(parser: NSXMLParser){
            
        }
        
        @objc func parser(parser: NSXMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [NSObject : AnyObject]){
            var attr = attrStack.last!
            for (key, value) in attributeDict {
                if let name = (key as? String)?.lowercaseString {
                    if let closure = XMLParser.ExpressionMap[(key as! String).lowercaseString] {
                        for (k,v) in closure(key: name, value: value as! String){
                            attr[k] = v
                        }
                    }
                }
            }
            attrStack.append(attr)
        }
        
        @objc func parser(parser: NSXMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?){
            attrStack.removeLast()
        }
        @objc func parser(parser: NSXMLParser, foundCharacters string: String?){
            if let str = string {
                buildString(str)
            }
        }
        @objc func parser(parser: NSXMLParser, parseErrorOccurred parseError: NSError){
            println(parseError)
        }
        
        
        //MARK: 解析文本
        private func buildString(str: String) {
            var string = str
            if var at = attrStack.last{
                // font
                var font: UIFont?
                var family = at[CMTextFontFamilyAttributeName] as? String
                var size = at[CMTextFontSizeAttributeName] as? Float
                
                if size == nil {size = 17}
                if family == nil {
                    font = UIFont.systemFontOfSize(CGFloat(size!))
                }else{
                    font = UIFont(name: family!, size: CGFloat(size!))
                }
                if font != nil {
                    at[NSFontAttributeName] = font!
                }
                at.removeValueForKey(CMTextFontFamilyAttributeName)
                at.removeValueForKey(CMTextFontSizeAttributeName)
                
                // paragraph
                var para = NSMutableParagraphStyle()
                if let align = at[CMTextAlignmentAttributeName] as? Int {
                    para.alignment = NSTextAlignment(rawValue: align)!
                    at.removeValueForKey(CMTextAlignmentAttributeName)
                }
                if let firstLineHeadIndent = at[CMTextFirstLineHeadIndentAttributeName] as? Float {
                    para.firstLineHeadIndent = CGFloat(firstLineHeadIndent)
                    at.removeValueForKey(CMTextFirstLineHeadIndentAttributeName)
                }
                if let headIndent = at[CMTextHeadIndentAttributeName] as? Float {
                    para.headIndent = CGFloat(headIndent)
                    at.removeValueForKey(CMTextHeadIndentAttributeName)
                }
                if let tailIndent = at[CMTextTailIndentAttributeName] as? Float {
                    para.tailIndent = CGFloat(tailIndent)
                    at.removeValueForKey(CMTextTailIndentAttributeName)
                }
                if let lineSpace = at[CMTextLineSpaceAttributeName] as? Float {
                    para.lineSpacing = CGFloat(lineSpace)
                    at.removeValueForKey(CMTextLineSpaceAttributeName)
                }
                at[NSParagraphStyleAttributeName] = para
                
                // append
                maString.appendAttributedString(NSAttributedString(string: str, attributes: at))
            }else{
                maString.appendAttributedString(NSAttributedString(string: str))
            }
            
        }
    }
}
private let CMTextFontFamilyAttributeName = "CMTextFontFamilyAttributeName"
private let CMTextFontSizeAttributeName = "CMTextFontSizeAttributeName"

private let CMTextAlignmentAttributeName = "NSTextAlignmentAttributeName"
private let CMTextFirstLineHeadIndentAttributeName = "CMTextFirstLineHeadIndentAttributeName"
private let CMTextHeadIndentAttributeName = "CMTextHeadIndentAttributeName"
private let CMTextTailIndentAttributeName = "CMTextTailIndentAttributeName"
private let CMTextLineSpaceAttributeName = "CMTextLineSpaceAttributeName"

private func FloatValue(str: String)->Float {
    var float = (str as NSString).floatValue
    return float
}

extension NSAttributedString.XMLParser {
    typealias EXP = (key: String, value: String)->[String: AnyObject]
    
    static var ExpressionMap: [String: EXP] = [
        
        // foreground/background color
        "color": {EXP in [NSForegroundColorAttributeName: UIColor(script: EXP.1)]},
        "bgcolor": {EXP in [NSBackgroundColorAttributeName: UIColor(script: EXP.1)]},
        
        // font
        "font": {EXP in [CMTextFontFamilyAttributeName: EXP.1]},
        "size": {EXP in [CMTextFontSizeAttributeName: FloatValue(EXP.1)]},
        
        // under line
        "underline": {EXP in [NSUnderlineStyleAttributeName: FloatValue(EXP.1)]},
        "ul": {EXP in
            if EXP.0 == EXP.1 {
                return [NSUnderlineStyleAttributeName: 1]
            }
            return [NSUnderlineStyleAttributeName: FloatValue(EXP.1)]
        },
        "underlinecolor": {EXP in [NSUnderlineColorAttributeName: UIColor(script: EXP.1)]},
        "ulcolor": {EXP in [NSUnderlineColorAttributeName: UIColor(script: EXP.1)]},
        
        // strike though
        "strikethrough": {EXP in [NSStrikethroughStyleAttributeName: FloatValue(EXP.1)]},
        "st": {EXP in
            if EXP.0 == EXP.1 {
                return [NSStrikethroughStyleAttributeName: 1]
            }
            return [NSStrikethroughStyleAttributeName: FloatValue(EXP.1)]
        },
        "strikethroughcolor": {EXP in [NSStrikethroughColorAttributeName: UIColor(script: EXP.1)]},
        "stcolor": {EXP in [NSStrikethroughColorAttributeName: UIColor(script: EXP.1)]},
        
        // stroke 可以间接实现 字体加粗效果
        "strokecolor": {EXP in [NSStrikethroughColorAttributeName: UIColor(script: EXP.1)]},
        "stroke": {EXP in [NSStrokeWidthAttributeName: FloatValue(EXP.1)]},
        
        // paragraph
        // text align
        "algin": { EXP in
            switch EXP.1 {
                case "-|","right": return [CMTextAlignmentAttributeName: NSTextAlignment.Right.rawValue]
                case "||","center": return [CMTextAlignmentAttributeName: NSTextAlignment.Center.rawValue]
                default: return [CMTextAlignmentAttributeName: NSTextAlignment.Left.rawValue]
            }
        },
        // 缩紧
        "firstlineindent": {EXP in [CMTextFirstLineHeadIndentAttributeName: FloatValue(EXP.1)]},
        "flindent": {EXP in [CMTextFirstLineHeadIndentAttributeName: FloatValue(EXP.1)]},
        
        "headindent": {EXP in [CMTextHeadIndentAttributeName: FloatValue(EXP.1)]},
        "hindent": {EXP in [CMTextHeadIndentAttributeName: FloatValue(EXP.1)]},
        
        "trailindent": {EXP in [CMTextTailIndentAttributeName: FloatValue(EXP.1)]},
        "tindent": {EXP in [CMTextTailIndentAttributeName: FloatValue(EXP.1)]},
        
        "linespace": {EXP in [CMTextLineSpaceAttributeName: FloatValue(EXP.1)]},
    ]
}