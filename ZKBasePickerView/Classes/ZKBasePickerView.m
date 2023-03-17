//
//  ZKBasePickerView.h
//  ZKBasePickerView
//
//  Created by Apple on 2019/12/12.
//

#import "ZKBasePickerView.h"
#import <Masonry/Masonry.h>
#import "NSDate+Calendar.h"

#define kPickerSize self.datePicker.frame.size
#define bottom_height (([[UIApplication sharedApplication] statusBarFrame].size.height > 20.0) ? 64.f : 40.f)


typedef void(^doneBlock)(NSDate *);
typedef void(^unDatedoneBlock)(NSArray<ZKBaseResponseSelectionOption *>*);

@implementation ZKBaseResponseSelectionOption
@end

@interface ZKBasePickerView ()<UIPickerViewDelegate,UIPickerViewDataSource,UIGestureRecognizerDelegate> {
    //日期存储数组
    NSMutableArray *_yearArray;
    NSMutableArray *_monthArray;
    NSMutableArray *_dayArray;
    NSMutableArray *_hourArray;
    NSMutableArray *_minuteArray;
    NSMutableArray *_secondArray;
    NSString *_dateFormatter;
    NSArray *_dateUnitArray;
    //记录位置
    NSInteger yearIndex;
    NSInteger monthIndex;
    NSInteger dayIndex;
    NSInteger hourIndex;
    NSInteger _minuteIndex;
    NSInteger secondIndex;
    
    NSInteger preRow;//日期滚动到的位置
    NSDate *_startDate;//选中时间
    NSInteger _maxYear;//最大时间年限
    NSInteger _minYear;//最小时间年限
    
    NSDate *_minDate;
    NSDate *_maxDate;
    NSString *_yearstring;
    NSString *_monthstring;
    NSString *_daystring;
    NSString *_hourstring;
    NSString *_minitstring;
    NSString *_secondstring;
}
@property (weak, nonatomic) IBOutlet UIButton *doneBtn;//确定按钮
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomConstraint;
@property (weak, nonatomic) IBOutlet UILabel *statusTitle;//状态标题
@property (weak, nonatomic) IBOutlet UIButton *cancelTitle;//取消按钮
- (IBAction)doneAction:(UIButton *)btn;
- (IBAction)cancelAction:(UIButton *)sender;
@property (weak, nonatomic) IBOutlet UIView *statusView;//取消确定栏

@property (weak, nonatomic) IBOutlet UIView *longTimeView;//长期View
@property (weak, nonatomic) IBOutlet UIButton *longTimeButton;//长期按钮
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topConstraint;


@property (nonatomic,strong)NSArray <NSArray<ZKBaseResponseSelectionOption*>*>*unDateArray;//非日期数据
@property (nonatomic,strong)UIPickerView *datePicker;
@property (nonatomic,strong) NSDate *scrollToDate;//滚到指定日期
@property (nonatomic,strong) NSMutableArray <ZKBaseResponseSelectionOption*>*scrollToSelected;//非日期滚到指定位置
@property (nonatomic,copy)doneBlock doneBlock;//日期回调block
@property (nonatomic,copy)unDatedoneBlock unDatedoneBlock;//非日期回调block
@property (nonatomic,assign)DLDateStyle datePickerStyle;
@property (nonatomic,strong)NSMutableArray *unDateSelectArr;//非日期选择数据

@end

@implementation ZKBasePickerView

// 设置对应的formatter and 时间单元
- (void)setDateFormatterAndUnit
{
    switch (self.datePickerStyle) {
        case ZKDateStyleShowYearMonthDayHourMinute:
            _dateFormatter = @"yyyy-MM-dd HH:mm";
            _dateUnitArray = @[@"年",@"月",@"日",@"时",@"分"];
            break;
        case ZKDateStyleShowMonthDayHourMinute:
            _dateFormatter = @"MM-dd HH:mm";
            _dateUnitArray = @[@"月",@"日",@"时",@"分"];
            break;
        case ZKDateStyleShowYearMonthDay:
            _dateFormatter = @"yyyy-MM-dd";
            _dateUnitArray = @[@"年",@"月",@"日"];
            break;
        case ZKDateStyleShowYearMonth:
            _dateFormatter = @"yyyy-MM";
            _dateUnitArray = @[@"年",@"月"];
            break;
        case ZKDateStyleShowMonthDay:
            _dateFormatter = @"MM-dd";
            _dateUnitArray = @[@"月",@"日"];
            break;
        case ZKDateStyleShowHourMinute:
            _dateFormatter = @"HH:mm";
            _dateUnitArray = @[@"时",@"分"];
            break;
        case ZKDateStyleShowYear:
            _dateFormatter = @"yyyy";
            _dateUnitArray = @[@"年"];
            break;
        case ZKDateStyleShowMonth:
            _dateFormatter = @"MM";
            _dateUnitArray = @[@"月"];
            break;
        case ZKDateStyleShowDayHourMinute:
            _dateFormatter = @"dd HH:mm";
            _dateUnitArray = @[@"日",@"时",@"分"];
            break;
        case ZKDateStyleShowYearMonthDayHour:
            _dateFormatter = @"yyyy-MM-dd HH";
            _dateUnitArray = @[@"年",@"月",@"日",@"时"];
            break;
        case ZKDateStyleShowYearMonthDayHourMinuteSecond:
            _dateFormatter = @"yyyy-MM-dd HH:mm:ss";
            _dateUnitArray = @[@"年",@"月",@"日",@"时",@"分",@"秒"];
            break;
        case ZKDateStyleShowHourMinuteSecond:
            _dateFormatter = @"HH:mm:ss";
            _dateUnitArray = @[@"时",@"分",@"秒"];
            break;
        default:
            _dateFormatter = @"yyyy-MM-dd HH:mm:ss";
            _dateUnitArray = @[];
            break;
    }
}

