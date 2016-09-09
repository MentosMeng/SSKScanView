//
//  UIButton+Addtion.h
//  SaoMaTestDemo
//
//  Created by app on 16/3/22.
//  Copyright © 2016年 jinglun. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIButton (Addtion)
+ (UIButton *)buttonWithRect:(CGRect)rect normalImg:(NSString *)normalImg andPushedImg:(NSString *)pushed andSelectedImg:(NSString *)selected;
@end
