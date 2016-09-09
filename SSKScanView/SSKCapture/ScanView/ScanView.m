//
//  ScanView.m
//  SaoMaTestDemo
//
//  Created by app on 16/3/29.
//  Copyright © 2016年 jinglun. All rights reserved.
//

#import "ScanView.h"
#import "UIButton+Addtion.h"
#import "ZBarSDK.h"
#import "ZBarReaderViewController.h"
#import <AVFoundation/AVFoundation.h>


typedef void(^StartScanFinish)(NSString*codeNumber);
typedef void(^ScanFinishFail)();
typedef void(^GoBack)();
typedef void(^ScanPhoto)();

@interface ScanView ()<ZBarReaderViewDelegate,ZBarReaderDelegate,UINavigationControllerDelegate, UIImagePickerControllerDelegate,NSURLConnectionDelegate,NSURLConnectionDataDelegate>{
    BOOL _torchIsOn;
    NSString *_out_url;
    int _state;  // 1:书籍 2:推介人
    NSMutableData * _backData;
}

@property (nonatomic,strong)UIButton *photoBtn;
@property (nonatomic,strong)UIButton *  flash;///<闪光灯
@property (nonatomic,strong)NSString *codeString;
@property (nonatomic,strong)ZBarReaderView *qreaderView;
@property (nonatomic,strong)UIImageView *saoMiaoLine;
@property (nonatomic,strong)UIImageView *imageWaiting;
@property (nonatomic,strong)UIImageView *imageWaitingGif;
@property (nonatomic,strong)UIImage * selectImg;///<
@property (strong,nonatomic)AVCaptureDevice * device;
@property (nonatomic, strong) NSDictionary *book_data;
@property (nonatomic, strong) UIImageView *hintView;
@property (nonatomic,assign)BOOL isLock;
@property (nonatomic,assign)BOOL isShowDetail;
@property (nonatomic,strong)UIImagePickerController *picker;
@property (nonatomic,strong)ZBarReaderController *reader ;


@property (nonatomic,copy)StartScanFinish scanFinish;///<扫码完成
@property (nonatomic,copy)ScanFinishFail  scanFailed;///<扫码失败
@property (nonatomic,copy)ScanPhoto       scanPLiabary;///<打开相册
@property (nonatomic,copy)GoBack          goback;///<返回上一层

@end

