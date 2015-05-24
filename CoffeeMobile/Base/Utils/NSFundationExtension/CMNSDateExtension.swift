//
//  NSDateExtension.swift
//  CoffeeMobile
//
//  Created by 程巍巍 on 5/20/15.
//  Copyright (c) 2015 Littocats. All rights reserved.
//

import Foundation

extension NSDate {
    /**
    *  NSDate 与字符串的格式化转换
    e.g.   2014-10-19 23:58:59:345
    yyyy    : 2014			//年
    YYYY    ; 2014			//年
    MM      : 10			//年中的月份  1〜12
    dd      : 19			//当月中的第几天 1〜31
    DD      : 292			//当年中的第几天	1〜366
    hh      : 11			//当天中的小时 12 进制 1〜12
    HH      : 23			//当天中的小时 24 进制 0 〜 23
    mm      : 58			//当前小时中的分钟 0 〜 59
    ss      : 59			//当前分钟中的秒数 0 〜 59
    SSS     : 345			//当前秒中的耗秒数 0 〜 999
    a       : PM			//表示上下午 AM 上午 PM 下午
    A       : 86339345		//当天中已经过的耗秒数
    t       : 				//普通字符无意义，通常用作日期与时间的分隔
    T       : 				//普通字符无意义，通常用作日期与时间的分隔
    v       : China Time	//时间名
    V       : cnsha		//时间名缩写
    w       : 43			//当年中的第几周	星期天为周的开始
    W       : 4 			//当月中的第几周 星期天为周的开始
    F       : 3 			//当月中的第几周 星期一为周的开始
    x		: +08			//表示当前时区
    x 		: +08			//表示当前时区
    */
    
    convenience init?(year: Int, month: Int, day: Int, hour: Int = 0, minute: Int = 0, second: Int = 0){
        var formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let date = formatter.dateFromString("\(year)-\(month)-\(day) \(hour):\(minute):\(second)")
        if date == nil {self.init();return nil}
        self.init(timeIntervalSince1970: date!.timeIntervalSince1970)
    }
    convenience init?(lunarYear year: Int, month: Int, day: Int, hour: Int = 0, minute: Int = 0, second: Int = 0, isLeapMonth: Bool = false){
        var interval = LunarComponent.lunarInterval(lunarYear: year, month: month, day: day, hour: hour, minute: minute, second: second, isLeapMonth: isLeapMonth)
        if !interval.valid {self.init();return nil}
        self.init(timeIntervalSince1970: interval.interval*86400)
    }
    
    convenience init?(string: String, format: String = "yyyy-MM-dd HH:mm:ss") {
        var formater = NSDateFormatter()
        formater.dateFormat = format
        if let date = formater.dateFromString(string) {
            self.init(timeIntervalSince1970: date.timeIntervalSince1970)
        }else{
            self.init()
        }
        return nil
    }
    
    var week: Int{
        var days = Int((self.timeIntervalSince1970 - NSDate(year: 1900, month: 1, day: 1)!.timeIntervalSince1970) / 86400)
        return days % 7 + 1
    }
    
    var lunar: LunarComponent{
        get{
            var components = objc_getAssociatedObject(self, &LunarComponent.Lib.LunarComponentKey) as? LunarComponent
            if components == nil {
                components = LunarComponent(date: self)
                self.lunar = components!
            }
            return components!
        }set{
            objc_setAssociatedObject(self, &LunarComponent.Lib.LunarComponentKey, newValue, objc_AssociationPolicy(OBJC_ASSOCIATION_RETAIN_NONATOMIC))
        }
    }
}

extension NSDate {
    final class LunarComponent {
        var components = (
            Hour:0,
            Minute: 0,
            Second: 0,
            SolarYear: 0,
            SolarMonth:0,
            SolarDay:0,
            LunarYear: 0,
            LunarMonth: 0,
            LunarDay: 0,
            LunarYearCN: "",
            LunarMonthCN: "",
            LunarDayCN: "",
            GZHour: "",  // 时
            GZQuarter: "",    // 刻
            GZYear: "",
            GZMonth: "",
            GZDay:  "",
            AnimalSymbol: 0,    //  1 ~ 12
            AnimalSymbolCN: "",
            AstronomySymbol: 0, //  1 ~ 12
            AstronomySymbolCN: "",
            SolarTerm: 0,   // 0 ~ 23
            SolarTermCN: "",
            Week: 0,
            isSolarTerm: false,
            isToday: false,
            isLeapMonth: false
        )
        private var interval: NSTimeInterval!   //timeIntervalSince1970
        // 农历年、月、日初始化
        private class func lunarInterval(lunarYear year: Int, month: Int, day: Int, hour: Int = 0, minute: Int = 0, second: Int = 0, isLeapMonth: Bool = false) -> (interval: NSTimeInterval, valid: Bool){
            
