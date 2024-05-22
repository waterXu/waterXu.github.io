//
//  ViewController.m
//  textAnimationDemo
//
//  Created by xxx on 2017/12/6.
//  Copyright © 2017年 xxx. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
@property(nonatomic,strong)CAShapeLayer *layer;
@property(nonatomic,strong)UITextView *maskTextview;
@end

static NSString *const testString = @"Just test a a  a a a 测试录音播放 hhhhh ，和我在成都的街头走一走 呜喔呜喔~~直到所有的灯都熄灭了也不停留";

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //需要做高亮的rextview
    UITextView *textView = [UITextView new];
    textView.text = testString;
    textView.font = [UIFont systemFontOfSize:20];
    textView.textColor = [UIColor blackColor];
    textView.frame = CGRectMake(20, 60, 100, 430);
    [self.view addSubview:textView];
   
    //额外添加一个用来做高亮的textview
    _maskTextview = [UITextView new];
    _maskTextview.text = testString;
    _maskTextview.textColor = [UIColor redColor];//你要高亮的颜色
    _maskTextview.font = [UIFont systemFontOfSize:20];
    _maskTextview.frame = textView.frame;
    
    [self.view addSubview:_maskTextview];
    
    _layer = [CAShapeLayer layer];
    _layer.frame = _maskTextview.bounds;
    _layer.fillColor = [UIColor blackColor].CGColor;//本来textview的颜色
    [_maskTextview.layer setMask:_layer];
    
    UIButton *testButton = [UIButton new];
    [testButton setFrame:CGRectMake(250, 200, 60, 40)];
    [testButton setTitle:@"测试" forState:UIControlStateNormal];
    [testButton setTitleColor:UIColor.redColor forState:UIControlStateNormal];
    [testButton addTarget:self action:@selector(buttonClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:testButton];
}
- (void)buttonClick {
    int array[4] = {0,10,23,35};
    int index = arc4random()%4;
    int start = array[index];
    int end;
    if(index == 3){
        end = (testString.length-1);
    }else{
        end = array[index + 1];
    }
    NSLog(@"start : %d, end : %d",start,end);
    NSRange range = NSMakeRange(start, end - start);
    //test range
    //NSRange range = NSMakeRange(30, 31);
    _maskTextview.selectedRange = range;
    UITextRange *textRange = _maskTextview.selectedTextRange;
 //    NSString *maskText = [testString substringWithRange:range];
    //系统默认的高亮样式
//    [_maskTextview setMarkedText:maskText selectedRange:NSMakeRange(start, end - start)];
    
    for (CAShapeLayer *layer in [_layer.sublayers copy]) {
        [layer removeAllAnimations];
        [layer removeFromSuperlayer];
    }
    //_layer.sublayers = nil;
    NSArray *arrays =  [_maskTextview selectionRectsForRange:textRange];
    CGFloat lineHeight = _maskTextview.font.lineHeight;
    for (UITextSelectionRect *rect in arrays) {
        //选中的rect 项可能包含多行，每一行做动效的可以通过containsStart 和 containsEnd 的height定位每行的位置
        NSLog(@"rectX is :%f",rect.rect.origin.x);
        NSLog(@"rectY is :%f",rect.rect.origin.y);
        NSLog(@"rectW is :%f",rect.rect.size.width);
        NSLog(@"rectH is :%f",rect.rect.size.height);
        
        NSLog(@"rect.containsStart is :%hhd",rect.containsStart);
        NSLog(@"rect.containsEnd is :%hhd",rect.containsEnd);
        NSLog(@"rect.isVertical is :%hhd",rect.isVertical);
        //NSLog(@"rect.writingDirection is :%d",rect.writingDirection);
        if(rect.containsEnd || rect.containsStart) {
            continue;
        }
        int line = rect.rect.size.height / lineHeight;
        for (int i = 0; i < line; i++)
        {
            CGFloat y = rect.rect.origin.y + (rect.rect.size.height/line) * i;
            CGRect layerRect = CGRectMake(rect.rect.origin.x, y, rect.rect.size.width, rect.rect.size.height/line);
            [self addSelectedLayerWithRect:layerRect];
        }
    }
}

- (void)addSelectedLayerWithRect:(CGRect)rect
{
    //添加一个上下的高亮的layer
    //如果是左右的动效的则需要把初始位置和最后的位置取出进行排序后再添加
    CAShapeLayer *layer = [CAShapeLayer layer];
    layer.frame = _maskTextview.bounds;
    layer.fillColor = [UIColor blackColor].CGColor;
    [_layer addSublayer:layer];
    
    UIBezierPath *fromPath = [UIBezierPath bezierPathWithRect:CGRectMake(rect.origin.x, rect.origin.y, rect.size.width, 0)];
    UIBezierPath *toPath = [UIBezierPath bezierPathWithRect:rect];
    CABasicAnimation *basicAnimation = [CABasicAnimation animationWithKeyPath:@"path"];
    basicAnimation.duration = 5;
    basicAnimation.repeatCount = 1;
    basicAnimation.fromValue = (__bridge id)fromPath.CGPath;
    basicAnimation.toValue = (__bridge id)toPath.CGPath;
    [layer addAnimation:basicAnimation forKey:@"path"];
    layer.path = toPath.CGPath;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