@implementation ScanView
-(id)initWithFrame:(CGRect)frame{
    self=[super initWithFrame:frame];
    if (self) {
        [self setUpScanUI:frame];
    }
    return self;
}
-(void)setUpScanUI:(CGRect)frame{
    _torchIsOn = NO;

    [self createSaoyiSaoUI];
    
    _photoBtn = [UIButton buttonWithRect:CGRectMake(self.bounds.size.width-70, self.bounds.size.height-64, 44, 44) normalImg:@"photo.png" andPushedImg:@"photo.png" andSelectedImg:@"photo.png"];
    [_photoBtn setEnabled:YES];
    [_photoBtn setTitle:@"" forState:UIControlStateNormal];
    [_photoBtn addTarget:self action:@selector(openPhoto) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_photoBtn];
    
    
    UIView * red=[[UIView alloc]initWithFrame:CGRectMake(0, 0, Screen_Width, 64)];
    [self addSubview:red];
    red.backgroundColor=[UIColor blackColor];
    red.alpha=0.1;
    
    UIView * headBg=[[UIView alloc]initWithFrame:CGRectMake(0, 0, Screen_Width, 88)];
    headBg.backgroundColor=[UIColor clearColor];
    [self addSubview:headBg];
    
    UIButton *  back=[UIButton buttonWithType:UIButtonTypeCustom];
    back.frame=CGRectMake(30, 30, 44, 44);
    [back addTarget:self action:@selector(back:) forControlEvents:UIControlEventTouchUpInside];
    [back setBackgroundImage:[UIImage imageNamed:@"saomaback@2x"] forState:UIControlStateNormal];
    [headBg addSubview:back];
    
    _flash=[UIButton buttonWithType:UIButtonTypeCustom];
    _flash.frame=CGRectMake(Screen_Width-44-30, 30, 44, 44);
    [_flash addTarget:self action:@selector(rightBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [_flash setBackgroundImage:[UIImage imageNamed:@"btn_lamp_off.png"] forState:UIControlStateNormal];
    [headBg addSubview:_flash];
    
    

}
- (void)createSaoyiSaoUI{
    ZBarReaderView *readview = [ZBarReaderView new];
    //自定义大小
    readview.frame = CGRectMake(0, 0, Screen_Width, Screen_Height);
    /*********UI定制*************/
    readview.torchMode=0;
    UIImageView *saoMiaoImage=[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"saomabg@2x.png"]];
    saoMiaoImage.frame=CGRectMake(0, 0, Screen_Width-80, Screen_Height-264);
    saoMiaoImage.center=self.center;
    saoMiaoImage.tag=1002;
    saoMiaoImage.backgroundColor=[UIColor clearColor];
    [readview addSubview:saoMiaoImage];
    self.saoMiaoLine=[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"saomaline.png"]];
    _saoMiaoLine.frame=CGRectMake(saoMiaoImage.frame.origin.x, saoMiaoImage.frame.origin.y+saoMiaoImage.frame.size.height, saoMiaoImage.frame.size.width, 1);
    [readview addSubview:_saoMiaoLine];
    
    UIView *view1=[[UIView alloc]initWithFrame:CGRectMake(0, 64, Screen_Width, saoMiaoImage.frame.origin.y-64)];
    view1.backgroundColor=[UIColor blackColor];
    view1.alpha=0.1;
    [readview addSubview:view1];
    
    UIView *view2=[[UIView alloc]initWithFrame:CGRectMake(0, 64+view1.frame.size.height, saoMiaoImage.frame.origin.x,saoMiaoImage.frame.size.height)];
    view2.backgroundColor=[UIColor blackColor];
    view2.alpha=0.1;
    [readview addSubview:view2];
    
    UIView *view3=[[UIView alloc]initWithFrame:CGRectMake(saoMiaoImage.frame.origin.x+saoMiaoImage.frame.size.width, 64+view1.frame.size.height, saoMiaoImage.frame.origin.x,saoMiaoImage.frame.size.height)];
    view3.backgroundColor=[UIColor blackColor];
    view3.alpha=0.1;
    [readview addSubview:view3];
    
    UILabel *label=[[UILabel alloc]initWithFrame:CGRectMake(0, view3.frame.origin.y+view3.frame.size.height, Screen_Width, Screen_Height-view3.frame.origin.y-view3.frame.size.height-30)];
    label.backgroundColor=[UIColor blackColor];
    label.alpha=0.1;
    label.textColor=[UIColor whiteColor];
    label.text=@"请将手机对准二维码即可自动扫描";
    label.textAlignment=NSTextAlignmentCenter;
    label.font=[UIFont systemFontOfSize:14];
    [readview addSubview:label];
    
    UIView *view4=[[UIView alloc]initWithFrame:CGRectMake(0, label.frame.origin.y+label.frame.size.height,Screen_Width, 30)];
    view4.backgroundColor=[UIColor blackColor];
    view4.alpha=0.1;
    [readview addSubview:view4];
    view1=nil,view2=nil,view3=nil,label=nil,view4=nil;
    [self saomiaolineAnimation];
    /****************************/
    readview.readerDelegate = self;
    //将其照相机拍摄视图添加到要显示的视图上
    [self addSubview:readview];
    //二维码/条形码识别设置
    ZBarImageScanner *scanner = readview.scanner;
    [scanner setSymbology: ZBAR_I25
                   config: ZBAR_CFG_ENABLE
                       to: 0];
    
    // 添加input
    AVCaptureDevice *inputDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    AVCaptureDeviceInput *captureInput = [AVCaptureDeviceInput deviceInputWithDevice:inputDevice error:nil];
    if (captureInput)
    {
        //启动，必须启动后，手机摄影头拍摄的即时图像菜可以显示在readview上
        [readview start];
    }
    else
    {
                
    }
    
}
-(void)saomiaolineAnimation{
    CAAnimationGroup *_animGroup = nil;
    if (!_animGroup)
    {
        _animGroup = [CAAnimationGroup animation];
        
        UIImageView *saoMiaoImage=[self viewWithTag:1002];
        
        CAKeyframeAnimation *positon = [CAKeyframeAnimation animationWithKeyPath:@"position"];
        UIBezierPath *path = [UIBezierPath bezierPath];
        [path moveToPoint:CGPointMake(_saoMiaoLine.frame.origin.x + _saoMiaoLine.frame.size.width/2, _saoMiaoLine.frame.origin.y + _saoMiaoLine.frame.size.height/2)];
        [path addLineToPoint:CGPointMake(_saoMiaoLine.frame.origin.x + _saoMiaoLine.frame.size.width/2, self.center.y-saoMiaoImage.frame.size.height/2)];
        [positon setPath:path.CGPath];
        [positon setDuration:5];
        
        CABasicAnimation *opacity0 = [CABasicAnimation animationWithKeyPath:@"opacity"];
        [opacity0 setFromValue:[NSNumber numberWithFloat:0]];
        [opacity0 setToValue:[NSNumber numberWithFloat:1]];
        [opacity0 setDuration:0.5];
        
        CABasicAnimation *opacity1 = [CABasicAnimation animationWithKeyPath:@"opacity"];
        [opacity1 setFromValue:[NSNumber numberWithFloat:1]];
        [opacity1 setToValue:[NSNumber numberWithFloat:1]];
        [opacity1 setDuration:4];
        opacity1.beginTime = 0.5;
        
        CABasicAnimation *opacity2 = [CABasicAnimation animationWithKeyPath:@"opacity"];
        [opacity2 setFromValue:[NSNumber numberWithFloat:1]];
        [opacity2 setToValue:[NSNumber numberWithFloat:0]];
        [opacity2 setDuration:0.5];
        opacity2.beginTime = 4.5;
        
        [_animGroup setDuration:5];
        [_animGroup setAnimations:[NSArray arrayWithObjects:positon, opacity0, opacity1,opacity2, nil]];
        [_animGroup setRepeatCount:MAXFLOAT];
        [_animGroup setRemovedOnCompletion:YES];
    }
    [_saoMiaoLine.layer addAnimation:_animGroup forKey:@"groupAnim"];

}
-(void)scanPicture:(UIImage*)erweimaImage{
    [self decodeImage:erweimaImage];
}
- (void)openPhoto
{
    CLog(@"调用blcok");
    if(self.scanPLiabary){
        self.scanPLiabary();
    }
    
}
#pragma mark ----------打开或关闭手电筒-----------
-(void)rightBtnClick:(UIButton *)sender{
    
    [self turnTorchOn:_torchIsOn];
    
}

