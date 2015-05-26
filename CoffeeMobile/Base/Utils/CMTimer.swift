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
    private weak var context: AnyObject?
    
    
    private init(interval: NSTimeInterval, repeat: Bool = false, userInfo: AnyObject? = nil, strict: Bool = false, context: AnyObject? = nil, function: CMTimerFunction){
        self.touple = (userInfo, strict, repeat, interval, function)
        self.thread = NSThread.currentThread()
        if context == nil {
            self.context = self
        }else{
            self.context = context
        }
        
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
                var nowInterval = NSDate.timeIntervalSinceReferenceDate()
                while nextExcuteTime <= nowInterval {
                    self.excuteFunction(&shouldStop)
                    if shouldStop {
                        return
                    }
                    self.repeatCount++
                    nextExcuteTime = self.startTime + self.interval * self.repeatCount
                }
                self.excuteStrict(nextExcuteTime - nowInterval)
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
        if thread == nil || self.context == nil {
            shouldStop = true
            return
        }
        NSThread.evalOnThread(thread!, waitUntilDon: true) { () -> Void in
            shouldStop = self.function(timer: self)
        }
    }
    
    /**
    MARK: GCD timer, 通过GCD任务管理的 timer ，触发时间受 runloop 影响，会有一定延迟
    :param: strict 表是否是严格模式，严格模式下，触发次数不会受到 runloop 延迟影响， 并根据延迟情况，自动校正触发时间
    :param: context timer 邦定的对像，对像释放后，timer 自动停止并释放
    */
    static func timeOut(interval: NSTimeInterval, repeat: Bool = false, userInfo: AnyObject? = nil, strict: Bool = false, context: AnyObject? = nil, function: CMTimerFunction) {
        CMTimer(interval: interval, repeat: repeat, userInfo: userInfo, strict: strict,context: context, function: function)
    }
}