//
//  UIAlertViewExtension.swift
//  CoffeeMobile
//
//  Created by 程巍巍 on 5/20/15.
//  Copyright (c) 2015 Littocats. All rights reserved.
//

import UIKit

extension UIAlertView {
    typealias UIAlertViewDismissHandler = @objc_block(view: UIAlertView, atIndex: Int) -> Void
    convenience init(title: String?, message: String?, cancelButtonTitle: String?, cancelHandler: UIAlertViewDismissHandler? = nil){
        self.init(title: title, message: message, delegate: BlockHandleSharedTarget.self, cancelButtonTitle:cancelButtonTitle)
        if cancelHandler == nil || cancelButtonTitle == nil{return}
        self.blockTable.setObject(unsafeBitCast(cancelHandler!, AnyObject.self), forKey: String(self.numberOfButtons - 1))
    }
    
    func add(button buttonTitle: String, handler: UIAlertViewDismissHandler? = nil) ->Self{
        self.addButtonWithTitle(buttonTitle)
        if handler != nil {
            self.blockTable.setObject(unsafeBitCast(handler!, AnyObject.self), forKey: String(self.numberOfButtons - 1))
        }
        return self
    }
    
    @objc private class BlockHandleSharedTarget: NSObject, UIAlertViewDelegate {
        @objc class func alertView(alertView: UIAlertView, didDismissWithButtonIndex buttonIndex: Int){
            var blockObject: AnyObject? = alertView.blockTable.objectForKey(String(buttonIndex))
            if blockObject == nil {return}
            var block = unsafeBitCast(blockObject, UIAlertViewDismissHandler.self)
            block(view: alertView, atIndex: buttonIndex)
        }
    }
    private var blockTable: NSMapTable{
        get{
            var table = objc_getAssociatedObject(self, &BlockHandle.BlockTableKey) as? NSMapTable
            if table == nil {
                table = NSMapTable.strongToStrongObjectsMapTable()
                objc_setAssociatedObject(self, &BlockHandle.BlockTableKey, table, objc_AssociationPolicy(OBJC_ASSOCIATION_RETAIN))
            }
            return table!
        }
    }
    private struct BlockHandle {
        static var BlockTableKey = "BlockTableKey"
    }
}

extension UIActionSheet {
    typealias UIActionSheetDismissHandler = @objc_block (view: UIActionSheet, atIndex: Int) -> Void
    convenience init(title: String?, cancelButtonTitle: String, dismissHandler: UIActionSheetDismissHandler? = nil) {
        self.init(title: title, delegate: unsafeBitCast(BlockHandleSharedTarget.self, UIActionSheetDelegate.self), cancelButtonTitle: cancelButtonTitle, destructiveButtonTitle: nil)
        if dismissHandler == nil {return}
        self.blockTable.setObject(unsafeBitCast(dismissHandler!, AnyObject.self), forKey: String(self.numberOfButtons - 1))
    }
    
    func add(button buttonTitle: String, handler: UIActionSheetDismissHandler? = nil) ->Self{
        self.addButtonWithTitle(buttonTitle)
        if handler != nil {
            self.blockTable.setObject(unsafeBitCast(handler!, AnyObject.self), forKey: String(self.numberOfButtons - 1))
        }
        return self
    }
    
    @objc private class BlockHandleSharedTarget: NSObject, UIActionSheetDelegate {
        @objc class func actionSheet(actionSheet: UIActionSheet, didDismissWithButtonIndex buttonIndex: Int){
            var blockObject: AnyObject? = actionSheet.blockTable.objectForKey(String(buttonIndex))
            if blockObject == nil {return}
            var block = unsafeBitCast(blockObject, UIActionSheetDismissHandler.self)
            block(view: actionSheet, atIndex: buttonIndex)
        }
    }
    
    private var blockTable: NSMapTable{
        get{
            var table = objc_getAssociatedObject(self, &BlockHandle.BlockTableKey) as? NSMapTable
            if table == nil {
                table = NSMapTable.strongToStrongObjectsMapTable()
                objc_setAssociatedObject(self, &BlockHandle.BlockTableKey, table, objc_AssociationPolicy(OBJC_ASSOCIATION_RETAIN))
            }
            return table!
        }
    }
    private struct BlockHandle {
        static var BlockTableKey = "BlockTableKey"
    }
}