//
//  CMZip.swift
//  CoffeeMobile
//
//  Created by 程巍巍 on 5/21/15.
//  Copyright (c) 2015 Littocats. All rights reserved.
//

import Foundation
import MiniZip

struct CMZip {
   
    /**
    MARK: 压缩等级
    */
    enum CompressionLevel: Int32, Printable {
        case Default        = -1
        case None           = 0
        case Fastest        = 1
        case Best           = 9
        
        var description: String {
            switch self {
            case .Default: return "Default"
            case .None:     return "None"
            case .Fastest: return "Fastest"
            case .Best:     return "Best"
            }
        }
    }
    
    /**
    MARK: 写入流
    */
    class ReadStream {
        private var store: (fileNameInZip: String, uzFile: unzFile)!
        var fileNameInZip: String {return store.fileNameInZip}
        
        init(uzFile: unzFile, nameInZip name: String){
            store = (name, uzFile)
        }
        
        func readDataToBuffer(buffer: NSMutableData) {
            var err = unzReadCurrentFile(store.uzFile, buffer.mutableBytes, UInt32(buffer.length))
            if err != ZIP_OK {
                Exception(error: err, reason: "Error reading '\(store.fileNameInZip)' in the zipfile").raise()
            }
        }
        
        func endReading() {
            var err = unzCloseCurrentFile(store.uzFile)
            if err != ZIP_OK {
                Exception(error: err, reason: "Error closing '\(store.fileNameInZip)' in the zipfile").raise()
            }
        }
    }
    /**
    MARK: 读取流
    */
    class WriteStream {
        private var store: (fileNameInZip: String, zFile: zipFile)!
        var fileNameInZip: String {return store.fileNameInZip}
        
        private init(zFile: zipFile, nameInZip name: String){
            store = (name, zFile)
        }
        
        func writeData(data: NSData) {
            var err = zipWriteInFileInZip(store.zFile, data.bytes, UInt32(data.length))
            if err != ZIP_OK {
                Exception(error: err, reason: "Error writing '\(store.fileNameInZip)' in the zipfile").raise()
            }
        }
        
        func endWriting() {
            var err = zipCloseFileInZip(store.zFile)
            if err != ZIP_OK {
                Exception(error: err, reason: "Error closing '\(store.fileNameInZip)' in the zipfile").raise()
            }
        }
    }
    
    /**
    MARK: ZIP 文件信息
    */
    class Infomation: Printable {
        
        private var store: (length: Int, level: CompressionLevel, crypted: Bool, size: Int, date: NSDate, crc32: UInt, name: String)!
        
        var length: Int {return store.length}
        var level: CompressionLevel {return store.level}
        var crypted: Bool {return store.crypted}
        var size: Int {return store.size}
        var date: NSDate {return store.date}
        var crc32: UInt {return store.crc32}
        var name: String {return store.name}
        
        private init(name: String, length: Int, level: CompressionLevel, crypted: Bool, size: Int, date: NSDate, crc32: UInt){
            self.store = (length, level, crypted, size, date, crc32, name)
        }
        
        var description: String {
            return "\nname:\(name)\ndate:\(date)\nlength:\(length)\nsize:\(size)\ncrypted:\(crypted)\nlevel:\(level)\ncrc:\(crc32)\n"
        }
    }
    
    /**
    MARK: 异常
    */
    class Exception: NSException {
        private var store: (error: Int32, reason: String)!
        var error: Int32 {return store.error}
        
