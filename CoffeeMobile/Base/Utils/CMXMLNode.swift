//
//  CMXMLNode.swift
//  CoffeeMobile
//
//  Created by 程巍巍 on 5/23/15.
//  Copyright (c) 2015 Littocats. All rights reserved.
//

import Foundation
import XMLNode

/**
MARK:   搜索过程，由上至下，即，只搜索兄弟元素和子元素
*/
extension XMLElement {
    func childrenWithId(cid: String)->[XMLElement] {
        return childrenWithAttribute("id", andValue: cid)
    }
    func childrenWithTag(tag: String)->[XMLElement] {
        return childrenWithAttribute("tag", andValue: tag)
    }
    
    private func childrenWithAttribute(attribute: String, andValue value: String) ->[XMLElement] {
        var child = [XMLElement]()
        if let subeles = self.children() as? [XMLElement] {
            for ele in subeles {
                if let avalue = ele.attributeForName(attribute).stringValue(){
                    if avalue == value {child.append(ele)}
                }
                for subchildren in ele.childrenWithAttribute(attribute, andValue: value) {
                    child.append(subchildren)
                }
            }
        }
        
        return child
    }
}

