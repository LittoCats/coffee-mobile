//
//  CMScanner.swift
//  CoffeeMobile
//
//  Created by 程巍巍 on 5/29/15.
//  Copyright (c) 2015 Littocats. All rights reserved.
//

import Foundation

class CMScanner {
    class Processor {
        var flag: AnyObject?
        
        /**
        process 不需要单独传入 当前 processor ，因为 stack 中最后一个 processor 一定是当前的 processor
        */
        var process:((buffer: NSMutableString, code: CChar, inout stack: [Processor])->Void)?
    }
    
    private var stack = [Processor]()
    
    
}