- (void)turnTorchOn:(BOOL)on{
    
    Class captureDeviceClass = NSClassFromString(@"AVCaptureDevice");
    if (captureDeviceClass != nil) {
        AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        if ([device hasTorch] && [device hasFlash]){
            
            [device lockForConfiguration:nil];
            if (on) {
                [_flash setBackgroundImage:[UIImage imageNamed:@"btn_lamp_off.png"] forState:UIControlStateNormal];
                
                [device setTorchMode:AVCaptureTorchModeOff];
                [device setFlashMode:AVCaptureFlashModeOff];
                _torchIsOn = NO;
                
            } else {
                [device setTorchMode:AVCaptureTorchModeOn];
                [device setFlashMode:AVCaptureFlashModeOn];
                [_flash setBackgroundImage:[UIImage imageNamed:@"btn_lamp_on.png"] forState:UIControlStateNormal];
                _torchIsOn = YES;
                
            }
            [device unlockForConfiguration];
        }
    }
}

// 处理扫描到的图
- (void)decodeImage:(UIImage *)image
{
    ZBarReaderController *reader=[ZBarReaderController new];
    CGImageRef cgimage=image.CGImage;
    ZBarSymbol *symbol = nil;
    for (symbol in [reader scanImage:cgimage])
        break;
    NSString *text=symbol.data;
    if (text!=nil) {
        [self.qreaderView stop];
        self.saoMiaoLine.hidden=YES;
        CLog(@"本地扫描结果====:%@",text);
        [self saoCodeResult:text];
    }
}

