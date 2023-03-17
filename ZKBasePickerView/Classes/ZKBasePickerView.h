//
//  ZKBasePickerView.h
//  ZKBasePickerView
//
//  Created by Apple on 2019/12/12.
//

#import <UIKit/UIKit.h>

//弹出日期类型
typedef NS_ENUM(NSInteger, DLDateStyle){
    ZKDateStyleShowYearMonthDayHourMinute  = 0,//年月日时分
    ZKDateStyleShowMonthDayHourMinute,//月日时分
    ZKDateStyleShowYearMonthDay,//年月日
    ZKDateStyleShowYearMonth,//年月
    ZKDateStyleShowMonthDay,//月日
    ZKDateStyleShowHourMinute,//时分
    ZKDateStyleShowYear,//年
    ZKDateStyleShowMonth,//月
    ZKDateStyleShowDayHourMinute,//日时分
    ZKDateStyleShowYearMonthDayHour,//年月日时
    ZKDateStyleShowYearMonthDayHourMinuteSecond,//年月日时分秒
    ZKDateStyleShowHourMinuteSecond,//时分秒
    unZKDateStyleShow//非时间类型
};

@interface ZKBaseResponseSelectionOption : NSObject
@property (nonatomic, copy) NSString *name; //选项名称
@property (nonatomic, copy) NSString *oId;  //选项ID
@end


@interface ZKBasePickerView : UIView

//选择器试图
@property (weak, nonatomic) IBOutlet UIView *buttomView;

//标题
@property (nonatomic,copy)NSString *pickerViewTitle;

//标题 字体大小
@property (nonatomic,assign)CGFloat pickerViewTitleFont;