            let ymd = year * 10000 + month * 100 + day
            if ymd > 21001201 || ymd < 19000131 {return (0, false)}
            
            if (hour < 0 || hour >= 24) || (minute < 0 || minute >= 60) || (second < 0 || second >= 60) {return (0, false)}
            
            var leapOffset = 0
            var leapMonth = LunarComponent.leapMonthOfYear(year)
            if isLeapMonth && leapMonth != month {return (0, false)}
            
            // 验正天是否超也范围
            var d = LunarComponent.daysOfLunarMonth(month, inYear: year)
            if d < day {return (0, false)}
            
            // 计算农历的时间差
            var offset = 0
            for i in 1900..<year {
                offset += LunarComponent.daysOfLunarYear(i)
            }
            
            var isAdd = false
            var daysOfLeapMonth = LunarComponent.daysOfLeapMonthInYear(year)
            for i in 1..<month{
                if !isAdd && (leapMonth <= i && leapMonth > 0){
                    offset += daysOfLeapMonth
                    isAdd = true
                }
                offset += LunarComponent.daysOfLunarMonth(i, inYear: year)
            }
            
            // 转换闰月农历 需补充该年闰月的前一个月的时差
            if isLeapMonth {offset += d}
            
            // 1900年农历正月一日的公历时间为1900年1月30日0时0分0秒(该时间也是本农历的最开始起始点)
            // NSTimeZone.localTimeZone().secondsFromGMT 为时区修正
            //            - NSTimeZone.localTimeZone().secondsFromGMT
            var _h = Float(hour)/24
            var _m = Float(minute)/(24*60)
            var _s = Float(second)/86400
            let stmap = Float(offset + day - 31)  - 25507 + _h + _m + _s
            var interval = NSTimeInterval(stmap)
            return (interval, true)
        }
        // 农历年、月、日初始化
        private init?(date: NSDate){
            self.interval = date.timeIntervalSince1970
            if !parseComponents() {return nil}
        }
        
