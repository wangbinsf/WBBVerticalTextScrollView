//
//  WBBVerticalScrollView.m
//  WBBVerticalScroll
//
//  Created by 王宾宾 on 16/8/12.
//  Copyright © 2016年 王宾宾. All rights reserved.
//
#define VIEW_WIDTH self.frame.size.width
#define VIEW_HEIGHT self.frame.size.height

#import "WBBVerticalTextScrollView.h"

@interface WBBVerticalTextScrollView()<UIScrollViewDelegate>

@property (nonatomic, assign) NSInteger itemCount;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UILabel *topLabel;
@property (nonatomic, strong) UILabel *centerLabel;
@property (nonatomic, strong) UILabel *bottomLabel;
@property (nonatomic, strong) UIButton *cover;
@property (nonatomic, strong) NSTimer *timer;
//当前显示在items的下标
@property (nonatomic, assign) NSInteger currentPageIndex;

@end

@implementation WBBVerticalTextScrollView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initialRootView];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self initialRootView];
}

- (void)initialRootView {
    UIScrollView *scrollView = [[UIScrollView alloc]init];
    self.scrollView = scrollView;
    scrollView.pagingEnabled = YES;
    scrollView.showsVerticalScrollIndicator = NO;
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.delegate = self;
    scrollView.bounces = NO;
    [self addSubview:scrollView];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.autoresizingMask = UIViewAutoresizingNone;
    self.scrollView.frame = self.bounds;
    self.topLabel.frame = CGRectMake(0, 0, VIEW_WIDTH, VIEW_HEIGHT);
    self.centerLabel.frame = CGRectMake(0, VIEW_HEIGHT, VIEW_WIDTH, VIEW_HEIGHT);
    self.bottomLabel.frame = CGRectMake(0, 2 * VIEW_HEIGHT, VIEW_WIDTH, VIEW_HEIGHT);
    self.cover.frame = self.bounds;
    [self beginTimer];
}

#pragma mark
#pragma mark - lazy

- (UILabel *)topLabel {
    if (!_topLabel) {
        _topLabel = [[UILabel alloc]init];
        _topLabel.textAlignment = NSTextAlignmentCenter;
        [self.scrollView addSubview:_topLabel];
    }
    return _topLabel;
}

- (UILabel *)centerLabel {
    if (!_centerLabel) {
        _centerLabel = [[UILabel alloc]init];
        _centerLabel.userInteractionEnabled = YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapLabel)];
        [_centerLabel addGestureRecognizer:tap];
        _centerLabel.textAlignment = NSTextAlignmentCenter;
        [self.scrollView addSubview:_centerLabel];
    }
    return _centerLabel;
}

- (UILabel *)bottomLabel {
    if (!_bottomLabel) {
        _bottomLabel = [[UILabel alloc]init];
        _bottomLabel.textAlignment = NSTextAlignmentCenter;
        [self.scrollView addSubview:_bottomLabel];
    }
    return _bottomLabel;
}

#pragma mark
#pragma mark - setting

- (void)setItems:(NSArray *)items {
    _items = items;
    self.itemCount = items.count;
    self.scrollView.contentSize = CGSizeMake(0, 3 * VIEW_HEIGHT);
    [self.scrollView setContentOffset:CGPointMake(0, VIEW_HEIGHT) animated:NO];
    self.centerLabel.text = self.items.firstObject;
    self.topLabel.text = self.items.lastObject;
    self.bottomLabel.text = self.items[1];
}

- (void)setTextFont:(UIFont *)textFont {
    _textFont = textFont;
    self.topLabel.font = textFont;
    self.centerLabel.font = textFont;
    self.bottomLabel.font = textFont;
}

- (void)setTextColor:(UIColor *)textColor {
    _textColor = textColor;
    self.topLabel.textColor = textColor;
    self.centerLabel.textColor = textColor;
    self.bottomLabel.textColor = textColor;
}

