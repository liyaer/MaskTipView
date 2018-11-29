//
//  DWL_MaskTipView.m
//  MobileTYCJ
//
//  Created by Mac on 2018/11/28.
//

#import "DWL_MaskTipView.h"


#define BgAlpha 0.7//蒙版透明度
#define transScale 1.2//放大动画的倍数
#define animationTime 0.45//动画时间
#define addLength 10//拓宽的长度


@interface DWL_MaskTipView ()

@property (nonatomic,strong) NSMutableArray *paths_m;
@property (nonatomic,strong) CAShapeLayer *maskLayer;
@property (nonatomic,assign) NSInteger index;
@property (nonatomic,strong) UIButton *nextStepBtn;

@end


@implementation DWL_MaskTipView

#pragma mark - 懒加载

-(NSMutableArray *)paths_m
{
    if (!_paths_m)
    {
        _paths_m = [NSMutableArray arrayWithCapacity:3];
    }
    return _paths_m;
}

-(CAShapeLayer *)maskLayer
{
    if (!_maskLayer)
    {
        _maskLayer = [CAShapeLayer layer];
        _maskLayer.fillColor = [UIColor redColor].CGColor;//随便什么，只要不是clearColor即可
        _maskLayer.fillRule = kCAFillRuleEvenOdd;//奇偶填充（奇填偶不填）
    }
    return _maskLayer;
}