        private func parseComponents() ->Bool{
            let date = NSDate(timeIntervalSince1970: self.interval)
            components.Hour         = LunarComponent.component(date: date, symbol: "HH")
            components.Minute       = LunarComponent.component(date: date, symbol: "mm")
            components.Second       = LunarComponent.component(date: date, symbol: "ss")
            components.SolarYear    = LunarComponent.component(date: date, symbol: "yyyy")
            components.SolarMonth   = LunarComponent.component(date: date, symbol: "MM")
            components.SolarDay     = LunarComponent.component(date: date, symbol: "dd")
            
            let ymd = components.SolarYear * 10000 + components.SolarMonth * 100 + components.SolarDay
            if ymd > 21001201 || ymd < 19000131 {return false}
            
            var objDate = NSDate(year: components.SolarYear, month: components.SolarMonth, day: components.SolarDay)
            var leap = 0
            var temp = 0
            
            // 修正 y m d 参数
            var y = LunarComponent.component(date: objDate!, symbol: "yyyy")
            var m = LunarComponent.component(date: objDate!, symbol: "MM")
            var d = LunarComponent.component(date: objDate!, symbol: "dd")
            var offset = Int((NSDate(year: y, month: m, day: d)!.timeIntervalSince1970 - NSDate(year: 1900, month: 1, day: 31)!.timeIntervalSince1970)/86400)
            
            var i = 0
            for (i = 1900; i < 2100; i++) {
                if offset <= 0 {break}
                temp = LunarComponent.daysOfLunarYear(i)
                offset -= temp
            }
            
            if offset < 0 { offset += temp; i--}
            
            // isToday
            var today = NSDate()
            components.isToday = LunarComponent.component(date: today, symbol: "yyyy") == y && LunarComponent.component(date: today, symbol: "MM") == m && LunarComponent.component(date: today, symbol: "dd") == d
            
            // week
            components.Week = Int((date.timeIntervalSince1970 - NSDate(year: 1900, month: 1, day: 1)!.timeIntervalSince1970) / 86400) % 7 + 1
            
            // 农历年
            components.LunarYear = i
            components.LunarYearCN = LunarComponent.cnNameOfYear(i)
            
            // 计算闰月
            leap = LunarComponent.leapMonthOfYear(i)
            components.isLeapMonth = false
            for (i = 1; i < 12; i++){
                if offset <= 0 {break}
                // 闰月
                if leap > 0 && i == leap+1 && components.isLeapMonth == false {
                    --i
                    components.isLeapMonth = true
                    temp = LunarComponent.daysOfLeapMonthInYear(y) // 计算闰月天数
                }else{
                    temp = LunarComponent.daysOfLunarMonth(i, inYear: y)
                }
                // 解除闰月
                if components.isLeapMonth && i == leap + 1{
                    components.isLeapMonth = false
                }
                offset -= temp
            }
            if offset == 0 && leap > 0 && i == leap + 1 {
                if components.isLeapMonth {
                    components.isLeapMonth = false
                }else{
                    components.isLeapMonth = true
                    --i
                }
            }
            if offset < 0 {
                offset += temp
                --i
            }
            
            // 农历月
            components.LunarMonth = i
            components.LunarMonthCN = LunarComponent.cnNameOfMonth(i)
            // 农历日
            components.LunarDay = offset + 1
            components.LunarDayCN = LunarComponent.cnNameOfDay(offset+1)
            
            // 天干地支处理
            var sm = m-1
            var term3	=	LunarComponent.solarTermOfYear(y, serialNo: 3) // 该农历年立春日期
            var gzY = LunarComponent.toGanZhi(y - 4) 	// 普通按年份计算，下方尚需按立春节气来修正
            
            // 依据立春日进行修正gzY
            if sm < 2 && d < term3 {
                gzY = LunarComponent.toGanZhi(y - 5)
            }else{
                gzY = LunarComponent.toGanZhi(y - 4)
            }
            components.GZYear = gzY
            
            // 月柱 1900年1月小寒以前为 丙子月(60进制12)
            var firstNode = LunarComponent.solarTermOfYear(y, serialNo: m*2-1) 	// 返回当月「节」为几日开始
            var secondNode = LunarComponent.solarTermOfYear(y, serialNo: m*2)     // 返回当月「节」为几日开始
            
            // 依据12节气修正干支月
            if d < firstNode {
                components.GZMonth = LunarComponent.toGanZhi((y-1900)*12+m+11)
            }else{
                components.GZMonth = LunarComponent.toGanZhi((y-1900)*12+m+12)
            }
            
            // 日柱 当月一日与 1900/1/1 相差天数
            var dayCyclical: Int = Int(NSDate(year: y, month: m, day: 1)!.timeIntervalSince1970/86400) + 25567 + 10 + 29
            components.GZDay = LunarComponent.toGanZhi(dayCyclical+d-1)
            
            // 判断是否是节气
            if firstNode == d {
                components.isSolarTerm = true
                components.SolarTerm = m*2-2
            }
            if secondNode == d {
                components.isSolarTerm = true
                components.SolarTerm = m*2-1
            }
            if components.isSolarTerm {
                components.SolarTermCN = LunarComponent.Lib.SolarTerm[components.SolarTerm]
            }
            
            // 属相
            components.AnimalSymbol = LunarComponent.animalSymbolOfYear(components.LunarYear)
            components.AnimalSymbolCN = LunarComponent.Lib.Animals[components.AnimalSymbol]
            // 星座
            components.AstronomySymbol = LunarComponent.astronomyOfMonth(m, day: y)
            components.AstronomySymbolCN = LunarComponent.Lib.AstronomyName[components.AstronomySymbol]
            
            // 时晨
            components.GZHour = "\(LunarComponent.Lib.Zhi[components.Hour/2])时"
            var quarter = components.Minute/15
            if quarter > 0{
                components.GZQuarter = "\(LunarComponent.Lib.nStr1[quarter])刻"
            }
            
            return true
        }
        
        private struct Lib {
            static var LunarComponentKey = "LunarComponentKey"
            
