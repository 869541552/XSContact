//
//  CFCallingView.h
//  CFHookInterface
//
//  Created by gyanping on 13-9-29.
//
//

#import <UIKit/UIKit.h>
#define CF_DYLIB_CFRES_PATH  @"/usr/local/cfres/"

@class CTCall;
@interface CFCallingView : UIView
{
    CTCall *myCtCall;
}


@property (nonatomic,retain) UILabel *nameLable;
@property (nonatomic,retain) UILabel *numLable;
@property (nonatomic,retain) UIButton *cenCallBtton;
@property (nonatomic,retain) CTCall *myCtCall;
+(CFCallingView *)shareInstance;
-(void)showCallingView:(BOOL)isShow;
-(void)callManger:(CTCall *)call;
- (void)showWithNumber:(NSString *)number username:(NSString*)name;
@end