// 根据限制日期设置一个与类型对应完成的日期
- (NSDate *)setWholeDateWithDate:(NSDate *)limitDate
{
    NSString *limitYear = [NSString stringWithFormat:@"%04d",[limitDate zk_year]];
    NSString *limitMonth = [NSString stringWithFormat:@"%02d",[limitDate zk_month]];
    NSString *limitDay = [NSString stringWithFormat:@"%02d",[limitDate zk_day]];
    NSString *limitHour = [NSString stringWithFormat:@"%02d",[limitDate zk_hour]];
    NSString *limitMinute = [NSString stringWithFormat:@"%02d",[limitDate zk_minute]];
    NSString *limitSecond = [NSString stringWithFormat:@"%02d",[limitDate zk_second]];
    
    NSDate *currentDate = [NSDate date];
    //年-月-日 没显示的补充当前的年月日
    NSString *currentYear = [NSString stringWithFormat:@"%04d",[currentDate zk_year]];
    NSString *currentMonth = [NSString stringWithFormat:@"%02d",[currentDate zk_month]];
    NSString *currentDay = [NSString stringWithFormat:@"%02d",[currentDate zk_day]];
    //时:分:秒 没显示的补充00
    NSString *currentHour = @"00";// [NSString stringWithFormat:@"%02d",[currentDate getHour]];
    NSString *currentMinute = @"00";//[NSString stringWithFormat:@"%02d",[currentDate getMinute]];
    NSString *currentSecond = @"00";//[NSString stringWithFormat:@"%02d",[currentDate getSecond]];
    
    //年-月-日 没显示的补充当前的年月日
    NSMutableArray *ymdArr = @[].mutableCopy;
    NSString *yearString = [_dateUnitArray containsObject:@"年"]?limitYear:currentYear;
    [ymdArr addObject: yearString];
    NSString *monthStr = [_dateUnitArray containsObject:@"月"]?limitMonth:currentMonth;
    [ymdArr addObject:monthStr];
    NSString *dayStr = [_dateUnitArray containsObject:@"日"]?limitDay:currentDay;
    int maxDay = [self ht_getCurrentAllDay:yearString.intValue andmonth:monthStr.intValue];
    if (dayStr.intValue > maxDay) {
        dayStr = [NSString stringWithFormat:@"%02d",maxDay];
    }
    [ymdArr addObject:dayStr];
    NSString *ymdStr = ymdArr.count ? [ymdArr componentsJoinedByString:@"-"] : nil;
    
    //时:分:秒 没显示的补充00
    NSMutableArray *hmsArr = @[].mutableCopy;
    [hmsArr addObject:[_dateUnitArray containsObject:@"时"]?limitHour:currentHour];
    [hmsArr addObject:[_dateUnitArray containsObject:@"分"]?limitMinute:currentMinute];
    [hmsArr addObject:[_dateUnitArray containsObject:@"秒"]?limitSecond:currentSecond];
    
    NSString *hmsStr = hmsArr.count ? [hmsArr componentsJoinedByString:@":"] : nil;
    
    //年-月-日 时:分:秒
    NSMutableArray *ymdhmsArray = @[].mutableCopy;
    if (ymdStr.length > 0) {
        [ymdhmsArray addObject:ymdStr];
    }
    if (hmsStr.length > 0) {
        [ymdhmsArray addObject:hmsStr];
    }
    NSString *dateStr = [ymdhmsArray componentsJoinedByString:@" "];
    
    return [NSDate date:dateStr withFormat:@"yyyy-MM-dd HH:mm:ss"];
}

-(instancetype)initWithDateStyle:(DLDateStyle)datePickerStyle maxYear:(NSInteger)maxYear minYear:(NSInteger)minYear completeBlock:(void(^)(NSDate *))completeBlock {
    return [self initNewWithDateStyle:datePickerStyle maxYear:maxYear maxYearStr:nil minYear:minYear minYearStr:nil formatStr:nil scrollToDate:nil completeBlock:completeBlock];
}

-(instancetype)initWithDateStyle:(DLDateStyle)datePickerStyle maxYear:(NSInteger)maxYear minYear:(NSInteger)minYear scrollToDate:(NSDate *)scrollToDate completeBlock:(void(^)(NSDate *))completeBlock {
    return [self initNewWithDateStyle:datePickerStyle maxYear:maxYear maxYearStr:nil minYear:minYear minYearStr:nil formatStr:nil scrollToDate:scrollToDate completeBlock:completeBlock];
}

-(instancetype)initNewWithDateStyle:(DLDateStyle)datePickerStyle maxYear:(NSInteger)maxYear maxYearStr:(NSString *)maxYearStr minYear:(NSInteger)minYear minYearStr:(NSString *)minYearStr scrollToDate:(NSDate *)scrollToDate completeBlock:(void(^)(NSDate *))completeBlock {
    return [self initNewWithDateStyle:datePickerStyle maxYear:maxYear maxYearStr:maxYearStr minYear:minYear minYearStr:minYearStr formatStr:nil scrollToDate:scrollToDate completeBlock:completeBlock];
}

-(instancetype)initWithDateStyle:(DLDateStyle)datePickerStyle maxYearStr:(NSString *)maxYearStr minYearStr:(NSString *)minYearStr completeBlock:(void(^)(NSDate *))completeBlock{
    return [self initNewWithDateStyle:datePickerStyle maxYear:0 maxYearStr:maxYearStr minYear:0 minYearStr:minYearStr formatStr:nil scrollToDate:nil completeBlock:completeBlock];
}

-(instancetype)initWithDateStyle:(DLDateStyle)datePickerStyle maxYearStr:(NSString *)maxYearStr minYearStr:(NSString *)minYearStr formatStr:(NSString *)format completeBlock:(void(^)(NSDate *))completeBlock {
    return [self initNewWithDateStyle:datePickerStyle maxYear:0 maxYearStr:maxYearStr minYear:0 minYearStr:minYearStr formatStr:format scrollToDate:nil completeBlock:completeBlock];
}