            static let LunarInfo = [    //农历1900-2100的润大小信息表
                0x04bd8,0x04ae0,0x0a570,0x054d5,0x0d260,0x0d950,0x16554,0x056a0,0x09ad0,0x055d2,
                0x04ae0,0x0a5b6,0x0a4d0,0x0d250,0x1d255,0x0b540,0x0d6a0,0x0ada2,0x095b0,0x14977,
                0x04970,0x0a4b0,0x0b4b5,0x06a50,0x06d40,0x1ab54,0x02b60,0x09570,0x052f2,0x04970,
                0x06566,0x0d4a0,0x0ea50,0x06e95,0x05ad0,0x02b60,0x186e3,0x092e0,0x1c8d7,0x0c950,
                0x0d4a0,0x1d8a6,0x0b550,0x056a0,0x1a5b4,0x025d0,0x092d0,0x0d2b2,0x0a950,0x0b557,
                0x06ca0,0x0b550,0x15355,0x04da0,0x0a5b0,0x14573,0x052b0,0x0a9a8,0x0e950,0x06aa0,
                0x0aea6,0x0ab50,0x04b60,0x0aae4,0x0a570,0x05260,0x0f263,0x0d950,0x05b57,0x056a0,
                0x096d0,0x04dd5,0x04ad0,0x0a4d0,0x0d4d4,0x0d250,0x0d558,0x0b540,0x0b6a0,0x195a6,
                0x095b0,0x049b0,0x0a974,0x0a4b0,0x0b27a,0x06a50,0x06d40,0x0af46,0x0ab60,0x09570,
                0x04af5,0x04970,0x064b0,0x074a3,0x0ea50,0x06b58,0x055c0,0x0ab60,0x096d5,0x092e0,
                0x0c960,0x0d954,0x0d4a0,0x0da50,0x07552,0x056a0,0x0abb7,0x025d0,0x092d0,0x0cab5,
                0x0a950,0x0b4a0,0x0baa4,0x0ad50,0x055d9,0x04ba0,0x0a5b0,0x15176,0x052b0,0x0a930,
                0x07954,0x06aa0,0x0ad50,0x05b52,0x04b60,0x0a6e6,0x0a4e0,0x0d260,0x0ea65,0x0d530,
                0x05aa0,0x076a3,0x096d0,0x04bd7,0x04ad0,0x0a4d0,0x1d0b6,0x0d250,0x0d520,0x0dd45,
                0x0b5a0,0x056d0,0x055b2,0x049b0,0x0a577,0x0a4b0,0x0aa50,0x1b255,0x06d20,0x0ada0,
                0x14b63,0x09370,0x049f8,0x04970,0x064b0,0x168a6,0x0ea50,0x06b20,0x1a6c4,0x0aae0,
                0x0a2e0,0x0d2e3,0x0c960,0x0d557,0x0d4a0,0x0da50,0x05d55,0x056a0,0x0a6d0,0x055d4,
                0x052d0,0x0a9b8,0x0a950,0x0b4a0,0x0b6a6,0x0ad50,0x055a0,0x0aba4,0x0a5b0,0x052b0,
                0x0b273,0x06930,0x07337,0x06aa0,0x0ad50,0x14b55,0x04b60,0x0a570,0x054e4,0x0d160,
                0x0e968,0x0d520,0x0daa0,0x16aa6,0x056d0,0x04ae0,0x0a9d4,0x0a2d0,0x0d150,0x0f252,
                0x0d520
            ]
            // 公历每个月份的天数普通表
            private static let SolarMonth = [0,31,28,31,30,31,30,31,31,30,31,30,31]
            // 天干地支之天干速查表
            private static let Gan = ["甲","乙","丙","丁","戊","己","庚","辛","壬","癸"]
            
            // 天干地支之地支速查表
            private static let Zhi = ["子","丑","寅","卯","辰","巳","午","未","申","酉","戌","亥"]
            
            // 天干地支之地支速查表<=>生肖
            private static let Animals = ["鼠","牛","虎","兔","龙","蛇","马","羊","猴","鸡","狗","猪"]
            
            // 24节气速查表
            private static let SolarTerm = ["小寒","大寒","立春","雨水","惊蛰","春分","清明","谷雨","立夏","小满","芒种","夏至","小暑","大暑","立秋","处暑","白露","秋分","寒露","霜降","立冬","小雪","大雪","冬至"]
            
            // 十二星座速查表
            private static let AstronomyInfo = [23, 21, 20, 21, 21, 22, 22, 24, 24, 24, 24, 23, 23]
            private static let AstronomyName = ["摩羯座", "水瓶座", "双鱼座", "牡羊座", "金牛座", "双子座", "巨蟹座", "狮子座", "处女座", "天秤座", "天蝎座", "射手座", "摩羯座"]
            
            // 1900-2100各年的24节气日期速查表
            
