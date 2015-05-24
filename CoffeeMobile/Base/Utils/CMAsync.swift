//
//  Async.swift
//  Async
//
//  Created by 程巍巍 on 3/31/15.
//  Copyright (c) 2015 Littocats. All rights reserved.
//
//  为 GCD 添加事务管理，类似 js 中 promise 的效果，
//  通过级连调用的提交的 dispatch_block_t 将按顺序执行

import Foundation

struct CMAsync {
    /**
    *   缓存将要执行的 dispatch_block_t
    *   如果关联事务（block) 被释放（例如销毁了 dispatch_queue_t)，后面的事务将被自动释放
    */
    private static var ChainedBlockTable = NSMapTable.weakToStrongObjectsMapTable()
    
    private let e_block: dispatch_block_t
    private init(_ block: dispatch_block_t, queue: dispatch_queue_t, interval: NSTimeInterval) {
        var _block = CMAsync.wrapBlock(block)
        
        if interval <= 0.0 {
            dispatch_async(queue, _block)
        }else{
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(NSEC_PER_SEC)*Int64(interval)), queue, _block)
        }
        self.e_block = block
    }
    private init(_ block: dispatch_block_t) {
        self.e_block = block
    }
    
    private func async(after interval: NSTimeInterval = 0.0, block: dispatch_block_t, inQueue queue: dispatch_queue_t) -> CMAsync {
        var _block: dispatch_block_t = { () -> Void in
            var __block = CMAsync.wrapBlock(block)
            if interval <= 0.0 {
                dispatch_async(queue, __block)
            }else{
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(NSEC_PER_SEC)*Int64(interval)), queue, __block)
            }
        }
        CMAsync.ChainedBlockTable.setObject(unsafeBitCast(_block, AnyObject.self), forKey: unsafeBitCast(self.e_block, AnyObject.self))
        return CMAsync(block)
    }
    
    private static func async(after interval: NSTimeInterval = 0.0, block: dispatch_block_t, inQueue queue: dispatch_queue_t) -> CMAsync {
        return CMAsync(block, queue: queue, interval: interval)
    }
    
    // block wrapper
    private static func wrapBlock(block: dispatch_block_t) ->dispatch_block_t{
        return { () -> Void in
            block()
            var n_block_obj: AnyObject? = CMAsync.ChainedBlockTable.objectForKey(unsafeBitCast(block, AnyObject.self))
            if n_block_obj == nil {return}
            var n_block = unsafeBitCast(n_block_obj, dispatch_block_t.self)
            n_block()
        }
    }
}

// MARK
extension CMAsync {
    /* dispatch_async() */
    static func main(block: dispatch_block_t) -> CMAsync {
        return CMAsync.async(block:block, inQueue: GCD.MainQueue)
    }
    static func interactive(block: dispatch_block_t) -> CMAsync {
        return CMAsync.async(block:block, inQueue: GCD.InteractiveQueue)
    }
    static func initiated(block: dispatch_block_t) -> CMAsync {
        return CMAsync.async(block:block, inQueue: GCD.InitiatedQueue)
    }
    static func utility(block: dispatch_block_t) -> CMAsync {
        return CMAsync.async(block:block, inQueue: GCD.UtilityQueue)
    }
    static func background(block: dispatch_block_t) -> CMAsync {
        return CMAsync.async(block:block, inQueue: GCD.BackgroundQueue)
    }
    static func customQueue(queue: dispatch_queue_t, block: dispatch_block_t) -> CMAsync {
        return CMAsync.async(block:block, inQueue: queue)
    }
    /* dispatch_after() */
    static func main(after interval: NSTimeInterval, block: dispatch_block_t) -> CMAsync {
        return CMAsync.async(after:interval, block:block, inQueue: GCD.MainQueue)
    }
    static func interactive(after interval: NSTimeInterval, block: dispatch_block_t) -> CMAsync {
        return CMAsync.async(after:interval, block:block, inQueue: GCD.InteractiveQueue)
    }
    static func initiated(after interval: NSTimeInterval, block: dispatch_block_t) -> CMAsync {
        return CMAsync.async(after:interval, block:block, inQueue: GCD.InitiatedQueue)
    }
    static func utility(after interval: NSTimeInterval, block: dispatch_block_t) -> CMAsync {
        return CMAsync.async(after:interval, block:block, inQueue: GCD.UtilityQueue)
    }
    static func background(after interval: NSTimeInterval, block: dispatch_block_t) -> CMAsync {
        return CMAsync.async(after:interval, block:block, inQueue: GCD.BackgroundQueue)
    }
    static func customQueue(after interval: NSTimeInterval, queue: dispatch_queue_t, block: dispatch_block_t) -> CMAsync {
        return CMAsync.async(after:interval, block:block, inQueue: queue)
    }
}

