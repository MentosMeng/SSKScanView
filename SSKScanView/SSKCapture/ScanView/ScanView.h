//
//  ScanView.h
//  SaoMaTestDemo
//
//  Created by app on 16/3/29.
//  Copyright © 2016年 jinglun. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^ScanSuccess)(NSString*codeNum);
typedef void(^ScanFail)();
typedef void(^Back)();
typedef void(^OpenPhotoLabiry)();

@interface ScanView : UIView

/**
 *
 * @param 初始化
 *
 */
-(id)initWithFrame:(CGRect)frame;
/**
 *
 * @param 调用扫描相册二维码
 *
 */
-(void)scanPicture:(UIImage*)erweimaImage;
/**
 *
 * @param 开始扫码,回调成功和失败
 *
 */
-(void)scanSuccess:(ScanSuccess)scanSuccess;
-(void)scanFail:(ScanFail)scanFail;
/**
 *
 * @param 返回
 */
-(void)comeBack:(Back)back;
/**
 *
 * @param 打开手机相册
 */
-(void)openXiangce:(OpenPhotoLabiry)photo;
/**
 *
 * @param 停止扫码
 *
 */
-(void)stopScan;
/**
 *
 * @param 开始扫码
 */
-(void)startScan;




@end