            // 数字转中文速查表
            private static let nStr1 = ["〇","一","二","三","四","五","六","七","八","九","十"]
            
            // 日期转农历称呼速查表
            private static let nStr2 = ["初","十","廿","卅"]
            
            // 月份转农历称呼速查表
            private static let nStr3 = ["正","二","三","四","五","六","七","八","九","十","冬","腊"]
            
            // 1900-2100各年的24节气日期速查表
            private static let sTermInfo: [NSString] = [
                "9778397bd097c36b0b6fc9274c91aa","97b6b97bd19801ec9210c965cc920e","97bcf97c3598082c95f8c965cc920f",
                "97bd0b06bdb0722c965ce1cfcc920f","b027097bd097c36b0b6fc9274c91aa","97b6b97bd19801ec9210c965cc920e",
                "97bcf97c359801ec95f8c965cc920f","97bd0b06bdb0722c965ce1cfcc920f","b027097bd097c36b0b6fc9274c91aa",
                "97b6b97bd19801ec9210c965cc920e","97bcf97c359801ec95f8c965cc920f","97bd0b06bdb0722c965ce1cfcc920f",
                "b027097bd097c36b0b6fc9274c91aa","9778397bd19801ec9210c965cc920e","97b6b97bd19801ec95f8c965cc920f",
                "97bd09801d98082c95f8e1cfcc920f","97bd097bd097c36b0b6fc9210c8dc2","9778397bd197c36c9210c9274c91aa",
                "97b6b97bd19801ec95f8c965cc920e","97bd09801d98082c95f8e1cfcc920f","97bd097bd097c36b0b6fc9210c8dc2",
                "9778397bd097c36c9210c9274c91aa","97b6b97bd19801ec95f8c965cc920e","97bcf97c3598082c95f8e1cfcc920f",
                "97bd097bd097c36b0b6fc9210c8dc2","9778397bd097c36c9210c9274c91aa","97b6b97bd19801ec9210c965cc920e",
                "97bcf97c3598082c95f8c965cc920f","97bd097bd097c35b0b6fc920fb0722","9778397bd097c36b0b6fc9274c91aa",
                "97b6b97bd19801ec9210c965cc920e","97bcf97c3598082c95f8c965cc920f","97bd097bd097c35b0b6fc920fb0722",
                "9778397bd097c36b0b6fc9274c91aa","97b6b97bd19801ec9210c965cc920e","97bcf97c359801ec95f8c965cc920f",
                "97bd097bd097c35b0b6fc920fb0722","9778397bd097c36b0b6fc9274c91aa","97b6b97bd19801ec9210c965cc920e",
                "97bcf97c359801ec95f8c965cc920f","97bd097bd097c35b0b6fc920fb0722","9778397bd097c36b0b6fc9274c91aa",
                "97b6b97bd19801ec9210c965cc920e","97bcf97c359801ec95f8c965cc920f","97bd097bd07f595b0b6fc920fb0722",
                "9778397bd097c36b0b6fc9210c8dc2","9778397bd19801ec9210c9274c920e","97b6b97bd19801ec95f8c965cc920f",
                "97bd07f5307f595b0b0bc920fb0722","7f0e397bd097c36b0b6fc9210c8dc2","9778397bd097c36c9210c9274c920e",
                "97b6b97bd19801ec95f8c965cc920f","97bd07f5307f595b0b0bc920fb0722","7f0e397bd097c36b0b6fc9210c8dc2",
                "9778397bd097c36c9210c9274c91aa","97b6b97bd19801ec9210c965cc920e","97bd07f1487f595b0b0bc920fb0722",
                "7f0e397bd097c36b0b6fc9210c8dc2","9778397bd097c36b0b6fc9274c91aa","97b6b97bd19801ec9210c965cc920e",
                "97bcf7f1487f595b0b0bb0b6fb0722","7f0e397bd097c35b0b6fc920fb0722","9778397bd097c36b0b6fc9274c91aa",
                "97b6b97bd19801ec9210c965cc920e","97bcf7f1487f595b0b0bb0b6fb0722","7f0e397bd097c35b0b6fc920fb0722",
                "9778397bd097c36b0b6fc9274c91aa","97b6b97bd19801ec9210c965cc920e","97bcf7f1487f531b0b0bb0b6fb0722",
                "7f0e397bd097c35b0b6fc920fb0722","9778397bd097c36b0b6fc9274c91aa","97b6b97bd19801ec9210c965cc920e",
                "97bcf7f1487f531b0b0bb0b6fb0722","7f0e397bd07f595b0b6fc920fb0722","9778397bd097c36b0b6fc9274c91aa",
                "97b6b97bd19801ec9210c9274c920e","97bcf7f0e47f531b0b0bb0b6fb0722","7f0e397bd07f595b0b0bc920fb0722",
                "9778397bd097c36b0b6fc9210c91aa","97b6b97bd197c36c9210c9274c920e","97bcf7f0e47f531b0b0bb0b6fb0722",
                "7f0e397bd07f595b0b0bc920fb0722","9778397bd097c36b0b6fc9210c8dc2","9778397bd097c36c9210c9274c920e",
                "97b6b7f0e47f531b0723b0b6fb0722","7f0e37f5307f595b0b0bc920fb0722","7f0e397bd097c36b0b6fc9210c8dc2",
                "9778397bd097c36b0b70c9274c91aa","97b6b7f0e47f531b0723b0b6fb0721","7f0e37f1487f595b0b0bb0b6fb0722",
                "7f0e397bd097c35b0b6fc9210c8dc2","9778397bd097c36b0b6fc9274c91aa","97b6b7f0e47f531b0723b0b6fb0721",
                "7f0e27f1487f595b0b0bb0b6fb0722","7f0e397bd097c35b0b6fc920fb0722","9778397bd097c36b0b6fc9274c91aa",
                "97b6b7f0e47f531b0723b0b6fb0721","7f0e27f1487f531b0b0bb0b6fb0722","7f0e397bd097c35b0b6fc920fb0722",
                "9778397bd097c36b0b6fc9274c91aa","97b6b7f0e47f531b0723b0b6fb0721","7f0e27f1487f531b0b0bb0b6fb0722",
                "7f0e397bd097c35b0b6fc920fb0722","9778397bd097c36b0b6fc9274c91aa","97b6b7f0e47f531b0723b0b6fb0721",
                "7f0e27f1487f531b0b0bb0b6fb0722","7f0e397bd07f595b0b0bc920fb0722","9778397bd097c36b0b6fc9274c91aa",
                "97b6b7f0e47f531b0723b0787b0721","7f0e27f0e47f531b0b0bb0b6fb0722","7f0e397bd07f595b0b0bc920fb0722",
                "9778397bd097c36b0b6fc9210c91aa","97b6b7f0e47f149b0723b0787b0721","7f0e27f0e47f531b0723b0b6fb0722",
                "7f0e397bd07f595b0b0bc920fb0722","9778397bd097c36b0b6fc9210c8dc2","977837f0e37f149b0723b0787b0721",
                "7f07e7f0e47f531b0723b0b6fb0722","7f0e37f5307f595b0b0bc920fb0722","7f0e397bd097c35b0b6fc9210c8dc2",
                "977837f0e37f14998082b0787b0721","7f07e7f0e47f531b0723b0b6fb0721","7f0e37f1487f595b0b0bb0b6fb0722",
                "7f0e397bd097c35b0b6fc9210c8dc2","977837f0e37f14998082b0787b06bd","7f07e7f0e47f531b0723b0b6fb0721",
                "7f0e27f1487f531b0b0bb0b6fb0722","7f0e397bd097c35b0b6fc920fb0722","977837f0e37f14998082b0787b06bd",
                "7f07e7f0e47f531b0723b0b6fb0721","7f0e27f1487f531b0b0bb0b6fb0722","7f0e397bd097c35b0b6fc920fb0722",
                "977837f0e37f14998082b0787b06bd","7f07e7f0e47f531b0723b0b6fb0721","7f0e27f1487f531b0b0bb0b6fb0722",
                "7f0e397bd07f595b0b0bc920fb0722","977837f0e37f14998082b0787b06bd","7f07e7f0e47f531b0723b0b6fb0721",
                "7f0e27f1487f531b0b0bb0b6fb0722","7f0e397bd07f595b0b0bc920fb0722","977837f0e37f14998082b0787b06bd",
                "7f07e7f0e47f149b0723b0787b0721","7f0e27f0e47f531b0b0bb0b6fb0722","7f0e397bd07f595b0b0bc920fb0722",
                "977837f0e37f14998082b0723b06bd","7f07e7f0e37f149b0723b0787b0721","7f0e27f0e47f531b0723b0b6fb0722",
                "7f0e397bd07f595b0b0bc920fb0722","977837f0e37f14898082b0723b02d5","7ec967f0e37f14998082b0787b0721",
                "7f07e7f0e47f531b0723b0b6fb0722","7f0e37f1487f595b0b0bb0b6fb0722","7f0e37f0e37f14898082b0723b02d5",
                "7ec967f0e37f14998082b0787b0721","7f07e7f0e47f531b0723b0b6fb0722","7f0e37f1487f531b0b0bb0b6fb0722",
                "7f0e37f0e37f14898082b0723b02d5","7ec967f0e37f14998082b0787b06bd","7f07e7f0e47f531b0723b0b6fb0721",
                "7f0e37f1487f531b0b0bb0b6fb0722","7f0e37f0e37f14898082b072297c35","7ec967f0e37f14998082b0787b06bd",
                "7f07e7f0e47f531b0723b0b6fb0721","7f0e27f1487f531b0b0bb0b6fb0722","7f0e37f0e37f14898082b072297c35",
                "7ec967f0e37f14998082b0787b06bd","7f07e7f0e47f531b0723b0b6fb0721","7f0e27f1487f531b0b0bb0b6fb0722",
                "7f0e37f0e366aa89801eb072297c35","7ec967f0e37f14998082b0787b06bd","7f07e7f0e47f149b0723b0787b0721",
                "7f0e27f1487f531b0b0bb0b6fb0722","7f0e37f0e366aa89801eb072297c35","7ec967f0e37f14998082b0723b06bd",
                "7f07e7f0e47f149b0723b0787b0721","7f0e27f0e47f531b0723b0b6fb0722","7f0e37f0e366aa89801eb072297c35",
                "7ec967f0e37f14998082b0723b06bd","7f07e7f0e37f14998083b0787b0721","7f0e27f0e47f531b0723b0b6fb0722",
                "7f0e37f0e366aa89801eb072297c35","7ec967f0e37f14898082b0723b02d5","7f07e7f0e37f14998082b0787b0721",
                "7f07e7f0e47f531b0723b0b6fb0722","7f0e36665b66aa89801e9808297c35","665f67f0e37f14898082b0723b02d5",
                "7ec967f0e37f14998082b0787b0721","7f07e7f0e47f531b0723b0b6fb0722","7f0e36665b66a449801e9808297c35",
                "665f67f0e37f14898082b0723b02d5","7ec967f0e37f14998082b0787b06bd","7f07e7f0e47f531b0723b0b6fb0721",
                "7f0e36665b66a449801e9808297c35","665f67f0e37f14898082b072297c35","7ec967f0e37f14998082b0787b06bd",
                "7f07e7f0e47f531b0723b0b6fb0721","7f0e26665b66a449801e9808297c35","665f67f0e37f1489801eb072297c35",
                "7ec967f0e37f14998082b0787b06bd","7f07e7f0e47f531b0723b0b6fb0721","7f0e27f1487f531b0b0bb0b6fb0722"
            ]
        }
    }
}