//选择器背景颜色
@property (nonatomic,strong)UIColor *pickerBackgroundColor;
//确定按钮颜色
@property (nonatomic,strong)UIColor *doneButtonColor;
//确定按钮文字
@property (nonatomic,copy)NSString *doneButtonTitle;
//取消按钮文字
@property (nonatomic,copy)NSString *cancelButtonTitle;
//年-月-日-时-分 文字颜色(默认橙色)
@property (nonatomic,strong)UIColor *dateLabelColor;
//滚轮日期颜色(默认黑色)
@property (nonatomic,strong)UIColor *datePickerColor;
// 限制最大时间（默认2099）datePicker大于最大日期则滚动回最大限制日期 [NSDate date:@"2099-12-31 23:59" WithFormat:@"yyyy-MM-dd HH:mm"]
@property (nonatomic, retain) NSDate *maxLimitDate;
// 限制最小时间（默认0） datePicker小于最小日期则滚动回最小限制日期
@property (nonatomic, retain) NSDate *minLimitDate;
//大号年份字体颜色(默认灰色)想隐藏可以设置为clearColor
@property (nonatomic, retain) UIColor *yearLabelColor;
//隐藏背景年份文字
@property (nonatomic, assign) BOOL hideBackgroundYearLabel;
//点击选择器下面固定按钮回调
@property (nonatomic, copy) void(^selectLongTimeBtnBlock)(void);
//选择器下面固定按钮wenzi
@property (nonatomic, strong) UILabel *longTimeTitleLab;
//是否显示“长期”
@property (nonatomic, assign) BOOL showLongTime;
//是否显示“至今”
@property (nonatomic, assign) BOOL showToNow;
//是否显示单位，默认不显示
@property (nonatomic, assign) BOOL showUnit;
//是否根据后面判断 再决定是否dismiss
@property (nonatomic, assign) BOOL isRetrunFirst;
//dismiss
-(void)dismiss;
//滚动到当前时间，如果当前时间未在时间范围类，则显示范围内的最小值
//@params datePickerStyle 日期类型
//@params maxYear 最大年限
//@params minYear 最小年限
//@params completeBlock 选中日期回调
-(instancetype)initWithDateStyle:(DLDateStyle)datePickerStyle maxYear:(NSInteger)maxYear minYear:(NSInteger)minYear completeBlock:(void(^)(NSDate *))completeBlock;
//滚动到指定的的时间，如果指定的的时间未在时间范围类，则显示范围内的最小值
//@params datePickerStyle 日期类型c
//@params maxYear 最大年限
//@params minYear 最小年限
//@params scrollToDate 滚动到指定日期
//@params completeBlock 选中日期回调
-(instancetype)initWithDateStyle:(DLDateStyle)datePickerStyle maxYear:(NSInteger)maxYear minYear:(NSInteger)minYear scrollToDate:(NSDate *)scrollToDate completeBlock:(void(^)(NSDate *))completeBlock;
//滚动到当前时间，如果当前时间未在时间范围类，则显示范围内的最小值
//@params datePickerStyle 日期类型
//@params maxYearStr 最大年限 yyyy-MM-dd HH:mm:ss格式，与日期类型对应
//@params minYearStr 最小年限 yyyy-MM-dd HH:mm:ss格式，与日期类型对应
//@params completeBlock 选中日期回调
-(instancetype)initWithDateStyle:(DLDateStyle)datePickerStyle maxYearStr:(NSString *)maxYearStr minYearStr:(NSString *)minYearStr completeBlock:(void(^)(NSDate *))completeBlock;
//滚动到当前时间，如果当前时间未在时间范围类，则显示范围内的最小值
//@params datePickerStyle 日期类型
//@params maxYearStr 最大年限 yyyy-MM-dd HH:mm:ss格式，与日期类型对应
//@params minYearStr 最小年限 yyyy-MM-dd HH:mm:ss格式，与日期类型对应
//@params format 时间格式
//@params completeBlock 选中日期回调
-(instancetype)initWithDateStyle:(DLDateStyle)datePickerStyle maxYearStr:(NSString *)maxYearStr minYearStr:(NSString *)minYearStr formatStr:(NSString *)format completeBlock:(void(^)(NSDate *))completeBlock;
//滚动到指定的的时间，如果指定的的时间未在时间范围类，则显示范围内的最小值
//@params datePickerStyle 日期类型
//@params maxYear 最大年限
//@params maxYearStr 最大年限 yyyy-MM-dd HH:mm:ss格式，与日期类型对应
//@params minYear 最小年限
//@params minYearStr 最小年限 yyyy-MM-dd HH:mm:ss格式，与日期类型对应
//@params scrollToDate 滚动到指定日期
//@params completeBlock 选中日期回调
-(instancetype)initNewWithDateStyle:(DLDateStyle)datePickerStyle maxYear:(NSInteger)maxYear maxYearStr:(NSString *)maxYearStr minYear:(NSInteger)minYear minYearStr:(NSString *)minYearStr scrollToDate:(NSDate *)scrollToDate completeBlock:(void(^)(NSDate *))completeBlock;
//滚动到指定的的时间，如果指定的的时间未在时间范围类，则显示范围内的最小值
//@params datePickerStyle 日期类型
//@params maxYear 最大年限
//@params maxYearStr 最大年限 yyyy-MM-dd HH:mm:ss格式，与日期类型对应
//@params minYear 最小年限
//@params minYearStr 最小年限 yyyy-MM-dd HH:mm:ss格式，与日期类型对应
//@params format 时间格式
//@params scrollToDate 滚动到指定日期
//@params completeBlock 选中日期回调
-(instancetype)initNewWithDateStyle:(DLDateStyle)datePickerStyle maxYear:(NSInteger)maxYear maxYearStr:(NSString *)maxYearStr minYear:(NSInteger)minYear minYearStr:(NSString *)minYearStr formatStr:(NSString *)format scrollToDate:(NSDate *)scrollToDate completeBlock:(void(^)(NSDate *))completeBlock;
//滚动选项
//@params array 数据
//@params completeBlock 选中回调
-(instancetype)initWithData:(NSArray <NSArray <ZKBaseResponseSelectionOption*>*>*)array completeBlock:(void(^)(NSArray<ZKBaseResponseSelectionOption *> *))completeBlock;
//滚动到指定选项
//@params array 数据
//@params scrollToSelected 选择指定位置数据
//@params completeBlock 选中回调
-(instancetype)initWithData:(NSArray <NSArray <ZKBaseResponseSelectionOption*>*>*)array scrollToSelected:(NSArray<ZKBaseResponseSelectionOption *> *)scrollToSelected completeBlock:(void(^)(NSArray<ZKBaseResponseSelectionOption *> *))completeBlock;

-(void)show;

@end