        init(reason: String){
            super.init(name: "CMZipException", reason: reason, userInfo: nil)
            store = (0, reason)
        }
        init(error: Int32, reason: String){
            super.init(name: "CMZipException", reason: reason, userInfo: ["error": Int(error)])
            store = (error, reason)
        }
        required init(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
    
    /**
    MARK: ZIP file
    */
    class File {
        
        enum Mode {
            case Unzip
            case Create
            case Append
        }
        private var store: (fileName: String, mode: Mode) = (fileName: "", mode: .Unzip)
        var fileName: String!{return store.fileName}
        var mode: Mode!{return store.mode}
        
        private var zFile: zipFile?
        private var uzFile: unzFile?
        
        init(fileName: String, mode: Mode){
            store.fileName = fileName
            store.mode = mode
            
            switch mode {
            case .Unzip:    uzFile = unzOpen64(fileName.cStringUsingEncoding(NSUTF8StringEncoding)!)
                if uzFile == nil {Exception(reason: "Can not open '\(fileName)'").raise()}
            case .Create:   zFile = zipOpen64(fileName.cStringUsingEncoding(NSUTF8StringEncoding)!, APPEND_STATUS_CREATE)
                if zFile == nil {Exception(reason: "Can not open '\(fileName)'").raise()}
            case .Append:   zFile = zipOpen64(fileName.cStringUsingEncoding(NSUTF8StringEncoding)!, APPEND_STATUS_ADDINZIP)
                if zFile == nil {Exception(reason: "Can not open '\(fileName)'").raise()}
            }
        }
        
        /**
            MARK: 获取一个新的写入流
        */
        func writeFileInZip(#name: String, date: NSDate, level: CompressionLevel, passwd: String?, crc32: UInt) ->WriteStream {
            if mode == .Unzip {
                Exception(reason: "Operation not permitted with Unzip mode").raise()
            }
            
            var calendar = NSCalendar.currentCalendar()
            var components = calendar.components(.CalendarUnitYear | .CalendarUnitMonth | .CalendarUnitDay | .CalendarUnitHour | .CalendarUnitMinute | .CalendarUnitSecond, fromDate: date)
            
            var zi = zip_fileinfo()
            zi.tmz_date.tm_sec  = uInt(components.second)
            zi.tmz_date.tm_min  = uInt(components.minute)
            zi.tmz_date.tm_hour = uInt(components.hour)
            zi.tmz_date.tm_mday = uInt(components.day)
            zi.tmz_date.tm_mon  = uInt(components.month - 1)
            zi.tmz_date.tm_year = uInt(components.year)
            zi.internal_fa      = 0
            zi.external_fa      = 0
            zi.dosDate          = 0
            
            
            
            var zipfi = UnsafeMutablePointer<zip_fileinfo>.alloc(1)
            zipfi.initialize(zi)
            
            var err = zipOpenNewFileInZip3_64(
                zFile!,
                UnsafePointer<Int8>(name.cStringUsingEncoding(NSUTF8StringEncoding)!),
                zipfi,
                nil,0,nil,0,nil,
                level != .None ? Z_DEFLATED : 0,
                level.rawValue, 0,
                -MAX_WBITS, DEF_MEM_LEVEL, Z_DEFAULT_STRATEGY,
                passwd != nil ? UnsafePointer<Int8>(passwd!.cStringUsingEncoding(NSUTF8StringEncoding)!) : nil, crc32, 1)
            zipfi.dealloc(1)
            if err != ZIP_OK {
                Exception(error: err, reason: "Error opening '\(fileName)' in zipfile").raise()
            }
            return WriteStream(zFile: zFile!, nameInZip: fileName)
        }
        
        /**
        MARK: 获取读取流
        */
        
        func readCurrentFile(#passwd: String) ->ReadStream {
            if mode != .Unzip {
                Exception(reason: "Operation not permitted without Unzip mode").raise()
            }
            
            var filename_inzip = [CChar](count: 256, repeatedValue: 0)
            
            var file_info = unz_file_info64()
            var file_info_ptr = UnsafeMutablePointer<unz_file_info64>.alloc(1)
            file_info_ptr.initialize(file_info)
            
            var err = unzGetCurrentFileInfo64(uzFile!, file_info_ptr, UnsafeMutablePointer<Int8>(filename_inzip), uLong(sizeofValue(filename_inzip)), UnsafeMutablePointer<Void>.alloc(0), 0, UnsafeMutablePointer<Int8>.alloc(0), 0)
            
            if err != UNZ_OK {
                Exception(reason: "Error getting current file info in '\(fileName)'").raise()
            }
            
            var name = String(CString: UnsafePointer<CChar>(filename_inzip), encoding: NSUTF8StringEncoding)
            
            if passwd.isEmpty {
                err = unzOpenCurrentFile(uzFile!)
            }else{
                err = unzOpenCurrentFilePassword(uzFile!, passwd.cStringUsingEncoding(NSUTF8StringEncoding)!)
            }
            return ReadStream(uzFile: uzFile!, nameInZip: name!)
        }
        
        func close() {
            var err: Int32
            switch self.mode! {
            case .Unzip:
                err = unzClose(uzFile!)
                if err != UNZ_OK {
                    Exception(error: err, reason: "Error closing '\(fileName)'").raise()
                }
            case .Append, .Create:
                err = zipClose(zFile!, nil)
                if err != ZIP_OK {
                    Exception(error: err, reason: "Error closing '\(fileName)'").raise()
                }
            }
        }
        
        /**
            MARK: 获取 ZIP 文件信息 只有 mode 为 Unzip 时可用
        */
        var numberOfFiles: Int {
            if mode != .Unzip {
                Exception(reason: "Operation not permitted without Unzip mode").raise()
            }
            var gi = unz_global_info64()
            var err = unzGetGlobalInfo64(uzFile!, &gi)
            if err != UNZ_OK {
                Exception(error: err, reason: "Error getting global info in \(fileName)")
            }
            return Int(gi.number_entry)
        }
        
        
        var fileList: [Infomation] {
            var ret = [Infomation]()
            var num = numberOfFiles
            println(num)
            self.gotoFirstFile()
            if num > 0 {
                for i in 0..<num {
                    ret.append(self.currentFileInfomation())
                    if i < num - 1 {
                        self.gotoNextFile()
                    }
                }
            }
            return ret
        }
        
        /**
        MARK: 私用方法
        */
        private func gotoFirstFile() {
            if mode != .Unzip {
                Exception(reason: "Operation not permitted without Unzip mode").raise()
            }
            var err = unzGoToFirstFile(uzFile!)
            if err != UNZ_OK {
                Exception(error: err, reason: "Error going to first file in zip in '\(fileName)'").raise()
            }
        }
        
        private func gotoNextFile()->Bool {
            if mode != .Unzip {
                Exception(reason: "Operation not permitted without Unzip mode").raise()
            }
            
            var err = unzGoToNextFile(uzFile!)
            if err == UNZ_END_OF_LIST_OF_FILE {
                return false
            }
            if err != UNZ_OK {
                Exception(error: err, reason: "Error going to next file in zip in '\(fileName)'").raise()
            }
            return true
        }
        
        private func locateFile(name: String) ->Bool {
            if mode != .Unzip {
                Exception(reason: "Operation not permitted without Unzip mode").raise()
            }
            
            var err = unzLocateFile(uzFile!, name.cStringUsingEncoding(NSUTF8StringEncoding)!, nil)
            if err == UNZ_END_OF_LIST_OF_FILE {
                return false
            }
            if err != UNZ_OK {
                Exception(error: err, reason: "Error localting file in zip in '\(fileName)'").raise()
            }
            return true
        }

        func currentFileInfomation() ->Infomation {
            if mode != .Unzip {
                Exception(reason: "Operation not permitted without Unzip mode").raise()
            }
            
            var filename_inzip = [CChar](count: 256, repeatedValue: 0)
            
            var file_info_ptr = UnsafeMutablePointer<unz_file_info64>.alloc(1)
            
            var err = unzGetCurrentFileInfo64(uzFile!, file_info_ptr, UnsafeMutablePointer<Int8>(filename_inzip), uLong(256), UnsafeMutablePointer<Void>.alloc(0), 0, UnsafeMutablePointer<Int8>.alloc(0), 0)
            
            if err != UNZ_OK {
                Exception(reason: "Error getting current file info in '\(fileName)'").raise()
            }
            var file_info = file_info_ptr.memory
            
            var name = String(CString: UnsafePointer<CChar>(filename_inzip), encoding: NSUTF8StringEncoding)
            var level = CompressionLevel.None
            if file_info.compression_method != 0 {
                var levelCode = (file_info.flag & 0x6) / 2
                if let lev = CompressionLevel(rawValue: Int32(levelCode)) {
                    level = lev
                }else{
                    level = .Best
                }
            }
            
            var crypted = (file_info.flag & 1) != 0
            
            var components      = NSDateComponents()
            components.year     = Int(file_info.tmu_date.tm_year)
            components.month    = Int(file_info.tmu_date.tm_mon + 1)
            components.day      = Int(file_info.tmu_date.tm_mday)
            components.hour     = Int(file_info.tmu_date.tm_hour)
            components.minute   = Int(file_info.tmu_date.tm_min)
            components.second   = Int(file_info.tmu_date.tm_sec)
            
            var calendar = NSCalendar()
            var date = calendar.dateFromComponents(components)
            
            var infomation = Infomation(name: name!, length: Int(file_info.uncompressed_size), level: level, crypted: crypted, size: Int(file_info.compressed_size), date: date != nil ? date! : NSDate(), crc32: UInt(file_info.crc))
            
            return infomation
        }
    }
}

extension CMZip {
    /**
    MARK: 压缩文件、文件夹
    */
    static func compressFileAtPath(path: String, withPassword password: String?) ->String {
        var tempPath = NSTemporaryDirectory().stringByAppendingPathComponent("CMZip_Tmp_\(Int(NSDate.timeIntervalSinceReferenceDate()*1000)).zip")
        var zipFile = File(fileName: tempPath, mode: .Create)
        var fileManager = NSFileManager.defaultManager()
        compressItem(path, toZIPFile: zipFile, password: password, fileManager: fileManager, workPath: path.stringByDeletingLastPathComponent)
        zipFile.close()
        return tempPath
    }
    
    private static func compressItem(item: String, toZIPFile file: File, password: String?, fileManager: NSFileManager, workPath: String) {
        var isDir = UnsafeMutablePointer<ObjCBool>.alloc(sizeof(ObjCBool))
        if fileManager.fileExistsAtPath(item, isDirectory: isDir){
            var readStream = file.writeFileInZip(name: item.stringByReplacingOccurrencesOfString(workPath, withString: "", options: NSStringCompareOptions.allZeros, range: nil), date: NSDate(), level: CMZip.CompressionLevel.Best, passwd: password, crc32: 0)
            if isDir.memory.boolValue {
                readStream.endWriting()
                var errPtr = NSErrorPointer()
                var subItems = fileManager.contentsOfDirectoryAtPath(item, error: errPtr)
                if errPtr != nil || subItems == nil {return}
                for subItem in subItems! {
                    if let sub = subItem as? String{
                        compressItem(item.stringByAppendingPathComponent(sub), toZIPFile: file, password: password, fileManager: fileManager, workPath: workPath)
                    }
                }
            }else{
                if let data = NSData(contentsOfFile: item) {
                    readStream.writeData(data)
                }
                readStream.endWriting()
            }
        }
    }
}