- (instancetype)initNewWithDateStyle:(DLDateStyle)datePickerStyle maxYear:(NSInteger)maxYear maxYearStr:(NSString *)maxYearStr minYear:(NSInteger)minYear minYearStr:(NSString *)minYearStr formatStr:(NSString *)format scrollToDate:(NSDate *)scrollToDate completeBlock:(void (^)(NSDate *))completeBlock
{
    self = [super init];
    if (self) {
        self = [[[NSBundle bundleForClass:[self class]] loadNibNamed:NSStringFromClass([self class]) owner:self options:nil] lastObject];
        
        self.datePickerStyle = datePickerStyle;
        self.scrollToDate = scrollToDate;
        
        //忽略传入的format
        [self setDateFormatterAndUnit];
        
        //时间范围-最大值 maxYearStr 优先级高于 maxYear
        NSDate *maxYearDate;
        if (maxYearStr.length > 0) {
            maxYearDate = [NSDate date:maxYearStr withFormat:_dateFormatter];
        }
        if (maxYearDate == nil) {
            NSString *dateStr = [NSString stringWithFormat:@"%04zd%@",maxYear > 0 ? maxYear : 2100, @"-12-31 23:59:59"];
            maxYearDate = [NSDate date:dateStr withFormat:@"yyyy-MM-dd HH:mm:ss"];
        }
        maxYearDate = [self setWholeDateWithDate:maxYearDate];
        
        //时间范围-最小值 minYearStr 优先级高于 minYear
        NSDate *minYearDate;
        if (minYearStr.length > 0) {
            minYearDate = [NSDate date:minYearStr withFormat:_dateFormatter];
        }
        if (minYearDate == nil) {
            NSString *dateStr = [NSString stringWithFormat:@"%04zd%@",(maxYear > 0 && minYear > 0 && minYear <= maxYear) ? minYear : 1900, @"-01-01 00:00:00"];
            minYearDate = [NSDate date:dateStr withFormat:@"yyyy-MM-dd HH:mm:ss"];
        }
        minYearDate = [self setWholeDateWithDate:minYearDate];
        
        if (!maxYearDate || !minYearDate)  return nil;
        
        _maxYear = [maxYearDate zk_year];
        _minYear = [minYearDate zk_year];
        if (_minYear > _maxYear) return nil;
        
        //默认显示时间
        if (!self.scrollToDate) {
            self.scrollToDate = [NSDate date];
        }
        self.scrollToDate = [self setWholeDateWithDate:self.scrollToDate];
        //未在范围内则显示临界值
        if ([self.scrollToDate timeIntervalSinceDate:minYearDate] < 0) {
            self.scrollToDate = minYearDate;
        }else if([self.scrollToDate timeIntervalSinceDate:maxYearDate] > 0){
            self.scrollToDate = maxYearDate;
        }
        
        self.maxLimitDate = maxYearDate;
        self.minLimitDate = minYearDate;
        _minDate = minYearDate;
        _maxDate = maxYearDate;
      
        _yearArray = [[NSMutableArray alloc] init];
        _monthArray = [[NSMutableArray alloc] init];
        _dayArray = [[NSMutableArray alloc] init];
        _hourArray = [[NSMutableArray alloc] init];
        _minuteArray = [[NSMutableArray alloc] init];
        _secondArray = [[NSMutableArray alloc] init];
        
        _yearstring = [NSString stringWithFormat:@"%04d",[self.scrollToDate zk_year]];
        _monthstring = [NSString stringWithFormat:@"%02d",[self.scrollToDate zk_month]];
        _daystring = [NSString stringWithFormat:@"%02d",[self.scrollToDate zk_day]];
        _hourstring = [NSString stringWithFormat:@"%02d",[self.scrollToDate zk_hour]];
        _minitstring = [NSString stringWithFormat:@"%02d",[self.scrollToDate zk_minute]];
        _secondstring = [NSString stringWithFormat:@"%02d",[self.scrollToDate zk_second]];
        
        [self getAllUnitArray:0];
       
        [self setupUI];
        self.pickerViewTitle = @"Select time";
        self.pickerViewTitleFont = 20;
        self.dateLabelColor = [self colorWithHex:0x222222];
        self.datePickerColor = [self colorWithHex:0x222222];
        
        [self getNowDate:self.scrollToDate animated:NO];

        if (completeBlock) {
            self.doneBlock = ^(NSDate *selectDate) {
                completeBlock(selectDate);
            };
        }
    }
    return self;
}

- (UIColor *)colorWithHex:(int)integer {
    return [UIColor colorWithRed:((float)((integer & 0xFF0000) >> 16))/255.0  green:((float)((integer & 0xFF00) >> 8))/255.0 blue:((float)(integer & 0xFF))/255.0 alpha:1.0];
}

-(instancetype)initWithData:(NSArray <NSArray <ZKBaseResponseSelectionOption*>*>*)array completeBlock:(void(^)(NSArray<ZKBaseResponseSelectionOption *> *))completeBlock
{
    self = [super init];
    if (self) {
        self = [[[NSBundle bundleForClass:[self class]] loadNibNamed:NSStringFromClass([self class]) owner:self options:nil] lastObject];
        if (self.pickerViewTitle && self.pickerViewTitle.length > 0) {
            self.self.statusTitle.text = self.pickerViewTitle;
        }
        self.unDateArray = array;
        self.datePickerStyle = unZKDateStyleShow;
        [self setupUI];
        
        if (completeBlock) {
            self.unDatedoneBlock = ^(NSArray<ZKBaseResponseSelectionOption *> *unDateSelectArr) {
                completeBlock(unDateSelectArr);
            };
        }
    }
    return self;
}

-(instancetype)initWithData:(NSArray <NSArray <ZKBaseResponseSelectionOption*>*>*)array scrollToSelected:(NSArray<ZKBaseResponseSelectionOption *> *)scrollToSelected completeBlock:(void(^)(NSArray<ZKBaseResponseSelectionOption *> *))completeBlock{
    self = [super init];
    if (self) {

        self = [[[NSBundle bundleForClass:[self class]] loadNibNamed:NSStringFromClass([self class]) owner:self options:nil] lastObject];
        if (self.pickerViewTitle && self.pickerViewTitle.length > 0) {
            self.self.statusTitle.text = self.pickerViewTitle;
        }
        self.unDateArray = array;
        self.datePickerStyle = unZKDateStyleShow;
        [self.scrollToSelected removeAllObjects];
        [self.scrollToSelected addObjectsFromArray:scrollToSelected];
        [self setupUI];
        
        if (completeBlock) {
            self.unDatedoneBlock = ^(NSArray<ZKBaseResponseSelectionOption *> *unDateSelectArr) {
                completeBlock(unDateSelectArr);
            };
        }
    }
    return self;
}

-(void)setupUI {
    
    self.frame = CGRectMake(0, 0, UIScreen.mainScreen.bounds.size.width, UIScreen.mainScreen.bounds.size.height);
    
    self.buttomView.backgroundColor = [self dynamicColor:[UIColor whiteColor] darkColor:[self colorWithHex:0x2D2D2E]];
    self.statusView.backgroundColor = [self dynamicColor:[UIColor whiteColor] darkColor:[self colorWithHex:0x2D2D2E]];
    self.longTimeView.backgroundColor = [self dynamicColor:[UIColor whiteColor] darkColor:[self colorWithHex:0x2D2D2E]];
    self.doneBtn.backgroundColor = [self dynamicColor:[UIColor whiteColor] darkColor:[self colorWithHex:0x2D2D2E]];
    [self.cancelTitle setTitleColor:[self dynamicColor:[self colorWithHex:0x555555] darkColor:[self colorWithHex:0x868686]] forState:UIControlStateNormal];
    [self.doneBtn setTitleColor:[self dynamicColor:[self colorWithHex:0x4974f5] darkColor:[self colorWithHex:0x4974f5]] forState:UIControlStateNormal];
    [self.cancelTitle.titleLabel setFont:[UIFont systemFontOfSize:16]];
    [self.doneBtn.titleLabel setFont:[UIFont boldSystemFontOfSize:16]];

    //点击背景是否影藏
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(dismiss)];
    tap.delegate = self;
    [self addGestureRecognizer:tap];
    
    self.bottomConstraint.constant = -400;
    self.backgroundColor = [UIColor.blackColor colorWithAlphaComponent:0];
    [self layoutIfNeeded];
    self.longTimeView.hidden = YES;
    
    
    [[UIApplication sharedApplication].keyWindow bringSubviewToFront:self];
    
    [self.buttomView addSubview:self.datePicker];
    
    [self.datePicker mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(self.buttomView);
        make.bottom.equalTo(self.buttomView.mas_bottom).offset(-bottom_height);
    }];
    self.topConstraint.constant = self.datePicker.frame.size.height+20;
}