//扫码之后代理
-(void)readerView:(ZBarReaderView *)readerView didReadSymbols:(ZBarSymbolSet *)symbols fromImage:(UIImage *)image{
    ZBarSymbol *symbol=nil;
    for (symbol in symbols)
        break;
    _codeString=symbol.data;
    CLog(@"扫描出来的URL:%@",_codeString);
    //扫描结束,需要停止运动
    self.qreaderView=readerView;
    
    if ([_codeString isKindOfClass:[NSNull class]]) {
        [self addAlertTitle:@"提示" withMessage:@"系统错误" withConfirmbtn:@"确定" withCancelBtn:nil withAlertTag:400 withDelegate:nil];
        CLog(@"需要调用block处理错误");
        
    }else{
        [self.qreaderView stop];
        self.saoMiaoLine.hidden=YES;
    }
    
    [self saoCodeResult:_codeString];
}
#pragma mark-----扫完码处理
-(void)saoCodeResult:(NSString*)result{
    NSString * codeNum=@"";
    if ([[result componentsSeparatedByString:@"c="] count]>1){
        codeNum=result;
    }
    if ([[result componentsSeparatedByString:@"b="] count]>1){
        codeNum= result;
    }
    
    // 对扫描的码处理
    //1.内容码
    if ([self isSubString:codeNum withContainStr:@"C"]||[self isSubString:codeNum withContainStr:@"G"]) {
        CLog(@"内容码");
        
        if (!self.isLock) {
            [self handleCodeWithNum:codeNum];
            codeNum = nil;
        }
        
    }else{
        // 第三方url
        _out_url = result;
        
        if (!self.isLock) {
            self.isLock = YES;
            if ([self isURL:_out_url])
            {
                
                [self addAlertWithMessage:@"发现一个外部链接，需要打开吗？" WithTag:101 WithDelegate:self WithConfimBtn:@"确定" WithCancleBtn:@"取消"];
            }
            else
            {
                [self addAlertWithMessage:_out_url WithTag:0 WithDelegate:nil WithConfimBtn:@"确定" WithCancleBtn:@"取消"];
                
                
            }
            
        }
    }
}
#pragma mark-----商品二维码
- (NSArray *)checkIsACode:(NSString *)result
{
    NSArray *array = [result componentsSeparatedByString:@"codeNumber="];
    if (array == nil || [array count] == 1)
    {
        array = [result componentsSeparatedByString:@"z="];
    }
    if ([array count] > 1)
    {
        return array;
    }
    else
    {
        array = [result componentsSeparatedByString:@"c="];
        if ([array count] > 1)
        {
            return array;
        }
    }
    
    return nil;
}
#pragma mark --------分割扫描结果--------------
- (NSString *)checkIsACode1:(NSString *)result
{
    self.codeString=result;
//    if ([[result componentsSeparatedByString:@"codeNumber="] count]>1) {
//        return [[result componentsSeparatedByString:@"codeNumber="] lastObject];
//    }else if ([[result componentsSeparatedByString:@"c="] count]>1){
//        return [[result componentsSeparatedByString:@"c="] lastObject];
//    }else if ([[result componentsSeparatedByString:@"m="] count]>1){
//        return [[result componentsSeparatedByString:@"m="] lastObject];
//    }else if ([[result componentsSeparatedByString:@"bookNumber="] count]>1){
//        return [[result componentsSeparatedByString:@"bookNumber="] lastObject];
//    }else if ([[result componentsSeparatedByString:@"b="] count]>1){
//        return [[result componentsSeparatedByString:@"b="] lastObject];
//    }
    return self.codeString;
}
#pragma mark-----内容码
- (void)handleCodeWithNum:(NSString *)codeNum
{
    self.isLock = YES;
    [self handleQRCodeWithCodeNumber:codeNum];
}
- (void)handleQRCodeWithCodeNumber:(NSString *)codeNumber
{
    
    if (self.isShowDetail) {
        return;
    }
    // 显示等待加载界面
//    [self coverALoadingView];
    // 每次获得基本信息时重置
    CLog(@"调用block");
    [self stopScan];
    CLog(@"请求内容码===%@",codeNumber);
    if (self.scanFinish) {
        self.scanFinish(codeNumber);
    }
}
#pragma mark---——--扫码失败的回调
- (void) readerControllerDidFailToRead: (ZBarReaderController*) reader
                             withRetry: (BOOL) retry{
    CLog(@"扫码失败了");
    [self stopScan];
    if (retry==NO) {
        CLog(@"调用blcok");
        if (self.scanFailed) {
            self.scanFailed();
        }
        
    }
}
-(void)back:(UIButton *)sender{
    [self.qreaderView stop];
    self.saoMiaoLine.hidden=YES;
    CLog(@"调用block");
    if (self.goback) {
        self.goback();
    }
}
#pragma mark-----对外block接口
-(void)scanSuccess:(ScanSuccess)scanSuccess{
    self.scanFinish=scanSuccess;
}
-(void)scanFail:(ScanFail)scanFail{
    self.scanFailed=scanFail;
}
-(void)comeBack:(Back)back{
    self.goback=back;
}
-(void)openXiangce:(OpenPhotoLabiry)photo{
    self.scanPLiabary=photo;
    
}
-(void)stopScan{
    self.isLock=NO;
    self.saoMiaoLine.hidden=NO;

}
-(void)startScan{
    self.isLock=NO;
    self.saoMiaoLine.hidden=NO;
    [self saomiaolineAnimation];
    if (self.qreaderView) {
        [self.qreaderView start];
    }

}


