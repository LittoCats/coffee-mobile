//
//  CMNSURLExtension.swift
//  CoffeeMobile
//
//  Created by 程巍巍 on 5/20/15.
//  Copyright (c) 2015 Littocats. All rights reserved.
//

import Foundation

extension NSURL {
    // query string 解析器，可独使用
    struct QueryParser {
        private static func queryComponents(key: String, _ value: AnyObject) -> [(String, String)] {
            var components: [(String, String)] = []
            if let dictionary = value as? [String: AnyObject] {
                for (nestedKey, value) in dictionary {
                    components += queryComponents("\(key)[\(nestedKey)]", value)
                }
            } else if let array = value as? [AnyObject] {
                for value in array {
                    components += queryComponents("\(key)[]", value)
                }
            } else {
                components.extend([(escape(key), escape("\(value)"))])
            }
            
            return components
        }
        
        private static func parseKeys(keys: [String], value: AnyObject) -> AnyObject {
            var ret: AnyObject = value
            for key in keys.reverse() {
                ret = key.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) == 0 ? [ret] : [key: ret]
            }
            return ret
        }
        
        private static func merge<T>(target: T, source: T?) -> T{
            if source == nil { return target}
            if var ret = target as? Array<AnyObject> {
                for item in source as! Array<AnyObject> {
                    ret.append(item)
                }
                return ret as! T
            }
            
            if var ret = target as? Dictionary<String, AnyObject> {
                for (key, value) in source as! Dictionary<String, AnyObject> {
                    ret[key] = value is String ? value : ret[key] == nil ? value : merge(ret[key]!, source: value)
                }
                return ret as! T
            }
            if target is String {
                return source!
            }
            return target
        }
        
        private static func escape(string: String) -> String {
            return string.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
        }
        private static func unEscape(string: String) -> String {
            return string.stringByReplacingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
        }
        
        static func query(parameters: [String: AnyObject]) -> String {
            var components: [(String, String)] = []
            for key in sorted(Array(parameters.keys), <) {
                let value: AnyObject! = parameters[key]
                components += self.queryComponents(key, value)
            }
            return join("&", components.map{"\($0)=\($1)"} as [String])
        }
        
        static func parse(query: String)-> [String: AnyObject] {
            var components = query.componentsSeparatedByString("&")
            var params = [String: AnyObject]()
            for item in sorted(components, <) {
                var keyValue = item.componentsSeparatedByString("=")
                if keyValue.count != 2 {continue}
                var keys = unEscape(keyValue[0]).stringByReplacingOccurrencesOfString("]", withString: "", options: NSStringCompareOptions.allZeros, range: nil).componentsSeparatedByString("[")
                var value = unEscape(keyValue[1])
                params = merge(params, source: parseKeys(keys, value: value)) as! [String : AnyObject]
            }
            return params
        }
    }
    
    // 解析 queryString
    var params: [String: AnyObject]? {
        if self.query == nil {return nil}
        return QueryParser.parse(self.query!)
    }
}