- (UIColor *)dynamicColor:(UIColor *)lightColor darkColor:(UIColor *)darkColor
{
#ifdef __IPHONE_13_0
    if (@available(iOS 13.0, *)) {
        UIColor *dyColor = [UIColor colorWithDynamicProvider:^UIColor * _Nonnull(UITraitCollection * _Nonnull traitCollection) {
            return traitCollection.userInterfaceStyle == UIUserInterfaceStyleLight ? lightColor : darkColor;
        }];
        return dyColor;
    } else {
        return lightColor;
    }
#else
    return lightColor;
#endif
    return lightColor;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:self.statusView.bounds byRoundingCorners: UIRectCornerTopLeft | UIRectCornerTopRight  cornerRadii:CGSizeMake(15, 15)];
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = self.statusView.bounds;
    maskLayer.path = maskPath.CGPath;
    self.statusView.layer.mask = maskLayer;
}

-(void)setDateLabelColor:(UIColor *)dateLabelColor {
    _dateLabelColor = dateLabelColor;
    self.statusTitle.textColor = _dateLabelColor;
    for (id subView in self.buttomView.subviews) {
        if ([subView isKindOfClass:[UILabel class]]) {
            UILabel *label = subView;
            label.textColor = _dateLabelColor;
        }
    }
}

-(void)setPickerViewTitleFont:(CGFloat )pickerViewTitleFont{
    self.statusTitle.font = [UIFont systemFontOfSize:pickerViewTitleFont];
}

- (void)setPickerBackgroundColor:(UIColor *)pickerBackgroundColor{
    _pickerBackgroundColor = pickerBackgroundColor;
    self.buttomView.backgroundColor = pickerBackgroundColor;
    self.statusView.backgroundColor = pickerBackgroundColor;
    self.doneBtn.backgroundColor = pickerBackgroundColor;
}

- (NSMutableArray *)setArray:(id)mutableArray
{
    if (mutableArray)
        [mutableArray removeAllObjects];
    else
        mutableArray = [NSMutableArray array];
    return mutableArray;
}

-(void)setYearLabelColor:(UIColor *)yearLabelColor {
    
}

#pragma mark - UIPickerViewDelegate,UIPickerViewDataSource
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    if (self.datePickerStyle == unZKDateStyleShow) {
        return self.unDateArray.count;
    }
    return _dateUnitArray.count;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    
    if (self.datePickerStyle == unZKDateStyleShow) {
        if (![self.unDateArray[component] isKindOfClass:NSArray.class]) return 0;
        NSArray *array = self.unDateArray[component];
        return array.count;
    }
    
    NSString *unitStr = _dateUnitArray[component];
    NSInteger rows = 0;
    if ([unitStr isEqualToString:@"年"]) {
        rows = _yearArray.count;
    }else if ([unitStr isEqualToString:@"月"]) {
        rows = _monthArray.count;
    }else if ([unitStr isEqualToString:@"日"]) {
        rows = _dayArray.count;
    }else if ([unitStr isEqualToString:@"时"]) {
        rows = _hourArray.count;
    }else if ([unitStr isEqualToString:@"分"]) {
        rows = _minuteArray.count;
    }else if ([unitStr isEqualToString:@"秒"]) {
        rows = _secondArray.count;
    }
    return rows;
}