- (void)addAlertTitle:(NSString*)title withMessage:(NSString*)message withConfirmbtn:(NSString*)confirmBtn withCancelBtn:(NSString*)cancaleBtn withAlertTag:(NSInteger)alertTag withDelegate:(id)del{
    
    UIAlertView * alert =[[UIAlertView alloc]initWithTitle:title message:message delegate:del cancelButtonTitle:cancaleBtn otherButtonTitles:confirmBtn, nil];
    alert.tag=alertTag;
    [alert show];
}

-(BOOL)isSubString:(NSString*)string withContainStr:(NSString*)str{
    BOOL isSub=NO;
    NSRange range = [string rangeOfString:str];
    if (range.length>0) {
        isSub=YES;
    }
    return isSub;
}

//URL正则判断
-(BOOL)isURL:(NSString *)url_str
{
    NSString *url_pre = @"(http|ftp|https):\\/\\/[\\w\\-_]+(\\.[\\w\\-_]+)+([\\w\\-\\.,@?^=%&amp;:/~\\+#]*[\\w\\-\\@?^=%&amp;/~\\+#])?";
    NSPredicate *regex = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", url_pre];
    return [regex evaluateWithObject:url_str];
}

-(void)addAlertWithMessage:(NSString*)message WithTag:(NSInteger)tag WithDelegate:(id)delegate WithConfimBtn:(NSString*)confimBtn WithCancleBtn:(NSString*)cancleBtn{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示"
                                                    message:message
                                                   delegate:delegate
                                          cancelButtonTitle:cancleBtn
                                          otherButtonTitles:confimBtn, nil];
    alert.tag = tag;
    [alert show];
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView.tag==101) {
        if (buttonIndex==1) {
            [[UIApplication sharedApplication]openURL:[NSURL URLWithString:_out_url]];
            [self performSelector:@selector(setScan) withObject:self afterDelay:1];
        }if (buttonIndex==0) {
            
        }
    }
}
-(void)setScan{
    [self startScan];
}
@end
