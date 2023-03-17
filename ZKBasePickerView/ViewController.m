//
//  ViewController.m
//  ZKBasePickerView
//
//  Created by 李雪健 on 2023/3/17.
//

#import "ViewController.h"
#import "ZKBasePickerView.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
}

- (IBAction)buttonAction:(id)sender {
    
    NSMutableArray *titleArray = @[].mutableCopy;
    for (NSString *title in @[@"123", @"456", @"789", @"000"]) {
        ZKBaseResponseSelectionOption *op = [[ZKBaseResponseSelectionOption alloc] init];
        op.oId = title;
        op.name = title;
        [titleArray addObject:op];
    }

    ZKBasePickerView *pickerView = [[ZKBasePickerView alloc] initWithData:@[titleArray] scrollToSelected:nil completeBlock:^(NSArray<ZKBaseResponseSelectionOption *> *selectArray) {
        ZKBaseResponseSelectionOption *option = selectArray.firstObject;
        NSLog(@"%@ %@", option.oId, option.name);
    }];
    pickerView.pickerViewTitle = @"Country Code";
    pickerView.doneButtonColor = UIColor.redColor;
    pickerView.doneButtonTitle = @"Done";
    pickerView.cancelButtonTitle = @"Cancel";
    pickerView.pickerBackgroundColor = UIColor.yellowColor;
    pickerView.datePickerColor = [UIColor whiteColor];
    [pickerView show];
}

@end
