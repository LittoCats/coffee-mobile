//
//  UIControlExtension.swift
//  CoffeeMobile
//
//  Created by 程巍巍 on 5/20/15.
//  Copyright (c) 2015 Littocats. All rights reserved.
//

import UIKit

extension UIControl {
    typealias UIControlBlockHandler = @objc_block (sender: UIControl/* UIControl or subClass*/, event: UIControlEvents) ->Void
    /**
    *  为 events 添加 block 事件
    *  @discussion if block is nil , events handler will be removed if exist
    */
    func handle(#events: UIControlEvents, withBlock block: UIControlBlockHandler?) ->Self {
        var nameArr = BlockHandleSharedTarget.names(events: events)
        var table = blockTable
        for name in nameArr{
            table.removeObjectForKey(name)
            self.removeTarget(BlockHandleSharedTarget.self, action: Selector(name+":"), forControlEvents: BlockHandle.eventsTable[name]!)
            if block != nil {
                table.setObject(unsafeBitCast(block, AnyObject.self), forKey: name)
                self.addTarget(BlockHandleSharedTarget.self, action: Selector(name+":"), forControlEvents: BlockHandle.eventsTable[name]!)
            }
        }
        return self
    }
    
    private var blockTable: NSMapTable {
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
        static var onceToken: dispatch_once_t = 0
        static var BlockTableKey = "BlockTableKey"
        static let eventsTable = [
            "TouchDown"         :UIControlEvents.TouchDown,
            "TouchDownRepeat"   :UIControlEvents.TouchDownRepeat,
            "TouchDragInside"   :UIControlEvents.TouchDragInside,
            "TouchDragOutside"  :UIControlEvents.TouchDragOutside,
            "TouchDragEnter"    :UIControlEvents.TouchDragEnter,
            "TouchDragExit"     :UIControlEvents.TouchDragExit,
            "TouchUpInside"     :UIControlEvents.TouchUpInside,
            "TouchUpOutside"    :UIControlEvents.TouchUpOutside,
            "TouchCancel"       :UIControlEvents.TouchCancel,
            "ValueChanged"      :UIControlEvents.ValueChanged,
            "EditingDidBegin"   :UIControlEvents.EditingDidBegin,
            "EditingChanged"    :UIControlEvents.EditingChanged,
            "EditingDidEnd"     :UIControlEvents.EditingDidEnd,
            "EditingDidEndOnExit":UIControlEvents.EditingDidEndOnExit
        ]
        static var handler: BlockHandleSharedTarget!
    }
    @objc private final class  BlockHandleSharedTarget: NSObject {
        class func names(#events: UIControlEvents) ->[String]{
            var nameArr = [String]()
            for item in BlockHandle.eventsTable {
                if events & item.1 == item.1 {
                    nameArr.append(item.0)
                }
            }
            return nameArr
        }
        class func handle(#event: String, sender: UIControl)->Void{
            var blockObject: AnyObject? = sender.blockTable.objectForKey(event)
            if blockObject == nil {return}
            var block = unsafeBitCast(blockObject, UIControlBlockHandler.self)
            block(sender: sender, event: BlockHandle.eventsTable[event]!)
        }
        
        @objc class func TouchDown              (sender: UIControl)->Void{handle(event: "TouchDown", sender: sender)}
        @objc class func TouchDownRepeat        (sender: UIControl)->Void{handle(event: "TouchDownRepeat", sender: sender)}
        @objc class func TouchDragInside        (sender: UIControl)->Void{handle(event: "TouchDragInside", sender: sender)}
        @objc class func TouchDragOutside       (sender: UIControl)->Void{handle(event: "TouchDragOutside", sender: sender)}
        @objc class func TouchDragEnter         (sender: UIControl)->Void{handle(event: "TouchDragEnter", sender: sender)}
        @objc class func TouchDragExit          (sender: UIControl)->Void{handle(event: "TouchDragExit", sender: sender)}
        @objc class func TouchUpInside          (sender: UIControl)->Void{handle(event: "TouchUpInside", sender: sender)}
        @objc class func TouchUpOutside         (sender: UIControl)->Void{handle(event: "TouchUpOutside", sender: sender)}
        @objc class func TouchCancel            (sender: UIControl)->Void{handle(event: "TouchCancel", sender: sender)}
        @objc class func ValueChanged           (sender: UIControl)->Void{handle(event: "ValueChanged", sender: sender)}
        @objc class func EditingDidBegin        (sender: UIControl)->Void{handle(event: "EditingDidBegin", sender: sender)}
        @objc class func EditingChanged         (sender: UIControl)->Void{handle(event: "EditingChanged", sender: sender)}
        @objc class func EditingDidEnd          (sender: UIControl)->Void{handle(event: "EditingDidEnd", sender: sender)}
        @objc class func EditingDidEndOnExit    (sender: UIControl)->Void{handle(event: "EditingDidEndOnExit", sender: sender)}
    }
}