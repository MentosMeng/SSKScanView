//
//  UIButton+Addtion.m
//  SaoMaTestDemo
//
//  Created by app on 16/3/22.
//  Copyright © 2016年 jinglun. All rights reserved.
//

#import "UIButton+Addtion.h"

@implementation UIButton (Addtion)
+ (UIButton *)buttonWithRect:(CGRect)rect
                   normalImg:(NSString *)normalImg
                andPushedImg:(NSString *)pushed
              andSelectedImg:(NSString *)selected
{
    UIButton *btn= [UIButton buttonWithType:UIButtonTypeCustom];
    
    if (normalImg != nil)
    {
        [btn setImage:[UIImage imageNamed:normalImg] forState:UIControlStateNormal];
    }
    
    if (pushed != nil)
    {
        [btn setImage:[UIImage imageNamed:pushed] forState:UIControlStateHighlighted];
    }
    
    if (selected != nil)
    {
        [btn setImage:[UIImage imageNamed:selected] forState:UIControlStateSelected];
    }
    
    [btn setFrame:rect];
    return btn;
}

@end
