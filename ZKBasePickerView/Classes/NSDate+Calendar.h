//
//  NSDate+Calendar.h
//  ZKBaseUIKit
//
//  Created by Apple on 2022/5/30.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSDate (Calendar)

+ (NSDate *)date:(NSString *)datestr withFormat:(NSString *)format;

- (int)zk_year;
- (int)zk_month;
- (int)zk_day;
- (int)zk_hour;
- (int)zk_minute;
- (int)zk_second;

@end

NS_ASSUME_NONNULL_END