extension NSDate.LunarComponent{
    
    // 返回农历y年闰月是哪个月；若y年没有闰月 则返回0
    // param lunar Year
    // return Number (0-12)
    class func leapMonthOfYear(year: Int)-> Int{
        return Lib.LunarInfo[year-1900] & 0xf
    }
    
    // 返回农历y年闰月的天数 若该年没有闰月则返回0
    // param lunar Year
    // return Number (0、29、30)
    class func daysOfLeapMonthInYear(year: Int)-> Int{
        if leapMonthOfYear(year) > 0{
            if Bool(Lib.LunarInfo[year-1900] & 0x10000) {return 30}
            else{return 29}
        }
        return 0
    }
    
    // 返回农历y年一整年的总天数
    // param lunar Year
    // return Number
    class func daysOfLunarYear(year: Int)-> Int{
        var sum = 348
        var i = 0x8000
        while i > 0x8{
            if Bool(Lib.LunarInfo[year - 1900] & i) {sum += 1}
            i >>= 1
        }
        return sum + daysOfLeapMonthInYear(year)
    }
    
    
    // 返回农历y年m月（非闰月）的总天数，计算m为闰月时的天数请使用leapMonthDays方法
    // param lunar Year
    // return Number (-1、29、30)
    class func daysOfLunarMonth(month: Int, inYear year: Int)->Int{
        if month > 12 || month < 1 {return -1}
        if Bool(Lib.LunarInfo[year - 1900] & (0x10000 >> month)){return 30}
        else{return 29}
    }
    
    
    // 返回公历(!)y年m月的天数
    // param solar Year
    // return Number (-1、28、29、30、31)
    class func daysOfMonth(month: Int, ofYear year: Int) ->Int{
        if month > 12 || month < 1 {return -1}
        if month != 2 {return Lib.SolarMonth[month]}
        //2月份的闰平规律测算后确认返回28或29
        if year%4 == 0 && year%100 != 0 || year%400 == 0 {return 29}
        else{return 28}
    }
    
