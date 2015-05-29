//
//  CMView.swift
//  CoffeeMobile
//
//  Created by 程巍巍 on 5/20/15.
//  Copyright (c) 2015 Littocats. All rights reserved.
//

import UIKit
import XMLNode

typealias XMLViewAttributeAnalyzer = @objc_block (view: UIView, value: String?)->AnyObject?
typealias XMLViewConstructor = @objc_block ()->UIView

/**
MARK: 只有实现了该协议的 View  类，才能通过 XML 配制自动构建
*/
@objc protocol XMLViewProtocol: NSObjectProtocol {
    
    /**
    MARK: Children 构造器，如果与 superview 提供的构造器名称相同，则覆盖 superview 提供的构造器，运行时确定，因此可以在同一个类的不同实例中提供不同的构造器，但不建议这么做
    */
    optional var XMLViewConstructorMap: [String: XMLViewConstructor] {get}
    
    /**
    MARK: 私用属性存取器，运行时确定，属性名相同时，可覆盖 superview 的属性存取器
    */
    optional func XMLViewAttributeAnalyzerMap()->[String:XMLViewAttributeAnalyzer]
    
    /**
    MARK: 是否忽略 Children 自动构建， 例如：标准 button 中 imageView/titleLabel 是不需要自动构建的。可以在这里自行处理一些资源解析，对自定义控件十分有用
    */
    optional func shouldIgnoreAutoLoadXMLChild(child: XMLElement)-> Bool
    
    /**
    MARK: 此方法主要用于一些特殊的自定义界面，使其可以定制 constraint.
    如果没有实现该方法或返回 nil ， 则使用预定义的解析方法
    */
    optional func constrainForName(name: String, script: String)-> NSLayoutConstraint?
}
//MARK:
extension UIView {
    struct XMLStatic {
        private static var xmlAssociatedKey = "xmlAssociatedKey"
        private static var contextAssociatedKey = "contextAssociatedKey"
        private static var uidMap = NSMapTable.strongToWeakObjectsMapTable()
        
        private static var XMLViewRootClassMap: [String: XMLViewConstructor] = [
            "View": {CMView()}
        ]
        
        private static var XMLViewAttributeAnalyzerMap: [String: XMLViewAttributeAnalyzer] = [
            "color": { (view: UIView, value: String?)->AnyObject? in
                if value != nil {
                    view.backgroundColor = UIColor(script: value!)
                }
                return view.backgroundColor?.hex
            },
            "bordercolor": { (view: UIView, value: String?)->AnyObject? in
                if value != nil {
                    view.layer.borderColor = UIColor(script: value!).CGColor
                }
                return UIColor(CGColor: view.layer.borderColor)?.hex
            },
            "borderwidth": { (view: UIView, value: String?)->AnyObject? in
                if value != nil {
                    view.layer.borderWidth = CGFloat(("\(value!)" as NSString).floatValue)
                }
                return view.layer.borderWidth
            },
            "cornerradius": { (view: UIView, value: String?)->AnyObject? in
                if value != nil {
                    view.layer.cornerRadius = CGFloat(("\(value!)" as NSString).floatValue)
                }
                return view.layer.cornerRadius
            },
            "contentmode": {(view: UIView, value: String?)->AnyObject? in
                if value != nil {
                    view.contentMode = UIViewContentMode(rawValue: ("\(value!)" as NSString).integerValue)!
                }
                return view.contentMode.rawValue
            },
            "hidden": {(view: UIView, value: String?)->AnyObject? in
                if value != nil {
                    view.hidden = ("\(value!)" as NSString).boolValue
                }
                return view.hidden
            },
            "alpha": {(view: UIView, value: String?)->AnyObject? in
                if value != nil {
                    view.alpha = CGFloat(("\(value!)" as NSString).floatValue)
                }
                return view.alpha
            },
            "clipstobounds": {(view: UIView, value: String?)->AnyObject? in
                if value != nil {
                    view.clipsToBounds = ("\(value!)" as NSString).boolValue
                }
                return view.clipsToBounds
            }
        ]