-(CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component {
    return 40;
}

- (NSInteger)isDark
{
    #ifdef __IPHONE_13_0
        if (@available(iOS 13.0, *)) {
            return UITraitCollection.currentTraitCollection.userInterfaceStyle == UIUserInterfaceStyleDark;
        } else {
            return 0;
        }
    #else
        return 0;
    #endif
        return 0;
}

-(UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view {
    //设置分割线的颜色
    if (self.isDark) {
        for(UIView *singleLine in pickerView.subviews){
            if (singleLine.frame.size.height < 1){
                singleLine.backgroundColor = [self colorWithHex:0xFF3C3C3D];
                CGRect frame = singleLine.frame;
                frame.origin.x = 20;
                frame.size.width = UIScreen.mainScreen.bounds.size.width - 40;
                frame.size.height = 0.5;
                singleLine.frame = frame;
            }
        }
    
    }
    
    UILabel *customLabel = (UILabel *)view;
    if (!customLabel) {
        customLabel = [[UILabel alloc] init];
        customLabel.textAlignment = NSTextAlignmentCenter;
        [customLabel setFont:[UIFont systemFontOfSize:self.datePickerStyle==ZKDateStyleShowYearMonthDayHourMinuteSecond?12:16]];
        customLabel.adjustsFontSizeToFitWidth = YES;
    }
    NSString *title;
    if (self.datePickerStyle == unZKDateStyleShow) {
        NSArray <ZKBaseResponseSelectionOption*>*selectArr = self.unDateArray[component];
        title = selectArr[row].name;
    }else{
        NSString *unitStr = _dateUnitArray[component];
        if ([unitStr isEqualToString:@"年"]) {
            title = _yearArray[row];
        }else if ([unitStr isEqualToString:@"月"]) {
            title = _monthArray[row];
        }else if ([unitStr isEqualToString:@"日"]) {
            title = _dayArray[row];
        }else if ([unitStr isEqualToString:@"时"]) {
            title = _hourArray[row];
        }else if ([unitStr isEqualToString:@"分"]) {
            title = _minuteArray[row];
        }else if ([unitStr isEqualToString:@"秒"]) {
            title = _secondArray[row];
        }
        //NSInteger selectedRow = [pickerView selectedRowInComponent:component];
        //if (selectedRow == row) {
        if(self.showUnit){
            title = [NSString stringWithFormat:@"%@%@",title,unitStr];
        }else{
            title = [NSString stringWithFormat:@"%@",title];
        }
        //}
    }
        
    customLabel.text = title;
    if (!_datePickerColor) {
        _datePickerColor = [UIColor blackColor];
    }
    customLabel.textColor = _datePickerColor;
    return customLabel;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if (self.datePickerStyle == unZKDateStyleShow) {
        NSArray <ZKBaseResponseSelectionOption*>*selectArr = self.unDateArray[component];
        if (self.scrollToSelected.count > 0 && self.scrollToSelected.count == self.unDateArray.count) {
            [self.scrollToSelected replaceObjectAtIndex:component withObject:selectArr[row]];
        }else{
            if (self.scrollToSelected.count > 0) {
                if (component >= self.scrollToSelected.count) {
                    [self.scrollToSelected addObject:selectArr[row]];
                }
                [self.scrollToSelected replaceObjectAtIndex:component withObject:selectArr[row]];
            }else{
                if(self.unDateSelectArr && component < self.unDateSelectArr.count){
                    [self.unDateSelectArr replaceObjectAtIndex:component withObject:selectArr[row]];
                }
            }
        }
        [pickerView reloadAllComponents];
        return;
    }
    
    NSString *unitStr = _dateUnitArray[component];
    if ([unitStr isEqualToString:@"年"]) {
        yearIndex = row;
        _yearstring = _yearArray[row];
        [self getAllUnitArray:1];
    }else if ([unitStr isEqualToString:@"月"]) {
        monthIndex = row;
        _monthstring = _monthArray[row];
        [self getAllUnitArray:2];
    }else if ([unitStr isEqualToString:@"日"]) {
        dayIndex = row;
        _daystring = _dayArray[row];
        [self getAllUnitArray:3];
    }else if ([unitStr isEqualToString:@"时"]) {
        hourIndex = row;
        _hourstring = _hourArray[row];
        [self getAllUnitArray:4];
    }else if ([unitStr isEqualToString:@"分"]) {
        _minuteIndex = row;
        _minitstring = _minuteArray[row];
        [self getAllUnitArray:5];
    }else if ([unitStr isEqualToString:@"秒"]) {
        secondIndex = row;
        _secondstring = _secondArray[row];
    }
    
    [pickerView reloadAllComponents];
    //滚动到索引对应位置
    [self scrollIndexPostion:NO];
    
    //年-月-日
    NSMutableArray *ymdArr = @[].mutableCopy;
    if ([_dateUnitArray containsObject:@"年"]) {
        [ymdArr addObject:_yearstring];
    }
    if ([_dateUnitArray containsObject:@"月"]) {
        [ymdArr addObject:_monthstring];
    }
    if ([_dateUnitArray containsObject:@"日"]) {
        [ymdArr addObject:_daystring];
    }
    NSString *ymdStr = ymdArr.count ? [ymdArr componentsJoinedByString:@"-"] : nil;
    
    //时:分:秒
    NSMutableArray *hmsArr = @[].mutableCopy;
    if ([_dateUnitArray containsObject:@"时"]) {
        [hmsArr addObject:_hourstring];
    }
    if ([_dateUnitArray containsObject:@"分"]) {
        [hmsArr addObject:_minitstring];
    }
    if ([_dateUnitArray containsObject:@"秒"]) {
        [hmsArr addObject:_secondstring];
    }
    NSString *hmsStr = hmsArr.count ? [hmsArr componentsJoinedByString:@":"] : nil;
    
    //年-月-日 时:分:秒
    NSMutableArray *ymdhmsArr = @[].mutableCopy;
    if (ymdStr.length > 0) {
        [ymdhmsArr addObject:ymdStr];
    }
    if (hmsStr.length > 0) {
        [ymdhmsArr addObject:hmsStr];
    }
    
    NSString *dateStr = [ymdhmsArr componentsJoinedByString:@" "];
    NSDate *selectDate;
    if ([dateStr containsString:@"to date"]) {
        selectDate = [NSDate date];
    }else{
        selectDate = [NSDate date:dateStr withFormat:_dateFormatter];
    }
    self.scrollToDate = [self setWholeDateWithDate:selectDate];
    //未在范围内则显示临界值
    if ([self.scrollToDate timeIntervalSinceDate:self.minLimitDate] < 0) {
        self.scrollToDate = self.minLimitDate;
        [self getNowDate:self.minLimitDate animated:YES];
    }else if([self.scrollToDate timeIntervalSinceDate:self.maxLimitDate] > 0){
        self.scrollToDate = self.maxLimitDate;
        [self getNowDate:self.maxLimitDate animated:YES];
    }
    _startDate = self.scrollToDate;
}


#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if( [touch.view isDescendantOfView:self.buttomView]) {
        return NO;
    }
    return YES;
}

