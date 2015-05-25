//
//  CMView.swift
//  CoffeeMobile
//
//  Created by 程巍巍 on 5/20/15.
//  Copyright (c) 2015 Littocats. All rights reserved.
//

import UIKit
import XMLNode

protocol CMViewProtocol {
    init(xml: String)
    static var XMLClassMap: [String: UIView.Type] {get}
}


extension UIView {
    private struct XMLStatic {
        static var xmlAssociatedKey = "xmlAssociatedKey"
        static var contextAssociatedKey = "contextAssociatedKey"
        static var nidMap = NSMapTable.strongToWeakObjectsMapTable()
    }
    var xml: XMLElement? {
        return objc_getAssociatedObject(self, &XMLStatic.xmlAssociatedKey) as? XMLElement
    }
    
    var nid: String {
        return String(format: "nid_%p", self)
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
    var context: CMContext? {
        return (hostViewController() as? CMViewController)?.context
    }
    
    /**
    MARK: convenience init with xml
    */
    convenience init(xml: XMLElement) {
        self.init()
        XMLStatic.nidMap.setObject(self, forKey: nid)
        objc_setAssociatedObject(self, &XMLStatic.xmlAssociatedKey, xml, objc_AssociationPolicy(OBJC_ASSOCIATION_RETAIN_NONATOMIC))
        
        // 将 native id 添加到 xnlelement 中，方便 选择器 查找
        var nativeId = XMLNode.attributeWithName("_id", stringValue: nid) as! XMLNode
        xml.addAttribute(nativeId)
        
        //
        loadXMLSyle()
        
        //
        loadXMLChildren()
    }
    
    /**
    MARK: 根据 xml 属性，设置 view 的属性
    子类中必须调用 super  方法
    */
    func loadXMLSyle() {
        
    }
    
    /**
    MARK: 根据 xml 属性，添加约束, 自动调用，不要手动调用
    */
    func loadXMLConstraints() {
        
    }
    
    /**
    MARK: 根据 xml children，添加subviews, 自动调用，不要手动调用
    */
    func loadXMLChildren() {
        
    }
}