    // 传入offset偏移量返回干支
    // param offset 相对甲子的偏移量
    // return 中文
    class func toGanZhi(offset: Int) ->String{
        return Lib.Gan[offset%10]+Lib.Zhi[offset%12]
    }
    
    // 公历(!)y年获得该年第n个节气的公历日期
    // param y公历年(1900-2100)；n二十四节气中的第几个节气(1~24)；从n=1(小寒)算起
    // return day Number
    class func solarTermOfYear(year: Int, serialNo: Int) ->Int{
        if year < 1900 || year > 2100 || serialNo < 1 || serialNo > 24{return -1}
        let no = serialNo - 1
        var table:NSString = Lib.sTermInfo[year - 1900]
        var info = NSString(format:"%i",parseInt(("0x" + table.substringWithRange(NSMakeRange(no/4*5, 5)))))
        var index_location = [0, 1, 3, 4]
        var index_length = [1, 2]
        return parseInt(info.substringWithRange(NSMakeRange(index_location[no%4], index_length[no%4%2])))
    }
    
    // 传入农历数字年份返回汉语通俗表示法
    // param lunar year
    // return Cn string
    // 若参数错误 返回 ""
    class func cnNameOfYear(year: Int)->String{
        var yStr: NSString = "\(year)"
        var ret = ""
        for i in 0..<(yStr as NSString).length {
            ret += Lib.nStr1[parseInt(yStr.substringWithRange(NSMakeRange(i, 1)))]
        }
        return ret+"年"
    }
    