-(UIButton *)nextStepBtn
{
    if (!_nextStepBtn)
    {
        _nextStepBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_nextStepBtn setFrame:CGRectMake(0, 0, 411/2, 139/2)];
        _nextStepBtn.center = self.center;
        [_nextStepBtn setImage:[UIImage imageNamed:@"4.jpg"] forState:UIControlStateNormal];
        [_nextStepBtn addTarget:self action:@selector(nextStepAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _nextStepBtn;
}




#pragma mark - 指定初始化方法

+(instancetype)showWithFrame:(CGRect)frame focusFrames:(NSArray <NSValue *>*)focusFrames focusShapes:(NSArray <NSNumber *>*)focusShapes
{
    if (focusFrames.count == focusShapes.count && focusFrames.count != 0)
    {
        return [[self alloc] initWithFrame:frame focusFrames:focusFrames focusShapes:focusShapes];
    }
    else
    {
        @throw [NSException exceptionWithName:@"DWL_Error" reason:@"数量不一致或者数量为0！" userInfo:nil];
    }
}

-(instancetype)initWithFrame:(CGRect)frame focusFrames:(NSArray <NSValue *>*)focusFrames focusShapes:(NSArray <NSNumber *>*)focusShapes
{
    if (self = [super initWithFrame:frame])
    {
        //绘制path，暂存到数组中
        [self getAllPathsWithFocusFrames:focusFrames focusShapes:focusShapes];
        
        //添加子视图
        self.backgroundColor = [UIColor colorWithWhite:0 alpha:BgAlpha];
        [self addSubview:self.nextStepBtn];
        
        //设置mask，默认取第一个path
        self.maskLayer.path = [(UIBezierPath *)self.paths_m.firstObject CGPath];
        self.layer.mask = self.maskLayer;

        //添加至window，并执行动画
        [[UIApplication sharedApplication].keyWindow addSubview:self];
        CGAffineTransform transform = CGAffineTransformIdentity;
        self.transform = CGAffineTransformMakeScale(transScale, transScale);
        [UIView animateWithDuration:animationTime animations:^
         {
             self.transform = transform;
         }
        completion:^(BOOL finished)
         {
             
         }];
    }
    return self;
}




#pragma mark - 点击事件

-(void)nextStepAction
{
    self.index++;
    
    [UIView animateWithDuration:animationTime animations:^
    {
        if (self.index && self.index < self.paths_m.count)
        {
            //进行下面的path动画
        }
        else
        {
            self.transform = CGAffineTransformMakeScale(transScale, transScale);
            self.alpha = 0;
        }
    }
    completion:^(BOOL finished)
    {
        if (self.index && self.index < self.paths_m.count)
        {
            CABasicAnimation *animate = [CABasicAnimation animationWithKeyPath:@"path"];
            animate.duration = animationTime;
            //结构体类型转接为id类型
            animate.fromValue = (__bridge id _Nullable)(self.maskLayer.path);
            animate.toValue = (__bridge id _Nullable)([(UIBezierPath *)self.paths_m[self.index] CGPath]);
            animate.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
            [self.maskLayer addAnimation:animate forKey:@"PathForMaskLayer"];
            
            //layer动画并不改变layer的实际位置，这里手动更改
            self.maskLayer.path = [(UIBezierPath *)self.paths_m[self.index] CGPath];
        }
        else
        {
            [self removeFromSuperview];
        }
    }];
}




#pragma mark - 封装方法调用集合

//绘制path，暂存到数组中
-(void)getAllPathsWithFocusFrames:(NSArray *)focusFrames focusShapes:(NSArray *)focusShapes
{
    UIBezierPath *startPath;
    UIBezierPath *endPath = [UIBezierPath bezierPathWithRect:self.bounds];
    for (int i = 0; i < focusShapes.count; i++)
    {
        CGRect tipframe = [(NSValue *)focusFrames[i] CGRectValue];
        DFocusShape shape = [(NSNumber *)focusShapes[i] integerValue];
        switch (shape)
        {
            case dRectShape:
            {
#warning 因为构造startPath的方法、形状不同，所以动画转换时可能有的不是那么自然美观（纠结好久，但是没有办法。如果形状比较简单，可以在各个case中使用下面default中的方法来构造，效果会自然些），使用时可以自己检查下
                startPath = [UIBezierPath bezierPathWithRect:CGRectInset(tipframe, -addLength, -addLength)];
            }
                break;
                
            case dCircleShape:
            {
                startPath = [UIBezierPath bezierPathWithOvalInRect:CGRectInset(tipframe, -addLength, -addLength)];
            }
                break;
                
            case dStarShape:
            {
                startPath = [self bezierPathWithStarInRect:CGRectInset(tipframe, -addLength, -addLength)];
            }
                break;
                
            default:
            {
                startPath = [UIBezierPath bezierPathWithRoundedRect:CGRectInset(tipframe, -addLength, -addLength) cornerRadius:5];
            }
                break;
        }
#warning 一定是self.view.bounds构成的path append 聚焦frame构成的path（若反过来，会导致动画效果不正常，因为这个被坑了好久，有时间探究本质）
        [endPath appendPath:startPath];
        [self.paths_m addObject:endPath];
        //恢复默认设置
        endPath = [UIBezierPath bezierPathWithRect:self.bounds];
    }
}

//根据frame获得偏移坐标
CG_INLINE CGPoint CGPointGetShiftPoint(CGRect frame)
{
    CGPoint p;
    p.x = frame.origin.x + (MAX(CGRectGetWidth(frame), CGRectGetHeight(frame)) - (CGRectGetHeight(frame)))/2;
    p.y = frame.origin.y + ( (MAX(CGRectGetWidth(frame), CGRectGetHeight(frame)) - CGRectGetWidth(frame)))/2;
    return p;
}

//根据缩放系数和偏移坐标进行变化
CG_INLINE CGPoint CGPointMakeScaleAndShift(CGPoint originPoint, CGFloat scale, CGPoint shiftPoint)
{
    CGPoint p;
    p.x = originPoint.x * scale + shiftPoint.x;
    p.y = originPoint.y * scale + shiftPoint.y;
    return p;
}

//得到⭐️曲线
-(UIBezierPath *)bezierPathWithStarInRect:(CGRect)frame
{
    CGFloat edgeLength = MIN(CGRectGetWidth(frame), CGRectGetHeight(frame));
    CGFloat scale = edgeLength/100;
    CGPoint shiftPoint = CGPointGetShiftPoint(frame);
    UIBezierPath *starPath = [UIBezierPath bezierPath];
    [starPath moveToPoint: CGPointMakeScaleAndShift(CGPointMake(50, 0),scale,shiftPoint)];
    [starPath addLineToPoint: CGPointMakeScaleAndShift(CGPointMake(67.64, 25.72),scale,shiftPoint)];
    [starPath addLineToPoint: CGPointMakeScaleAndShift(CGPointMake(97.55, 34.55),scale,shiftPoint)];
    [starPath addLineToPoint: CGPointMakeScaleAndShift(CGPointMake(78.54, 59.27),scale,shiftPoint)];
    [starPath addLineToPoint: CGPointMakeScaleAndShift(CGPointMake(79.39, 90.45),scale,shiftPoint)];
    [starPath addLineToPoint: CGPointMakeScaleAndShift(CGPointMake(50, 80.01),scale,shiftPoint)];
    [starPath addLineToPoint: CGPointMakeScaleAndShift(CGPointMake(20.61, 90.45),scale,shiftPoint)];
    [starPath addLineToPoint: CGPointMakeScaleAndShift(CGPointMake(21.46, 59.27),scale,shiftPoint)];
    [starPath addLineToPoint: CGPointMakeScaleAndShift(CGPointMake(2.45, 34.55),scale,shiftPoint)];
    [starPath addLineToPoint: CGPointMakeScaleAndShift(CGPointMake(32.36, 25.72),scale,shiftPoint)];
    [starPath closePath];
    return starPath;
}

@end
