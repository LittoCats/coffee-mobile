//
//  CMConstraint.swift
//  CoffeeMobile
//
//  Created by 程巍巍 on 5/24/15.
//  Copyright (c) 2015 Littocats. All rights reserved.
//

import Foundation
import UIKit

struct CMLayout {
    
    private var item: AnyObject
    
    init(_ item: AnyObject){
        self.item = item
        if let view = item as? UIView {
            view.setTranslatesAutoresizingMaskIntoConstraints(false)
        }
    }
    
    var Left:       Attribute {return Attribute(item: item, attribute: NSLayoutAttribute.Left)}
    var Right:      Attribute {return Attribute(item: item, attribute: NSLayoutAttribute.Right)}
    var Top:        Attribute {return Attribute(item: item, attribute: NSLayoutAttribute.Top)}
    var Bottom:     Attribute {return Attribute(item: item, attribute: NSLayoutAttribute.Bottom)}
    var Leading:    Attribute {return Attribute(item: item, attribute: NSLayoutAttribute.Leading)}
    var Trailing:   Attribute {return Attribute(item: item, attribute: NSLayoutAttribute.Trailing)}
    var Width:      Attribute {return Attribute(item: item, attribute: NSLayoutAttribute.Width)}
    var Height:     Attribute {return Attribute(item: item, attribute: NSLayoutAttribute.Height)}
    var CenterX:    Attribute {return Attribute(item: item, attribute: NSLayoutAttribute.CenterX)}
    var CenterY:    Attribute {return Attribute(item: item, attribute: NSLayoutAttribute.CenterY)}
    var Baseline:   Attribute {return Attribute(item: item, attribute: NSLayoutAttribute.Baseline)}
    
    struct Attribute {
        private var item: AnyObject
        private var attribute: NSLayoutAttribute
        
        var LessOrEqual:    Relation {return Relation(item: item, attribute: attribute, relation: NSLayoutRelation.LessThanOrEqual)}
        var Equal:          Relation {return Relation(item: item, attribute: attribute, relation: NSLayoutRelation.Equal)}
        var GreaterOrEqual: Relation {return Relation(item: item, attribute: attribute, relation: NSLayoutRelation.GreaterThanOrEqual)}
        
        struct Relation {
            private var item: AnyObject
            private var attribute: NSLayoutAttribute
            private var relation: NSLayoutRelation
            
            func constraint(_ constant: CGFloat = 0,_ multiplier: CGFloat = 1)-> NSLayoutConstraint {
                return NSLayoutConstraint(item: item, attribute: attribute, relatedBy: relation, toItem: nil, attribute: .NotAnAttribute, multiplier: multiplier, constant: constant)
            }
            
            func to(item: AnyObject) ->ToItem {
                return ToItem(item: self.item, attribute: attribute, relation: relation, toItem: item)
            }
            
            struct ToItem {
                private var item: AnyObject
                private var attribute: NSLayoutAttribute
                private var relation: NSLayoutRelation
                private var toItem: AnyObject
                
                var Left:       Build {return Build(item: item, attribute: (attribute, NSLayoutAttribute.Left), relation: relation, toItem: toItem)}
                var Right:      Build {return Build(item: item, attribute: (attribute, NSLayoutAttribute.Right), relation: relation, toItem: toItem)}
                var Top:        Build {return Build(item: item, attribute: (attribute, NSLayoutAttribute.Top), relation: relation, toItem: toItem)}
                var Bottom:     Build {return Build(item: item, attribute: (attribute, NSLayoutAttribute.Bottom), relation: relation, toItem: toItem)}
                var Leading:    Build {return Build(item: item, attribute: (attribute, NSLayoutAttribute.Leading), relation: relation, toItem: toItem)}
                var Trailing:   Build {return Build(item: item, attribute: (attribute, NSLayoutAttribute.Trailing), relation: relation, toItem: toItem)}
                var Width:      Build {return Build(item: item, attribute: (attribute, NSLayoutAttribute.Width), relation: relation, toItem: toItem)}
                var Height:     Build {return Build(item: item, attribute: (attribute, NSLayoutAttribute.Height), relation: relation, toItem: toItem)}
                var CenterX:    Build {return Build(item: item, attribute: (attribute, NSLayoutAttribute.CenterX), relation: relation, toItem: toItem)}
                var CenterY:    Build {return Build(item: item, attribute: (attribute, NSLayoutAttribute.CenterY), relation: relation, toItem: toItem)}
                var Baseline:   Build {return Build(item: item, attribute: (attribute, NSLayoutAttribute.Baseline), relation: relation, toItem: toItem)}
                
                
                struct Build {
                    private var item: AnyObject
                    private var attribute: (NSLayoutAttribute, NSLayoutAttribute)
                    private var relation: NSLayoutRelation
                    private var toItem: AnyObject
                    
                    func constraint(_ constant: CGFloat = 0,_ multiplier: CGFloat = 1)-> NSLayoutConstraint {
                        return NSLayoutConstraint(item: item, attribute: attribute.0, relatedBy: relation, toItem: toItem, attribute: attribute.1, multiplier: multiplier, constant: constant)
                    }
                }
            }
        }
    }
}

extension NSLayoutConstraint {
    func addTo(view: UIView) {
        view.addConstraint(self)
    }
}
