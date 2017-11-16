//
//  CFCallingView.m
//  CFHookInterface
//
//  Created by gyanping on 13-9-29.
//
//

#import "CFCallingView.h"
#import "TelephonyUtil.h"
#import "CFDaemonManger.h"
//#define CF_DYLIB_CFRES_PATH @"/usr/local/cfres/"

@interface CFCallingView ()
-(IBAction)endCallClick:(id)sender;
//-(void)addViewToCallView;
@end

static CTCall * callers = nil;
@implementation CFCallingView

@synthesize nameLable,numLable,cenCallBtton;
@synthesize myCtCall;

static void TelephonycallBack(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo)
{
    if ([(NSString *)name isEqualToString:@"kCTCallStatusChangeNotification"])
    {
        CTCall *call = (CTCall *)[(NSDictionary *)userInfo objectForKey:@"kCTCall"];

        [[CFCallingView shareInstance] callManger:call];
    }

}

-(void)callManger:(CTCall *)call
{
    callers = call;
}

+(CFCallingView *)shareInstance
{
    static CFCallingView *_singletion;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _singletion = [[CFCallingView alloc] initWithFrame:CGRectMake(0, 20, 320, 460)];
    });
    
    return _singletion;
}


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        CTTelephonyCenterAddObserver(CTTelephonyCenterGetDefault(), NULL, &TelephonycallBack, CFSTR("kCTCallStatusChangeNotification"), NULL, CFNotificationSuspensionBehaviorHold);

        self.backgroundColor = [UIColor underPageBackgroundColor];
        
        
        UIImageView *lcd_bottom = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 382.0, 320.0, 96.0)];
        lcd_bottom.image = [UIImage imageWithContentsOfFile:@"/usr/local/cfres/lcd_bottom.png"];
        
        UIButton *endCallBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        endCallBtn.frame =  CGRectMake(20.0, 404.0 - 10, 281.0, 51.0);
        [endCallBtn setBackgroundImage:[UIImage imageWithContentsOfFile:@"/usr/local/cfres/Calling_TerminateLong_Normal.png"] forState:UIControlStateNormal];
//        endCallBtn.showsTouchWhenHighlighted = YES;
        [endCallBtn addTarget:self action:@selector(endCallClick:) forControlEvents:UIControlEventTouchUpInside];
        self.cenCallBtton = endCallBtn;
        [endCallBtn release];
        
        
        UIImageView *top_bottom = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 96.0)];
        top_bottom.image = [UIImage imageWithContentsOfFile:@"/usr/local/cfres/lcd_top.png"];
        
        UIImageView *cen_view = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 157.0, 320.0, 182.0)];
        cen_view.image = [UIImage imageWithContentsOfFile:@"/usr/local/cfres/ad5.png"];
        
        UILabel *nameLab = [[UILabel alloc] initWithFrame:CGRectMake(13.0, 7.0, 287.0, 35.0)];
        nameLab.backgroundColor=[UIColor clearColor];
        nameLab.font = [UIFont boldSystemFontOfSize:20];
        nameLab.textColor = [UIColor whiteColor];
        nameLab.textAlignment = UITextAlignmentCenter;
        nameLab.adjustsFontSizeToFitWidth = YES;
//        nameLab.text = @"郭燕平";
        self.nameLable = nameLab;
        [nameLab release];
        
        UILabel *numLab = [[UILabel alloc] initWithFrame:CGRectMake(13.0, 55.0, 287.0, 35.0)];
        numLab.backgroundColor=[UIColor clearColor];
        numLab.font = [UIFont boldSystemFontOfSize:20];
        numLab.textColor = [UIColor whiteColor];
        numLab.textAlignment = UITextAlignmentCenter;
        numLab.adjustsFontSizeToFitWidth = YES;
//        numLab.text = @"1000878888";
        self.numLable = numLab;
        [numLab release];
        
        [self addSubview:lcd_bottom];
        [self addSubview:top_bottom];
        [self addSubview:cen_view];
        [self addSubview:endCallBtn];
        [self addSubview:self.nameLable];
        [self addSubview:self.numLable];
        
        [lcd_bottom release];
        [top_bottom release];
        [cen_view release];
//        [endCallBtn release];
        
    }
    return self;
}
- (void)showWithNumber:(NSString *)number username:(NSString*)name
{
    if ([name length])
    {
        self.nameLable.text = name;
        self.numLable.text = number;
    }
    else
        self.nameLable.text = number;
  
}

-(void)showCallingView:(BOOL)isShow
{
    if (isShow)
    {
        
        [[UIApplication sharedApplication].keyWindow addSubview:self];
    }
    else
    {
      
        [self removeFromSuperview];
    }
}

-(IBAction)endCallClick:(id)sender
{
//    [[CFDaemonManger shareInstance] sendMsgToDaemon:0x67 msg:nil msgLen:0];
//    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"呼出号码"
//                          
//                                                    message:CTCallCopyAddress(NULL, callers)
//                          
//                                                   delegate:nil
//                          
//                                          cancelButtonTitle:@"Thanks"
//                          
//                                          otherButtonTitles:nil];
//    
//    [alert show];
//    
//    [alert release];
    if (callers)
        CTCallDisconnect(callers);
//    sleep(2);
//    [CFDaemonManger setHookCallOut:NO];
    [self showCallingView:NO];
}

-(void)dealloc
{
    [nameLable release];
    [numLable release];
    [cenCallBtton release];
    [super dealloc];
}

//-(void)addViewToCallView
//{
//    UIImageView *imgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:(NSString *)]];
//    UIView *titleView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 20, 320, 40)];
//    [titleView set]
//}

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect
 {
 // Drawing code
 }
 */

@end