    // 传入农历数字月份返回汉语通俗表示法
    // param lunar month
    // return Cn string
    // 若参数错误 返回 ""
    class func cnNameOfMonth(month: Int)->String{
        if month > 12 || month < 1 {return ""}
        return Lib.nStr3[month - 1] + "月"
    }
    
    // 传入农历日期数字返回汉字表示法
    // param lunar day
    // return Cn string
    // return Cn string
    // eg: cnDay = toChinaDay 21 //cnMonth='廿一'
    class func cnNameOfDay(day: Int) -> String{return Lib.nStr2[Int(day / 10)] + Lib.nStr1[day % 10]}
    
    // 年份转生肖[!仅能大致转换] => 精确划分生肖分界线是“立春”
    // param y year
    // return Cn string
    class func animalSymbolOfYear(year: Int) -> Int{return ( year - 4) % 12}
    
    // 根据生日计算十二星座
    // param solar month 1 ~ 12
    // param solar day
    // return Cn string
    class func astronomyOfMonth(month: Int, day: Int) ->Int{
        if day >= Lib.AstronomyInfo[month] {return month}
        else{return month - 1}
    }
    
    private class func component(#date: NSDate, symbol: String) -> Int{
        var formatter = NSDateFormatter()
        formatter.dateFormat = symbol
        return parseInt(formatter.stringFromDate(date))
    }
    
    private class func parseInt(string: String)-> Int{
        struct IntSymbol {
            static let HEX = ["0": 0, "1":1, "2":2, "3":3, "4":4, "5":5, "6":6, "7":7, "8":8, "9":9, "a":10, "b":11, "c":12, "d":13, "e":14, "f":15]
        }
        let str: NSString = string.lowercaseString
        var int: Int = 0
        var symbol: NSString
        var value: Int?
        if str.hasPrefix("0x") {
            var vstr: NSString = str.substringFromIndex(2)
            for index in 0..<vstr.length {
                symbol = vstr.substringWithRange(NSMakeRange(index, 1))
                value = IntSymbol.HEX[symbol as String]
                if value == nil {return 0}
                int |= value! << (4 * (vstr.length - index - 1))
            }
        }else{
            var vstr: NSString = str
            for index in 0..<vstr.length {
                symbol = vstr.substringWithRange(NSMakeRange(index, 1))
                value = IntSymbol.HEX[symbol as String]
                if value == nil {return 0}
                int += value! * Int(pow(10, Float((vstr.length - index - 1))))
            }
        }
        return int
    }
}