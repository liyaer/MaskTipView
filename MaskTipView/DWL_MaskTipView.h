//
//  DWL_MaskTipView.h
//  MobileTYCJ
//
//  Created by Mac on 2018/11/28.
//

#import <UIKit/UIKit.h>


//用户可指定聚焦显示的图形类型
typedef NS_ENUM(NSInteger, DFocusShape)
{
    dRectShape,//方形
    dCircleShape,//圆形
    dStarShape,//五角星形
    dOtherShape,//圆角矩形
};


@interface DWL_MaskTipView : UIView
/*
    frame：期望的self.frame
    focusFrames：待聚焦显示的frame数组（注意frame值应该和self处于相同或者等价的坐标系统中）
    focusShapes：待聚焦显示的shape数组（数据类型是DFocusShape）
 */
+(instancetype)showWithFrame:(CGRect)frame focusFrames:(NSArray <NSValue *>*)focusFrames focusShapes:(NSArray <NSNumber *>*)focusShapes;

@end