        private static var XMLViewConstraintAttributeMap: [String: [NSLayoutAttribute]] = [
            "width":    [NSLayoutAttribute.Width],
            "height":   [NSLayoutAttribute.Height],
            "top":      [NSLayoutAttribute.Top],
            "bottom":   [NSLayoutAttribute.Bottom],
            "left":     [NSLayoutAttribute.Left],
            "right":    [NSLayoutAttribute.Right],
            "leading":  [NSLayoutAttribute.Leading],
            "trailing": [NSLayoutAttribute.Trailing],
            "centerx":  [NSLayoutAttribute.CenterX],
            "centery":  [NSLayoutAttribute.CenterY],
            "ratio":    [NSLayoutAttribute.Width,NSLayoutAttribute.Height]
        ]
    }
    
    /**
    MARK: 自动构建时，绑定到 View 的 XML DOM 元素，主要用于自动搜索
    */
    final var xml: XMLElement? {
        return objc_getAssociatedObject(self, &XMLStatic.xmlAssociatedKey) as? XMLElement
    }
    
    /**
    MARK: View 实例的唯一标识符，如果是由 XMLElement 自动构建的，则会绑定到 对应的 XMLElement
    */
    final var uid: String {
        return String(format: "uid_%p", self)
    }
    
    //
    
    private func hostViewController() ->UIViewController? {
        var target: AnyObject? = self
        while target != nil {
            if let next = (target as? UIResponder)?.nextResponder() {
                target = next
                if target is UIViewController {
                    break
                }
            }else{
                target = nil
                break
            }
        }
        return target as? UIViewController
    }
    
    /**
    MARK: XMLView 运行时上下文
    */
    final var context: CMContext? {
        return (hostViewController() as? CMViewController)?.context
    }
    
    /**
    MARK: convenience init with xml
    */
    static func view(xmlString: String)-> UIView{
        var error = NSErrorPointer()
        var xmlDoc = XMLDocument(XMLString: xmlString, options: 0, error: error)
        if error != nil {
            println(error.memory)
            return UIView()
        }
        
        if let root = xmlDoc.rootElement() {
            if let view = loadXMLView(xmlele: root, constructorMap: XMLStatic.XMLViewRootClassMap){
                view.loadXMLConstraints()
                return view
            }
        }
        
        return UIView()
    }
    