- (void)setTextAlign:(NSTextAlignment)textAlign {
    _textAlign = textAlign;
    self.topLabel.textAlignment = textAlign;
    self.centerLabel.textAlignment = textAlign;
    self.bottomLabel.textAlignment = textAlign;
}

- (void)setUserInteraction:(BOOL)userInteraction {
    _userInteraction = userInteraction;
    if (!_userInteraction) {
        self.centerLabel.userInteractionEnabled = NO;
        UIButton *cover = [UIButton buttonWithType:UIButtonTypeCustom];
        [cover addTarget:self action:@selector(coverClick) forControlEvents:UIControlEventTouchUpInside];
        self.cover = cover;
        cover.backgroundColor = [UIColor clearColor];
        [self insertSubview:cover aboveSubview:self.scrollView];
    }
}

#pragma mark
#pragma mark - publick

- (void)tapLabel {
    if ([self.delegate respondsToSelector:@selector(verticalTextScrollView:didSelectIndex:)]) {
        [self.delegate verticalTextScrollView:self didSelectIndex:self.currentPageIndex];
    }
}

- (void)coverClick {
    if ([self.delegate respondsToSelector:@selector(verticalTextScrollView:didSelectIndex:)]) {
        [self.delegate verticalTextScrollView:self didSelectIndex:self.currentPageIndex];
    }
}

#pragma mark
#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{

}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self endTimer];
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
    CGPoint offset = [self nearestTargetOffsetForOffset:*targetContentOffset];
    targetContentOffset->x = offset.x;
    targetContentOffset->y = offset.y;
}

- (CGPoint)nearestTargetOffsetForOffset:(CGPoint)offset {
    CGPoint point;
    NSInteger page = roundf(offset.x / VIEW_WIDTH);
    CGFloat targetX = VIEW_WIDTH * page;
    point = CGPointMake(targetX, offset.y);
    return point;
}

/**
 *  decelerate:是否即将减速
 *  如果减速，则会调用scrollViewWillBeginDecelerating\scrollViewDidEndDecelerating
 *  如果没有减速，则不会调用scrollViewWillBeginDecelerating\scrollViewDidEndDecelerating
 */
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    [self beginTimer];
    if (!decelerate) {
        //重新加载数据
        [self reloadData];
    }
}

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView {
    //开始减速是调用
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    //减速结束调用
    //重新加载数据
    [self reloadData];
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    //如有减速，减速结束调用此方法
    [self reloadData];
}

#pragma mark 重新加载图片
-(void)reloadData{
    NSInteger topLabelIndex,bottomLabelIndex;
    CGPoint offset = [self.scrollView contentOffset];
    if (offset.y > VIEW_HEIGHT) { //向下滑动
        self.currentPageIndex = (self.currentPageIndex + 1) % self.itemCount;
    }else if(offset.y
             < VIEW_HEIGHT){ //向上滑动
        self.currentPageIndex = (self.currentPageIndex + self.itemCount-1) % self.itemCount;
    }
    self.centerLabel.text = self.items[self.currentPageIndex];
    
    //重新设置左右图片
    topLabelIndex = (self.currentPageIndex+self.itemCount-1)%self.itemCount;
    bottomLabelIndex = (self.currentPageIndex+1)%self.itemCount;
    self.topLabel.text = self.items[topLabelIndex];
    self.bottomLabel.text = self.items[bottomLabelIndex];
    [self.scrollView setContentOffset:CGPointMake(0, VIEW_HEIGHT) animated:NO];
}

#pragma mark
#pragma mark Timer

- (void)beginTimer {
    if (self.timer) [self endTimer];
    self.timer = [NSTimer timerWithTimeInterval:2.0 target:self selector:@selector(autoScroll) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop]addTimer:self.timer forMode:NSRunLoopCommonModes];
}

- (void)endTimer {
    [self.timer invalidate];
    self.timer = nil;
}

- (void)autoScroll {
    [self.scrollView setContentOffset:CGPointMake(0, 2*VIEW_HEIGHT) animated:YES];
}

#pragma mark other

- (void)dealloc {
    [self.timer invalidate];
    self.timer = nil;
}

@end
