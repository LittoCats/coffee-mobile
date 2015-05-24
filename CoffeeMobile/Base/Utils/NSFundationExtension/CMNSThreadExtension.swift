//
//  NSThreadExtension.swift
//  CoffeeMobile
//
//  Created by 程巍巍 on 5/21/15.
//  Copyright (c) 2015 Littocats. All rights reserved.
//

import Foundation


extension NSThread {
    
    static func evalOnThread(thread: NSThread, waitUntilDon wait: Bool, closure: dispatch_block_t){
        if thread == NSThread.currentThread() {
            return closure()
        }
        Sync(closure: closure).evalSelector("excute", onThread: thread, waitUntilDone: wait)
    }
    
    private class Sync: NSObject {
        
        private static var onceToken: dispatch_once_t = 0
        override class func initialize(){
            dispatch_once(&onceToken, { () -> Void in
                var method = class_getInstanceMethod(NSObject.self, "evalSelector:onThread:withObject:waitUntilDone:modes:")
                var _method = class_getInstanceMethod(NSObject.self, "performSelector:onThread:withObject:waitUntilDone:modes:")
                method_exchangeImplementations(method, _method)
            })
        }
        
        var closure: dispatch_block_t
        init(closure: dispatch_block_t) {
            self.closure = closure
        }
        
        @objc func excute() {
            self.closure()
        }
    }
}

extension NSObject {
    @objc private func evalSelector(selector: Selector, onThread thread: NSThread, withObject arg: AnyObject? = nil, waitUntilDone wait: Bool = true, modes array: [String] = [NSDefaultRunLoopMode]) {
        evalSelector(selector, onThread: thread, withObject: arg, waitUntilDone: wait, modes: array)
    }
}