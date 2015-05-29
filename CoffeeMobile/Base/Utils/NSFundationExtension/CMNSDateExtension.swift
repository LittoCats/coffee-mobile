//
//  NSDateExtension.swift
//  CoffeeMobile
//
//  Created by 程巍巍 on 5/20/15.
//  Copyright (c) 2015 Littocats. All rights reserved.
//

import Foundation
import LunarCalendar

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
    
}