extension CMAsync {
    /* dispatch_async() */
    func main(block: dispatch_block_t) -> CMAsync {
        return async(block:block, inQueue: GCD.MainQueue)
    }
    func interactive(block: dispatch_block_t) -> CMAsync {
        return async(block:block, inQueue: GCD.InteractiveQueue)
    }
    func initiated(block: dispatch_block_t) -> CMAsync {
        return async(block:block, inQueue: GCD.InitiatedQueue)
    }
    func utility(block: dispatch_block_t) -> CMAsync {
        return async(block:block, inQueue: GCD.UtilityQueue)
    }
    func background(block: dispatch_block_t) -> CMAsync {
        return async(block:block, inQueue: GCD.BackgroundQueue)
    }
    func customQueue(queue: dispatch_queue_t, block: dispatch_block_t) -> CMAsync {
        return async(block:block, inQueue: queue)
    }
    /* dispatch_after() */
    func main(after interval: NSTimeInterval, block: dispatch_block_t) -> CMAsync {
        return async(after:interval, block:block, inQueue: GCD.MainQueue)
    }
    func interactive(after interval: NSTimeInterval, block: dispatch_block_t) -> CMAsync {
        return async(after:interval, block:block, inQueue: GCD.InteractiveQueue)
    }
    func initiated(after interval: NSTimeInterval, block: dispatch_block_t) -> CMAsync {
        return async(after:interval, block:block, inQueue: GCD.InitiatedQueue)
    }
    func utility(after interval: NSTimeInterval, block: dispatch_block_t) -> CMAsync {
        return async(after:interval, block:block, inQueue: GCD.UtilityQueue)
    }
    func background(after interval: NSTimeInterval, block: dispatch_block_t) -> CMAsync {
        return async(after:interval, block:block, inQueue: GCD.BackgroundQueue)
    }
    func customQueue(after interval: NSTimeInterval, queue: dispatch_queue_t, block: dispatch_block_t) -> CMAsync {
        return async(after:interval, block:block, inQueue: queue)
    }
}

extension CMAsync {
    private struct GCD {
        
        /* dispatch_get_queue() */
        static var MainQueue: dispatch_queue_t {
            return dispatch_get_main_queue()
        }
        static var InteractiveQueue: dispatch_queue_t {
            //  DISPATCH_QUEUE_PRIORITY_HIGH
            //            return dispatch_get_global_queue(Int(QOS_CLASS_USER_INTERACTIVE.value), 0)
            return dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)
        }
        static var InitiatedQueue: dispatch_queue_t {
            //  DISPATCH_QUEUE_PRIORITY_DEFAULT
            //            return dispatch_get_global_queue(Int(QOS_CLASS_DEFAULT.value), 0)
            return dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
        }
        static var UtilityQueue: dispatch_queue_t {
            //  DISPATCH_QUEUE_PRIORITY_LOW
            //            return dispatch_get_global_queue(Int(QOS_CLASS_UTILITY.value), 0)
            return dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0)
        }
        static var BackgroundQueue: dispatch_queue_t {
            //  DISPATCH_QUEUE_PRIORITY_BACKGROUND
            //            return dispatch_get_global_queue(Int(QOS_CLASS_BACKGROUND.value), 0)
            return dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)
        }
    }
}