    private static func loadXMLView(#xmlele: XMLElement, constructorMap map: [String: XMLViewConstructor])->UIView? {
        if let name = xmlele.name() {
            if let constructor = map[name] {
                var view = constructor()
                objc_setAssociatedObject(view, &XMLStatic.xmlAssociatedKey, xmlele, objc_AssociationPolicy(OBJC_ASSOCIATION_RETAIN_NONATOMIC))
                // 将 native id 添加到 xnlelement 中，方便 选择器 查找
                var nativeId = XMLNode.attributeWithName("_uid", stringValue: view.uid) as! XMLNode
                xmlele.addAttribute(nativeId)
                view.loadXMLAttribute()
                if let children = xmlele.children() {
                    var childrenMap = map
                    if let map = (view as? XMLViewProtocol)?.XMLViewConstructorMap {
                        for (key, value) in map {
                            childrenMap[key] = value
                        }
                    }
                    for child in children as! [XMLNode] {
                        if let subele = child as? XMLElement {
                            if let ignore = (view as? XMLViewProtocol)?.shouldIgnoreAutoLoadXMLChild?(subele) {
                                if ignore {continue}
                            }
                            if let subview = loadXMLView(xmlele: subele, constructorMap: childrenMap){
                                view.addSubview(subview)
                            }
                        }
                    }
                }
                return view
            }
        }
        return nil
    }
    /**
    MARK: 根据 xml 属性，设置 view 的属性
    子类中必须调用 super  方法
    */
    private func loadXMLAttribute() {
        var analyzerMap = XMLStatic.XMLViewAttributeAnalyzerMap
        if let xmlView = self as? XMLViewProtocol {
            if let map = xmlView.XMLViewAttributeAnalyzerMap?() {
                for (name,analyzer) in map {
                    analyzerMap[name] = analyzer
                }
            }
        }
        if let attributes = xml?.attributes() as? [XMLNode] {
            for node in attributes {
                if let analyzer = analyzerMap[node.name().lowercaseString] {
                    analyzer(view: self, value: node.stringValue())
                }
            }
        }
    }
    
    
    /**
    MARK: 根据 xml 属性，添加约束, 自动调用，不要手动调用
    */
    private func loadXMLConstraints() {
        for name in ["width", "height", "centerx", "centery", "left", "right", "top", "bottom", "ratio"] {
            if let script: String = xml?.attributeForName(name)?.stringValue() {
                if script.isEmpty {continue}
                /**
                解析 constraint script 为 [first, firstattribute, relation, second, secondattribute, constant, multiper]。
                first 为当前控件，即 self, firstattribute 为当前 xmlnode 的 name, second 需跟据 id 在 context 中查找,constant 位于 + 或 - 号 与 * 号之间，默认为0， multiper * 号以后的数字部分，默认为 1
                multiper 不能为负值
                script 仅存在两种情况，数字开头，例： width='44*1.2'；非数字开头，例： centerx=root.centerx-10*2
                @discussion 为使简化结构，所有约束，仅允许同级（兄弟）及与父级之间存在约束，自定义控件内，自已实现的，不受限制
                @discussion 如果 second 为 super ,则 second 为 superview
                */
                var conf = [String: AnyObject]()
                conf["first"] = self
                conf["firstattribute"] = name
                conf["constant"] = 0
                conf["multiplier"] = 1
                conf["secondattribute"] = NSLayoutAttribute.NotAnAttribute.rawValue
                
                // second secondattribute
                if let range = script.rangeOfString("^[a-zA-Z\\.]*", options: .RegularExpressionSearch, range: nil, locale: nil) {
                    if !range.isEmpty {
                        var sub = script.substringWithRange(range)
                        var arr = sub.componentsSeparatedByString(".")
                        assert(arr.count == 2, "XML Constraint Script error : \(name)='\(script)'")
                        conf["second"] = arr[0]
                        conf["secondattribute"] = arr[1]
                    }
                }
                if let range = script.rangeOfString("[0-9-+*]+[0-9\\.]*", options: .RegularExpressionSearch, range: nil, locale: nil){
                    if !range.isEmpty {
                        var sub = script.substringWithRange(range)
                        var arr = sub.componentsSeparatedByString("*")
                        println(arr)
                        if arr.count > 0 { conf["constant"] = (arr[0] as NSString).floatValue}
                        if arr.count > 1 { conf["multiplier"] = (arr[1] as NSString).floatValue}
                    }
                }
                
                if let secondattribute = conf["secondattribute"] as? String {
                    if let attArr =  XMLStatic.XMLViewConstraintAttributeMap[secondattribute]{
                        conf["secondattribute"] = attArr[0].rawValue
                    }
                }
                if let attArr = XMLStatic.XMLViewConstraintAttributeMap[conf["firstattribute"] as! String] {
                    conf["firstattribute"] = attArr[0].rawValue
                    if attArr.count > 1 { conf["secondattribute"] = attArr[1].rawValue}
                }
                
                // 查找 second
                if let secondId = conf["second"] as? String {
                    if secondId == "super" || secondId == self.superview?.xml?.attributeForName("id").stringValue(){
                        conf["second"] = self.superview!    // superview 一定要存在，如果不存在，则这个时候是不能设置约束的
                    }else{
                        // 在兄弟间查找
                        for brother in self.superview!.subviews as! [UIView] {
                            if secondId == brother.xml?.attributeForName("id").stringValue() {
                                conf["second"] = brother
                            }
                        }
                    }
                }
                
                var firstView = conf["first"] as! UIView
                var secondView = conf["second"] as? UIView
                firstView.setTranslatesAutoresizingMaskIntoConstraints(false)
                var constraint = NSLayoutConstraint(item: firstView, attribute: NSLayoutAttribute(rawValue: conf["firstattribute"] as! Int)!, relatedBy: NSLayoutRelation.Equal, toItem: secondView, attribute: NSLayoutAttribute(rawValue: conf["secondattribute"] as! Int)!, multiplier: CGFloat(conf["multiplier"] as! Float), constant: CGFloat(conf["constant"] as! Float))
                
                if secondView == nil {
                    firstView.addConstraint(constraint)
                }else{
                    firstView.superview?.addConstraint(constraint)
                }
                
                if let constraint = (self as? XMLViewProtocol)?.constrainForName?(name, script: script) {
                }else{
                    
                }
                
                
            }
        }
        for subview in self.subviews as! [UIView]{
            if subview is XMLViewProtocol {
                subview.loadXMLConstraints()
            }
        }
    }
}

extension UIView {
    /**
    MARK: DOM 选择器
    :   $("View")   选择 class 为 View 的元素，返回数组
    :   $(".root")  选择 id 为 root 的元素，返回数组
    :   $("#root")  选择 tag 为 root 的元素, 返回数组
    */
}

class CMView: UIView, XMLViewProtocol {
    
}