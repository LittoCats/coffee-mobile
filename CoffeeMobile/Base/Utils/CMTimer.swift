//
//  CMTimer.swift
//  CoffeeMobile
//
//  Created by 程巍巍 on 5/20/15.
//  Copyright (c) 2015 Littocats. All rights reserved.
//

import Foundation


final class CMTimer {
    
    typealias CMTimerFunction = (timer: CMTimer)->(Bool)
    
    private var touple: (userInfo: AnyObject?, strict: Bool, repeat: Bool, interval: NSTimeInterval, function: CMTimerFunction)!
    private weak var thread: NSThread?
    
    var userInfo: AnyObject?{return touple.userInfo}
    var strict: Bool {return touple.strict}
    var repeat: Bool {return touple.repeat}
    var function: CMTimerFunction {return touple.function}
    var interval: NSTimeInterval {return touple.interval}
    
    var valid: Bool = true
    
    private var startTime: NSTimeInterval = NSDate.timeIntervalSinceReferenceDate()
    private var repeatCount: NSTimeInterval = 0
    
    private init(interval: NSTimeInterval, repeat: Bool = false, userInfo: AnyObject? = nil, strict: Bool = false, function: CMTimerFunction){
        self.touple = (userInfo, strict, repeat, interval, function)
        
        self.thread = NSThread.currentThread()
        
        if strict {
            excuteStrict(interval)
        }else{
            excute()
        }
    }
    
    // NSTimer reciever
    private func excuteStrict(inteval: NSTimeInterval){
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(NSEC_PER_SEC)*Int64(interval)), dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)) { () -> Void in
            if !self.valid {return}
            var shouldStop = true
            self.excuteFunction(&shouldStop)
            if !shouldStop && self.repeat{
                self.repeatCount++
                var nextExcuteTime = self.startTime + self.interval * self.repeatCount
                self.excuteStrict(nextExcuteTime - NSDate.timeIntervalSinceReferenceDate())
            }
        }
    }
    
    // gcd reciever
    private func excute(){
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(NSEC_PER_SEC)*Int64(interval)), dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)) { () -> Void in
            if !self.valid {return}
            var shouldStop = true
            self.excuteFunction(&shouldStop)
            if !shouldStop && self.repeat{
                self.excute()
            }
        }
    }
    
    //
    private func excuteFunction(inout shouldStop: Bool) {
        if thread == nil {shouldStop = true}
        NSThread.evalOnThread(thread!, waitUntilDon: true) { () -> Void in
            shouldStop = self.function(timer: self)
        }
    }
    
    static func timeOut(interval: NSTimeInterval, repeat: Bool = false, userInfo: AnyObject? = nil, strict: Bool = false, function: CMTimerFunction) {
        CMTimer(interval: interval, repeat: repeat, userInfo: userInfo, strict: strict, function: function)
    }
}