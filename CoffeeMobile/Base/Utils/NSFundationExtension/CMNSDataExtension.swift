//
//  CMNSDataExtension.swift
//  CoffeeMobile
//
//  Created by 程巍巍 on 5/22/15.
//  Copyright (c) 2015 Littocats. All rights reserved.
//

import Foundation
import MiniZip

extension NSData {
    
    /**
    MARK: 压缩，尾部 8 byte 表示压缩前的长度 (UInt64)
    */
    func deflate() -> NSData! {
        var compressedLength = compressBound(uLong(self.length))
        
        var buffer = UnsafeMutablePointer<Bytef>.alloc(Int(compressedLength))
        var ret: NSMutableData?
        if Z_OK == compress(buffer, &compressedLength, UnsafePointer<Bytef>(self.bytes), uLong(self.length)) {
            var inflatedLength = UInt64(self.length)
            ret = NSMutableData(bytes: buffer, length: Int(compressedLength))
            ret?.appendBytes(&inflatedLength, length: sizeof(UInt64))
        }
        buffer.dealloc(1)
        return ret
    }
    
    /**
    MARK: 解压缩
    */
    func inflate() -> NSData!{
        var sourceLength: UInt64 = 0
        self.getBytes(&sourceLength, range: NSMakeRange(self.length - sizeof(UInt64), sizeof(UInt64)))
        var buffer = UnsafeMutablePointer<Bytef>.alloc(Int(sourceLength))
        var bufferLength = uLong(sourceLength)
        
        var ret: NSData?
        
        if Z_OK == uncompress(buffer, &bufferLength,  UnsafePointer<Bytef>(self.bytes), uLong(self.length - sizeof(UInt64))){
            ret = NSData(bytes: buffer, length: Int(bufferLength))
        }
        
        buffer.dealloc(1)
        return ret
    }
}