#pragma mark - Action
-(void)show {
    
    [[UIApplication sharedApplication].keyWindow addSubview:self];
    [UIView animateWithDuration:0.35f animations:^{
        self.bottomConstraint.constant = 0;
        self.backgroundColor = [UIColor.blackColor colorWithAlphaComponent:0.4];
        [self layoutIfNeeded];
        if (self.datePickerStyle == unZKDateStyleShow) {
            [self getNowSelectIndex];
        }
    }];
}
-(void)dismiss {
    [UIView animateWithDuration:0.35f animations:^{
        self.backgroundColor = [UIColor.blackColor colorWithAlphaComponent:0];
        self.bottomConstraint.constant = -400;
        [self layoutIfNeeded];
    } completion:^(BOOL finished) {
        //        [self.unDateSelectArr removeAllObjects];
        [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
        [self removeFromSuperview];
    }];
}




- (IBAction)doneAction:(UIButton *)btn {
    if (self.datePickerStyle != unZKDateStyleShow) {
        _startDate = self.scrollToDate;
        self.doneBlock(_startDate);
        if (self.isRetrunFirst) {
            
        }else{
            [self dismiss];
        }
    }else{
        
        if (self.scrollToSelected.count > 0 && self.scrollToSelected.count == self.unDateArray.count) {
            self.unDatedoneBlock(self.scrollToSelected);
        }else{
            if (self.scrollToSelected.count > 0) {
                [self.unDateSelectArr removeAllObjects];
                self.unDateSelectArr = self.scrollToSelected;
            }
            [self.unDateSelectArr removeObject:@""];
            self.unDatedoneBlock(self.unDateSelectArr);
        }
        [self dismiss];
    }
    
    
}

- (IBAction)cancelAction:(UIButton *)sender {
    [self dismiss];
}

///点击长期按钮
- (IBAction)longTimeClickAction:(UIButton *)sender {
    if (self.selectLongTimeBtnBlock) {
        self.selectLongTimeBtnBlock();
    }
    [self dismiss];
}

#pragma mark - tools
//滚动到指定的时间位置
- (void)getNowDate:(NSDate *)date animated:(BOOL)animated
{
    if (!date) return;
    
    _yearstring = [NSString stringWithFormat:@"%04d",[date zk_year]];
    _monthstring = [NSString stringWithFormat:@"%02d",[date zk_month]];
    _daystring = [NSString stringWithFormat:@"%02d",[date zk_day]];
    _hourstring = [NSString stringWithFormat:@"%02d",[date zk_hour]];
    _minitstring = [NSString stringWithFormat:@"%02d",[date zk_minute]];
    _secondstring = [NSString stringWithFormat:@"%02d",[date zk_second]];
    
    [self getAllUnitArray:0];
    [self.datePicker reloadAllComponents];
    
    //滚动到索引对应位置
    [self scrollIndexPostion:animated];
}

// 滚动到索引对应位置
- (void)scrollIndexPostion:(BOOL)animated
{
    for (NSInteger component = 0 ; component < _dateUnitArray.count; component ++) {
        NSString *unitStr = _dateUnitArray[component];
        NSInteger row = 0;
        if ([unitStr isEqualToString:@"年"]) {
            row = yearIndex;
        }else if ([unitStr isEqualToString:@"月"]) {
            row = monthIndex;
        }else if ([unitStr isEqualToString:@"日"]) {
            row = dayIndex;
        }else if ([unitStr isEqualToString:@"时"]) {
            row = hourIndex;
        }else if ([unitStr isEqualToString:@"分"]) {
            row = _minuteIndex;
        }else if ([unitStr isEqualToString:@"秒"]) {
            row = secondIndex;
        }
        [self.datePicker selectRow:row inComponent:component animated:animated];
    }
}

//滚动到指定的时间位置
- (void)getNowSelectIndex
{
    if (self.scrollToSelected.count != 0) {
        for (int i = 0; i<self.scrollToSelected.count; i++) {
            ZKBaseResponseSelectionOption *op = self.scrollToSelected[i];
            NSArray <ZKBaseResponseSelectionOption *>*array = self.unDateArray[i];
            for (int j = 0; j< array.count; j++) {
                ZKBaseResponseSelectionOption *columOp = array[j];
                if ([op.name isEqualToString:columOp.name]) {
                    [self.datePicker selectRow:j inComponent:i animated:YES];
                }
            }
        }
    }
}

#pragma mark - getter / setter
-(UIPickerView *)datePicker {
    if (!_datePicker) {
        [self.buttomView layoutIfNeeded];
        _datePicker = [[UIPickerView alloc] init];
        _datePicker.showsSelectionIndicator = YES;
        _datePicker.delegate = self;
        _datePicker.dataSource = self;
    }
    return _datePicker;
}

- (void)setPickerViewTitle:(NSString *)pickerViewTitle{
    _pickerViewTitle = pickerViewTitle;
    self.statusTitle.text = _pickerViewTitle;
}

- (void)setDoneButtonTitle:(NSString *)doneButtonTitle{
    [self.doneBtn setTitle:doneButtonTitle forState:UIControlStateNormal];
}

- (void)setCancelButtonTitle:(NSString *)cancelButtonTitle{
    [self.cancelTitle setTitle:cancelButtonTitle forState:UIControlStateNormal];
}

-(void)setDoneButtonColor:(UIColor *)doneButtonColor {
    _doneButtonColor = doneButtonColor;
    [self.doneBtn setTitleColor:doneButtonColor forState:UIControlStateNormal];
}

- (void)setShowLongTime:(BOOL)showLongTime {
    _showLongTime = showLongTime;
    _showLongTime == YES ? self.longTimeView.hidden = NO : YES;
}

- (void)setShowToNow:(BOOL)showToNow{
    _showToNow = showToNow;
    if (_showToNow) {
        [_yearArray addObject:@"to date"];
    }
}

- (void)setLongTimeTitleLab:(UILabel *)longTimeTitleLab{
    _longTimeTitleLab = longTimeTitleLab;
    [self.longTimeButton setTitle:_longTimeTitleLab.text forState:UIControlStateNormal];
    [self.longTimeButton setTitleColor:_longTimeTitleLab.textColor forState:UIControlStateNormal];
}

-(void)setHideBackgroundYearLabel:(BOOL)hideBackgroundYearLabel {
}

- (NSMutableArray *)unDateSelectArr
{
    if (!_unDateSelectArr) {
        _unDateSelectArr = [NSMutableArray arrayWithCapacity:self.unDateArray.count];
        for (int i = 0; i < self.unDateArray.count; i++) {
            [_unDateSelectArr addObject:@""];
        }
    }
    return _unDateSelectArr;
}

- (NSMutableArray<ZKBaseResponseSelectionOption *> *)scrollToSelected{
    if (!_scrollToSelected) {
        _scrollToSelected = [NSMutableArray array];
    }
    return _scrollToSelected;
}

- (void)getAllUnitArray:(NSUInteger)type
{
    //type 0年月日时分秒 1月日时分秒 2日时分秒 3时分秒 4分秒 5秒
    if (type == 0) {
        [self getYearsArray];
    }
    if (type <= 1) {
        [self getMonthsArray];
    }
    if (type <= 2) {
        [self getDaysArray];
    }
    if (type <= 3) {
        [self getHoursArray];
    }
    if (type <= 4) {
        [self getMinitsArray];
    }
    if (type <= 5) {
        [self getSecondsArray];
    }
}

-(void)getYearsArray{
    
    int minDateYear = [_minDate zk_year];
    int maxDateYear = [_maxDate zk_year];
    //组装年份范围
    [_yearArray removeAllObjects];
    for (int i=minDateYear; i<=maxDateYear; i++) {
        [_yearArray addObject:[NSString stringWithFormat:@"%04d",i]];
    }
    
    //根据当前显示年份获取对应的索引
    int c = [_yearstring intValue];
    int x = [_yearArray.firstObject intValue];
    int d = [_yearArray.lastObject intValue];
    if (c<=x) {
        yearIndex = 0;
    }
    else if (c>=d){
        yearIndex = _yearArray.count-1;
    }
    else if (c>x && c<d){
        yearIndex = c-x;
    }
    _yearstring = [_yearArray objectAtIndex:yearIndex];
    
}
-(void)getMonthsArray{
    
    int minDateYear = [_minDate zk_year];
    int maxDateYear = [_maxDate zk_year];
    
    int minDateMonth = [_minDate zk_month];
    int maxDateMonth = [_maxDate zk_month];
    
    int mStart = 1;
    int mEnd = 12;
    
    //判断最小日期与最大日期是否是同一年
    BOOL isEqualYear = minDateYear == maxDateYear;
    if (isEqualYear) {
        mStart = minDateMonth;
        mEnd = maxDateMonth;
    }else{
        //判断当前选择是否是最小年份
        BOOL isMinYear = _yearstring.intValue == [_yearArray.firstObject intValue];
        if (isMinYear) {
            mStart = minDateMonth;
        }
        //判断当前选择是否是最大年份
        BOOL isMaxYear = _yearstring.intValue == [_yearArray.lastObject intValue];
        if (isMaxYear) {
            mEnd = maxDateMonth;
        }
    }
    
    //组装月份范围
    [_monthArray removeAllObjects];
    for (int i=mStart; i<=mEnd; i++) {
        NSString *num = [NSString stringWithFormat:@"%02d",i];
        [_monthArray addObject:num];
    }
    
    //根据当前显示月份获取对应的索引
    int c = [_monthstring intValue];
    int x = [_monthArray.firstObject intValue];
    int d = [_monthArray.lastObject intValue];
    if (c<=x) {
        monthIndex = 0;
    }
    else if (c>=d){
        monthIndex = _monthArray.count-1;
    }
    else if (c>x && c<d){
        monthIndex = c-x;
    }
    _monthstring = [_monthArray objectAtIndex:monthIndex];
    
}

-(void)getDaysArray{
    int minDateYear = [_minDate zk_year];
    int maxDateYear = [_maxDate zk_year];
    
    int minDateMonth = [_minDate zk_month];
    int maxDateMonth = [_maxDate zk_month];
    
    int minDateDay = [_minDate zk_day];
    int maxDateDay = [_maxDate zk_day];
    
    //当前年月对应的天数
    int daycout = [self ht_getCurrentAllDay:[_yearstring intValue] andmonth:[_monthstring intValue]];
    int dStart = 1;
    int dEnd = daycout;
    
    //判断最小日期与最大日期是否是同一年、同一月
    BOOL isEqualYear = minDateYear == maxDateYear;
    BOOL isEqualMonth = minDateMonth == maxDateMonth;
    if (isEqualYear && isEqualMonth) {
        dStart = minDateDay;
        dEnd = maxDateDay;
    }else{
        //判断当前选择是否是最小年份、最小月份
        BOOL isMinYear = _yearstring.intValue == [_yearArray.firstObject intValue];
        BOOL isMinMonth = _monthstring.intValue  == [_monthArray.firstObject intValue];
        if (isMinYear && isMinMonth) {
            dStart = minDateDay;
        }
        //判断当前选择是否是最大年份、最大月份
        BOOL isMaxYear = _yearstring.intValue == [_yearArray.lastObject intValue];
        BOOL isMaxMonth = _monthstring.intValue == [_monthArray.lastObject intValue];
        if (isMaxYear && isMaxMonth) {
            dEnd = maxDateDay;
        }
    }
    
    //组装天数范围
    [_dayArray removeAllObjects];
    for (int i=dStart; i<=dEnd; i++) {
        [_dayArray addObject:[NSString stringWithFormat:@"%02d",i]];
    }
    
    //根据当前显示天获取对应的索引
    int c = [_daystring intValue];
    int x = [_dayArray.firstObject intValue];
    int d = [_dayArray.lastObject intValue];
    if (c<=x) {
        dayIndex = 0;
    }
    else if (c>=d){
        dayIndex = _dayArray.count-1;
    }
    else if (c>x && c<d){
        dayIndex = c-x;
    }
    _daystring = [_dayArray objectAtIndex:dayIndex];
}

-(void)getHoursArray{
    
    int minDateYear = [_minDate zk_year];
    int maxDateYear = [_maxDate zk_year];
    
    int minDateMonth = [_minDate zk_month];
    int maxDateMonth = [_maxDate zk_month];
    
    int minDateDay = [_minDate zk_day];
    int maxDateDay = [_maxDate zk_day];
    
    int minDateHour = [_minDate zk_hour];
    int maxDateHour = [_maxDate zk_hour];
    
    int hStart = 0;
    int hEnd = 23;
    
    //判断最小日期与最大日期是否是同一年、同一月、用一天
    BOOL isEqualYear = minDateYear == maxDateYear;
    BOOL isEqualMonth = minDateMonth == maxDateMonth;
    BOOL isEqualDay = minDateDay == maxDateDay;
    if (isEqualYear && isEqualMonth && isEqualDay) {
        hStart = minDateHour;
        hEnd = maxDateHour;
    }else{
        //判断当前选择是否是最小年份、最小月份、最小日
        BOOL isMinYear = _yearstring.intValue == [_yearArray.firstObject intValue];
        BOOL isMinMonth = _monthstring.intValue  == [_monthArray.firstObject intValue];
        BOOL isMinDay = _daystring.intValue == [_dayArray.firstObject intValue];
        if (isMinYear && isMinMonth && isMinDay) {
            hStart = minDateHour;
        }
        //判断当前选择是否是最大年份、最大月份、最大日
        BOOL isMaxYear = _yearstring.intValue == [_yearArray.lastObject intValue];
        BOOL isMaxMonth = _monthstring.intValue == [_monthArray.lastObject intValue];
        BOOL isMaxDay = _daystring.intValue == [_dayArray.lastObject intValue];
        if (isMaxYear && isMaxMonth && isMaxDay) {
            hEnd = maxDateHour;
        }
    }
    
    //组装小时范围
    [_hourArray removeAllObjects];
    for (int i=hStart; i<=hEnd; i++) {
        [_hourArray addObject:[NSString stringWithFormat:@"%02d",i]];
    }
    
    //根据当前显示小时获取对应的索引
    int c = [_hourstring intValue];
    int x = [_hourArray.firstObject intValue];
    int d = [_hourArray.lastObject intValue];
    if (c<=x) {
        hourIndex = 0;
    }
    else if (c>=d){
        hourIndex = _hourArray.count-1;
    }
    else if (c>x && c<d){
        hourIndex = c-x;
    }
    _hourstring = [_hourArray objectAtIndex:hourIndex];
    
}

-(void)getMinitsArray{
    
    int minDateYear = [_minDate zk_year];
    int maxDateYear = [_maxDate zk_year];
    
    int minDateMonth = [_minDate zk_month];
    int maxDateMonth = [_maxDate zk_month];
    
    int minDateDay = [_minDate zk_day];
    int maxDateDay = [_maxDate zk_day];
    
    int minDateHour = [_minDate zk_hour];
    int maxDateHour = [_maxDate zk_hour];
    
    int minDateMinute = [_minDate zk_minute];
    int maxDateMinute = [_maxDate zk_minute];
    
    int mStart = 0;
    int mEnd = 59;
    
    //判断最小日期与最大日期是否是同一年、同一月、用一天、同一时
    BOOL isEqualYear = minDateYear == maxDateYear;
    BOOL isEqualMonth = minDateMonth == maxDateMonth;
    BOOL isEqualDay = minDateDay == maxDateDay;
    BOOL isEqualHour = minDateHour == maxDateHour;
    if (isEqualYear && isEqualMonth && isEqualDay && isEqualHour) {
        mStart = minDateMinute;
        mEnd = maxDateMinute;
    }else{
        //判断当前选择是否是最小年份、最小月份、最小日、最小时
        BOOL isMinYear = _yearstring.intValue == [_yearArray.firstObject intValue];
        BOOL isMinMonth = _monthstring.intValue  == [_monthArray.firstObject intValue];
        BOOL isMinDay = _daystring.intValue == [_dayArray.firstObject intValue];
        BOOL isMinHour = _hourstring.intValue == [_hourArray.firstObject intValue];
        if (isMinYear && isMinMonth && isMinDay && isMinHour) {
            mStart = minDateMinute;
        }
        //判断当前选择是否是最大年份、最大月份、最大日、最大时
        BOOL isMaxYear = _yearstring.intValue == [_yearArray.lastObject intValue];
        BOOL isMaxMonth = _monthstring.intValue == [_monthArray.lastObject intValue];
        BOOL isMaxDay = _daystring.intValue == [_dayArray.lastObject intValue];
        BOOL isMaxHour = _hourstring.intValue == [_hourArray.lastObject intValue];
        if (isMaxYear && isMaxMonth && isMaxDay && isMaxHour) {
            mEnd = maxDateMinute;
        }
    }
    
    //组装分范围
    [_minuteArray removeAllObjects];
    for (int i=mStart; i<=mEnd; i++) {
        [_minuteArray addObject:[NSString stringWithFormat:@"%02d",i]];
    }
    
    //根据当前显示分获取对应的索引
    int c = [_minitstring intValue];
    int x = [_minuteArray.firstObject intValue];
    int d = [_minuteArray.lastObject intValue];
    if (c<=x) {
        _minuteIndex = 0;
    }
    else if (c>=d){
        _minuteIndex = _minuteArray.count-1;
    }
    else if (c>x && c<d){
        _minuteIndex = c-x;
    }
    _minitstring = [_minuteArray objectAtIndex:_minuteIndex];
    
}

-(void)getSecondsArray{
    int minDateYear = [_minDate zk_year];
    int maxDateYear = [_maxDate zk_year];
    
    int minDateMonth = [_minDate zk_month];
    int maxDateMonth = [_maxDate zk_month];
    
    int minDateDay = [_minDate zk_day];
    int maxDateDay = [_maxDate zk_day];
    
    int minDateHour = [_minDate zk_hour];
    int maxDateHour = [_maxDate zk_hour];
    
    int minDateMinute = [_minDate zk_minute];
    int maxDateMinute = [_maxDate zk_minute];
    
    int minDateSecond = [_minDate zk_second];
    int maxDateSecond = [_maxDate zk_second];

    int sStart = 0;
    int sEnd = 59;
    
    //判断最小日期与最大日期是否是同一年、同一月、用一天、同一时、同一分
    BOOL isEqualYear = minDateYear == maxDateYear;
    BOOL isEqualMonth = minDateMonth == maxDateMonth;
    BOOL isEqualDay = minDateDay == maxDateDay;
    BOOL isEqualHour = minDateHour == maxDateHour;
    BOOL isEqualMinute = minDateMinute == maxDateMinute;
    if (isEqualYear && isEqualMonth && isEqualDay && isEqualHour && isEqualMinute) {
        sStart = minDateSecond;
        sEnd = maxDateSecond;
    }else{
        //判断当前选择是否是最小年份、最小月份、最小日、最小时、最小分
        BOOL isMinYear = _yearstring.intValue == [_yearArray.firstObject intValue];
        BOOL isMinMonth = _monthstring.intValue  == [_monthArray.firstObject intValue];
        BOOL isMinDay = _daystring.intValue == [_dayArray.firstObject intValue];
        BOOL isMinHour = _hourstring.intValue == [_hourArray.firstObject intValue];
        BOOL isMinMinute = _minitstring.intValue == [_minuteArray.firstObject intValue];
        if (isMinYear && isMinMonth && isMinDay && isMinHour && isMinMinute) {
            sStart = minDateSecond;
        }
        //判断当前选择是否是最大年份、最大月份、最大日、最大时、最大分
        BOOL isMaxYear = _yearstring.intValue == [_yearArray.lastObject intValue];
        BOOL isMaxMonth = _monthstring.intValue == [_monthArray.lastObject intValue];
        BOOL isMaxDay = _daystring.intValue == [_dayArray.lastObject intValue];
        BOOL isMaxHour = _hourstring.intValue == [_hourArray.lastObject intValue];
        BOOL isMaxMinute = _minitstring.intValue == [_minuteArray.lastObject intValue];
        if (isMaxYear && isMaxMonth && isMaxDay && isMaxHour && isMaxMinute) {
            sEnd = maxDateSecond;
        }
    }
    
    //组装秒范围
    [_secondArray removeAllObjects];
    for (int i=sStart; i<=sEnd; i++) {
        [_secondArray addObject:[NSString stringWithFormat:@"%02d",i]];
    }
    
    //根据当前显示秒获取对应的索引
    int c = [_secondstring intValue];
    int x = [_secondArray.firstObject intValue];
    int d = [_secondArray.lastObject intValue];
    if (c<=x) {
        secondIndex = 0;
    }
    else if (c>=d){
        secondIndex = _secondArray.count-1;
    }
    else if (c>x && c<d){
        secondIndex = c-x;
    }
    _secondstring = [_secondArray objectAtIndex:secondIndex];
    
}

-(int)ht_getCurrentAllDay:(int)year andmonth:(int)month{
    
    int endDate = 0;
    switch (month) {
        case 1:
        case 3:
        case 5:
        case 7:
        case 8:
        case 10:
        case 12:
            endDate = 31;
            break;
        case 4:
        case 6:
        case 9:
        case 11:
            endDate = 30;
            break;
        case 2:
            // 是否为闰年
            if (year % 400 == 0) {
                endDate = 29;
            } else {
                if (year % 100 != 0 && year %4 ==4) {
                    endDate = 29;
                } else {
                    endDate = 28;
                }
            }
            break;
        default:
            break;
    }
    
    return endDate;
}
@end

