//
//  LunarCalendar.h
//  LunarCalendar
//
//  Created by 程巍巍 on 5/28/15.
//  Copyright (c) 2015 Littocats. All rights reserved.
//

#import <Foundation/Foundation.h>

@class LunarCalendarDay;

@interface LunarCalendarMonth : NSObject
@property (nonatomic, readonly) NSString* firstDayWeek;   //  本月第一天的星期
@property (nonatomic, readonly) NSString* solarYear;    //公历年份
@property (nonatomic, readonly) NSString* solarMonth;    //公历月分
@property (nonatomic, readonly) NSString* d0;   //月首的J2000.0起算的儒略日数
@property (nonatomic, readonly) NSString* days;   //本月的天数
@property (nonatomic, readonly) NSString* lunarYear;   //该年的干支纪年
@property (nonatomic, readonly) NSString* animal;  //该年的生肖

- (LunarCalendarDay *)day:(NSInteger)day;

@end

@interface LunarCalendarDay : NSObject

@property (nonatomic, readonly) NSString* d0;		//  2000.0起算儒略日,北京时12:00
@property (nonatomic, readonly) NSString* solardayIndex;		//  所在公历月内日序数
@property (nonatomic, readonly) NSString* solarYear;		//   所在公历年,同lun.y
@property (nonatomic, readonly) NSString* solarMonth;		//   所在公历月,同lun.m
@property (nonatomic, readonly) NSString* solarDay;		//   日名称(公历)
@property (nonatomic, readonly) NSString* solarDays;		//  所在公历月的总天数,同lun.d0
@property (nonatomic, readonly) NSString* firstDayWeek;     //所在月的月首的星期,同lun.w0
@property (nonatomic, readonly) NSString* week;		//星期
@property (nonatomic, readonly) NSString* weekIndex;     //在本月中的周序号
@property (nonatomic, readonly) NSString* weeks;    //本月的总周数
//·日的农历信息
@property (nonatomic, readonly) NSString* lunarDayIndex;		// 距农历月首的编移量,0对应初一
@property (nonatomic, readonly) NSString* lunarDay;		// 日名称(农历),即'初一,初二等'
@property (nonatomic, readonly) NSString* cur_dz;		//距冬至的天数
@property (nonatomic, readonly) NSString* cur_xz;		//距夏至的天数
@property (nonatomic, readonly) NSString* cur_lq;		//距立秋的天数
@property (nonatomic, readonly) NSString* cur_mz;		//距芒种的天数
@property (nonatomic, readonly) NSString* cur_xs;		//距小暑的天数
@property (nonatomic, readonly) NSString* lunarMonth;		// 月名称
@property (nonatomic, readonly) NSString* lunarMonthNn;		// 月大小
@property (nonatomic, readonly) NSString* lunarLeap;    // 闰状况(值为'闰'或空串)
@property (nonatomic, readonly) NSString* nextLunarMonth;		// 下个月名称,判断除夕时要用到
//·日的农历纪年、月、日、时及星座
@property (nonatomic, readonly) NSString* Lyear;		// 农历纪年(10进制,1984年起算,分界点可以是立春也可以是春节,在程序中选择一个)
@property (nonatomic, readonly) NSString* Lyear2;		//干支纪年
@property (nonatomic, readonly) NSString* Lmonth;		// 纪月处理,1998年12月7日(大雪)开始连续进行节气计数,0为甲子
@property (nonatomic, readonly) NSString* Lmonth2;		//干支纪月
@property (nonatomic, readonly) NSString* Lday2;		// 纪日
@property (nonatomic, readonly) NSString* Ltime2;		//纪时
@property (nonatomic, readonly) NSString* zodiac;		//星座
//·日的回历信息
@property (nonatomic, readonly) NSString* Hyear;		// 年(回历)
@property (nonatomic, readonly) NSString* Hmonth;		//月(回历)
@property (nonatomic, readonly) NSString* Hday;		//  日(回历)
//·日的其它信息
@property (nonatomic, readonly) NSString* yxmc;		//月相名称
@property (nonatomic, readonly) NSString* yxjd;		//月相时刻(儒略日)
@property (nonatomic, readonly) NSString* yxsj;		//月相时间串
@property (nonatomic, readonly) NSString* jqmc;		//节气名称
@property (nonatomic, readonly) NSString* jqjd;		//节气时刻(儒略日)
@property (nonatomic, readonly) NSString* jqsj;		//节气时间串

@end

@interface LunarCalendar : NSObject

- (LunarCalendarMonth *)month:(NSInteger)month inYear:(NSInteger)year;

@end


