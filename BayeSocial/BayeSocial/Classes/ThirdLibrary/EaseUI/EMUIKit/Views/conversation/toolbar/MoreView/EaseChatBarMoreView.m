/************************************************************
 *  * Hyphenate CONFIDENTIAL
 * __________________
 * Copyright (C) 2016 Hyphenate Inc. All rights reserved.
 *
 * NOTICE: All information contained herein is, and remains
 * the property of Hyphenate Inc.
 * Dissemination of this information or reproduction of this material
 * is strictly forbidden unless prior written permission is obtained
 * from Hyphenate Inc.
 */

#import "EaseChatBarMoreView.h"
#import "BayeSocial-Swift.h"

#define CHAT_BUTTON_SIZE 50
#define INSETS 10
#define MOREVIEW_COL 4
#define MOREVIEW_ROW 2
#define MOREVIEW_BUTTON_TAG 1000

@implementation UIView (MoreView)

- (void)removeAllSubview
{
    for (UIView *view in self.subviews) {
        [view removeFromSuperview];
    }
}

@end

@interface EaseChatBarMoreView ()<UIScrollViewDelegate>
{
    EMChatToolbarType _type;
    NSInteger _maxIndex;
}

@property (nonatomic, strong) UIScrollView *scrollview;
@property (nonatomic, strong) UIPageControl *pageControl;

@property (nonatomic, strong) UIButton *photoButton;
@property (nonatomic, strong) UIButton *takePicButton;
@property (nonatomic, strong) UIButton *locationButton;
@property (nonatomic, strong) UIButton *videoButton;
@property (nonatomic, strong) UIButton *audioCallButton;
@property (nonatomic, strong) UIButton *videoCallButton;
@property (nonatomic,strong) NSMutableArray <NSDictionary *>*buttonItems;
@property (nonatomic,assign,getter=isChatGruop) BOOL chatGroup;
@end

@implementation EaseChatBarMoreView

- (NSMutableArray<NSDictionary *> *)buttonItems {
    if (!_buttonItems) {
        _buttonItems = [NSMutableArray array];
    }
    return _buttonItems;
}
+ (void)initialize
{
    // UIAppearance Proxy Defaults
    EaseChatBarMoreView *moreView = [self appearance];
    moreView.moreViewBackgroundColor = [UIColor whiteColor];
}

- (instancetype)initWithFrame:(CGRect)frame type:(EMChatToolbarType)type
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _type = type;
        [self setupSubviewsForType:_type];
    }
    return self;
}

- (void)setupSubviewsForType:(EMChatToolbarType)type
{
    //self.backgroundColor = [UIColor clearColor];
    
    self.chatGroup                              = type == EMChatToolbarTypeGroup;
    _scrollview                                 = [[UIScrollView alloc] init];
    _scrollview.pagingEnabled                   = YES;
    _scrollview.showsHorizontalScrollIndicator  = NO;
    _scrollview.showsVerticalScrollIndicator    = NO;
    _scrollview.delegate = self;
    [self addSubview:_scrollview];
    
    _pageControl                                = [[UIPageControl alloc] init];
    _pageControl.currentPage                    = 0;
    _pageControl.numberOfPages                  = 1;
    [self addSubview:_pageControl];
    
    [self.buttonItems addObject:@{
                                  @"icon" : @"chatbar_camera",
                                  @"title" : @"拍摄",
                                  @"type" : @"0"
                                  }];
    
    [self.buttonItems addObject:@{
                                  @"icon" : @"chatbar_image",
                                  @"title" : @"照片",
                                  @"type" : @"1"
                                  }];
  
//    [self.buttonItems addObject:@{
//                                  @"icon" : @"chat_bar_movie",
//                                  @"title" : @"小视频",
//                                  @"type" : @"2"
//                                  }];
//    
//    if (!self.isChatGruop)       {
//        [self.buttonItems addObject:@{
//                                      @"icon" : @"chat_bar_ video",
//                                      @"title" : @"视频聊天",
//                                      @"type" : @"3"
//                                      }];
//    }
//    
  
    if ([BKGlobalOptions curret].red_packet_show) {
        
        [self.buttonItems addObject:@{
                                      @"icon" : @"chatbar_redPacket",
                                      @"title" : @"红包",
                                      @"type" : @"4"
                                      }];
    }
    
////
//    [self.buttonItems addObject:@{
//                                  @"icon" : @"chatbar_businessCard",
//                                  @"title" : @"名片",
//                                  @"type" : @"5"
//                                  }];
//
    if ([BKGlobalOptions curret].wechatStoreIsVisible) {
        [self.buttonItems addObject:@{
                                        @"icon" :@"landloacstore",
                                        @"title" : @"去商城",
                                        @"type" : @"6"
                                      }];
    }
    
    __block CGFloat buttonWidth       = ([UIScreen mainScreen].bounds.size.width -115.0f) / 4.0f;
    __block CGFloat buttonHeight      = buttonWidth;
    __block CGFloat margin            = 23.0f;
    __block UILabel *lastLabel        = nil;
    __weak typeof(self) weakself = self;
    [self.buttonItems enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull dictionary, NSUInteger idx, BOOL * _Nonnull stop) {
        
        NSDictionary *params                = [self.buttonItems objectAtIndex:idx];
        
        __strong typeof(weakself)strongself = weakself;
        UIButton *button                    = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setImage:[UIImage imageNamed:dictionary[@"icon"]] forState:UIControlStateNormal];
        button.tag                          = [params[@"type"] integerValue];
        [button addTarget:strongself action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
        NSInteger row                       = idx / 4;
        NSInteger col                       = idx % 4;
        CGFloat buttonX                     = margin + col *(margin + buttonWidth);
        CGFloat buttonY                     = 10.0f + row *(buttonHeight + margin);
        [button setFrame:CGRectMake(buttonX, buttonY , buttonWidth, buttonHeight)];
        [strongself.scrollview addSubview:button];
        
        UILabel *textLabel                  = [[UILabel alloc] init];
        textLabel.textColor                 = [UIColor RGBColor:149.0f green:149.0f blue:149.0f];
        textLabel.font                      = [UIFont systemFontOfSize:13.0f];
        textLabel.textAlignment             = NSTextAlignmentCenter;
        textLabel.frame                     = CGRectMake(buttonX, CGRectGetMaxY(button.frame), buttonWidth, 20.0f);
        textLabel.text                      = dictionary[@"title"];
        [strongself.scrollview addSubview:textLabel];
        lastLabel                           = textLabel;
    
    }];

    CGRect frame = self.frame;
    frame.size.height = CGRectGetMaxY(lastLabel.frame) + 20.0f;

    self.frame = frame;
    _scrollview.frame = CGRectMake(0, 0, CGRectGetWidth(frame), CGRectGetHeight(frame));
    _pageControl.frame = CGRectMake(0, CGRectGetHeight(frame) - 20, CGRectGetWidth(frame), 20);
    _pageControl.hidden = _pageControl.numberOfPages<=1;
    
}

/**
 点击了 toolBar 上的 button
 */
- (void)buttonClick:(UIButton *)btn {
    
    NSInteger selectIndex = btn.tag;
    
    switch (selectIndex) {
        case 0:
        {
            [self takePicAction]; // 相机
        }
            break;
        case 1:
        {
            [self photoAction]; // 相册
        }
            break;
        case 3:
        {
            [self takevideoChat]; // 视频通话
        }
            break;
        case 4:
        {
            [self takeRedpacket]; // 红包
        }
            break;
        case 5:
        {
            [self  takeBusinessCard]; // 名片
        }
            break;
        default:
        {
            [self storeAction]; // 供销社
        }
            break;
    }
    
}

- (void)insertItemWithImage:(UIImage *)image highlightedImage:(UIImage *)highLightedImage title:(NSString *)title
{
    CGFloat insets = (self.frame.size.width - MOREVIEW_COL * CHAT_BUTTON_SIZE) / 5;
    CGRect frame = self.frame;
    _maxIndex++;
    NSInteger pageSize = MOREVIEW_COL*MOREVIEW_ROW;
    NSInteger page = _maxIndex/pageSize;
    NSInteger row = (_maxIndex%pageSize)/MOREVIEW_COL;
    NSInteger col = _maxIndex%MOREVIEW_COL;
    UIButton *moreButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [moreButton setFrame:CGRectMake(page * CGRectGetWidth(self.frame) + insets * (col + 1) + CHAT_BUTTON_SIZE * col, INSETS + INSETS * 2 * row + CHAT_BUTTON_SIZE * row, CHAT_BUTTON_SIZE , CHAT_BUTTON_SIZE)];
    [moreButton setImage:image forState:UIControlStateNormal];
    [moreButton setImage:highLightedImage forState:UIControlStateHighlighted];
    [moreButton addTarget:self action:@selector(moreAction:) forControlEvents:UIControlEventTouchUpInside];
    moreButton.tag = MOREVIEW_BUTTON_TAG+_maxIndex;
    [_scrollview addSubview:moreButton];
    [_scrollview setContentSize:CGSizeMake(CGRectGetWidth(self.frame) * (page + 1), CGRectGetHeight(self.frame))];
    [_pageControl setNumberOfPages:page + 1];
    if (_maxIndex >=5) {
        frame.size.height = 150;
        _scrollview.frame = CGRectMake(0, 0, CGRectGetWidth(frame), CGRectGetHeight(frame));
        _pageControl.frame = CGRectMake(0, CGRectGetHeight(frame) - 20, CGRectGetWidth(frame), 20);
    }
    self.frame = frame;
    _pageControl.hidden = _pageControl.numberOfPages<=1;
}

- (void)updateItemWithImage:(UIImage *)image highlightedImage:(UIImage *)highLightedImage title:(NSString *)title atIndex:(NSInteger)index
{
    UIView *moreButton = [_scrollview viewWithTag:MOREVIEW_BUTTON_TAG+index];
    if (moreButton && [moreButton isKindOfClass:[UIButton class]]) {
        [(UIButton*)moreButton setImage:image forState:UIControlStateNormal];
        [(UIButton*)moreButton setImage:highLightedImage forState:UIControlStateHighlighted];
    }
}

- (void)removeItematIndex:(NSInteger)index
{
    UIView *moreButton = [_scrollview viewWithTag:MOREVIEW_BUTTON_TAG+index];
    if (moreButton && [moreButton isKindOfClass:[UIButton class]]) {
        [self _resetItemFromIndex:index];
        [moreButton removeFromSuperview];
    }
}

#pragma mark - private

- (void)_resetItemFromIndex:(NSInteger)index
{
    CGFloat insets = (self.frame.size.width - MOREVIEW_COL * CHAT_BUTTON_SIZE) / 5;
    CGRect frame = self.frame;
    for (NSInteger i = index + 1; i<_maxIndex + 1; i++) {
        UIView *moreButton = [_scrollview viewWithTag:MOREVIEW_BUTTON_TAG+i];
        if (moreButton && [moreButton isKindOfClass:[UIButton class]]) {
            NSInteger moveToIndex = i - 1;
            NSInteger pageSize = MOREVIEW_COL*MOREVIEW_ROW;
            NSInteger page = moveToIndex/pageSize;
            NSInteger row = (moveToIndex%pageSize)/MOREVIEW_COL;
            NSInteger col = moveToIndex%MOREVIEW_COL;
            [moreButton setFrame:CGRectMake(page * CGRectGetWidth(self.frame) + insets * (col + 1) + CHAT_BUTTON_SIZE * col, INSETS + INSETS * 2 * row + CHAT_BUTTON_SIZE * row, CHAT_BUTTON_SIZE , CHAT_BUTTON_SIZE)];
            moreButton.tag = MOREVIEW_BUTTON_TAG+moveToIndex;
            [_scrollview setContentSize:CGSizeMake(CGRectGetWidth(self.frame) * (page + 1), CGRectGetHeight(self.frame))];
            [_pageControl setNumberOfPages:page + 1];
        }
    }
    _maxIndex--;
    if (_maxIndex >=5) {
        frame.size.height = 150;
    } else {
        frame.size.height = 80;
    }
    self.frame = frame;
    _scrollview.frame = CGRectMake(0, 0, CGRectGetWidth(frame), CGRectGetHeight(frame));
    _pageControl.frame = CGRectMake(0, CGRectGetHeight(frame) - 20, CGRectGetWidth(frame), 20);
    _pageControl.hidden = _pageControl.numberOfPages<=1;
}

#pragma setter
//- (void)setMoreViewColumn:(NSInteger)moreViewColumn
//{
//    if (_moreViewColumn != moreViewColumn) {
//        _moreViewColumn = moreViewColumn;
//        [self setupSubviewsForType:_type];
//    }
//}
//
//- (void)setMoreViewNumber:(NSInteger)moreViewNumber
//{
//    if (_moreViewNumber != moreViewNumber) {
//        _moreViewNumber = moreViewNumber;
//        [self setupSubviewsForType:_type];
//    }
//}

- (void)setMoreViewBackgroundColor:(UIColor *)moreViewBackgroundColor
{
    _moreViewBackgroundColor = moreViewBackgroundColor;
    if (_moreViewBackgroundColor) {
        [self setBackgroundColor:_moreViewBackgroundColor];
    }
}

/*
- (void)setMoreViewButtonImages:(NSArray *)moreViewButtonImages
{
    _moreViewButtonImages = moreViewButtonImages;
    if ([_moreViewButtonImages count] > 0) {
        for (UIView *view in self.subviews) {
            if ([view isKindOfClass:[UIButton class]]) {
                UIButton *button = (UIButton *)view;
                if (button.tag < [_moreViewButtonImages count]) {
                    NSString *imageName = [_moreViewButtonImages objectAtIndex:button.tag];
                    [button setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
                }
            }
        }
    }
}

- (void)setMoreViewButtonHignlightImages:(NSArray *)moreViewButtonHignlightImages
{
    _moreViewButtonHignlightImages = moreViewButtonHignlightImages;
    if ([_moreViewButtonHignlightImages count] > 0) {
        for (UIView *view in self.subviews) {
            if ([view isKindOfClass:[UIButton class]]) {
                UIButton *button = (UIButton *)view;
                if (button.tag < [_moreViewButtonHignlightImages count]) {
                    NSString *imageName = [_moreViewButtonHignlightImages objectAtIndex:button.tag];
                    [button setImage:[UIImage imageNamed:imageName] forState:UIControlStateHighlighted];
                }
            }
        }
    }
}*/

#pragma mark - UIScrollViewDelegate

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    CGPoint offset =  scrollView.contentOffset;
    if (offset.x == 0) {
        _pageControl.currentPage = 0;
    } else {
        int page = offset.x / CGRectGetWidth(scrollView.frame);
        _pageControl.currentPage = page;
    }
}

#pragma mark - action

- (void)takePicAction{
    if(_delegate && [_delegate respondsToSelector:@selector(moreViewTakePicAction:)]){
        [_delegate moreViewTakePicAction:self];
    }
}

- (void)photoAction
{
    if (_delegate && [_delegate respondsToSelector:@selector(moreViewPhotoAction:)]) {
        [_delegate moreViewPhotoAction:self];
    }
}

- (void)locationAction
{
    if (_delegate && [_delegate respondsToSelector:@selector(moreViewLocationAction:)]) {
        [_delegate moreViewLocationAction:self];
    }
}
- (void)storeAction {
    if ([self.delegate respondsToSelector:@selector(moreViewStoreAction:)]) {
        [self.delegate moreViewStoreAction:self];
    }
}
- (void)takeAudioCallAction
{
    if (_delegate && [_delegate respondsToSelector:@selector(moreViewAudioCallAction:)]) {
        [_delegate moreViewAudioCallAction:self];
    }
}

- (void)takeVideoCallAction
{
    if (_delegate && [_delegate respondsToSelector:@selector(moreViewVideoCallAction:)]) {
        [_delegate moreViewVideoCallAction:self];
    }
}

/**
 红包功能
 */
- (void)takeRedpacket {

    if (self.delegate && [self.delegate respondsToSelector:@selector(moreViewRedPacketAction:)]) {
        [self.delegate moreViewRedPacketAction:self];
    }
}

/**
    视频聊天
 */
- (void)takevideoChat {
    
    if (self.delegate&&[self.delegate respondsToSelector:@selector(moreViewVideoChatAction:)]) {
        [self.delegate moreViewVideoChatAction:self];
    }
    
}

/**
 名片功能
 */
- (void)takeBusinessCard {
    
    if (self.delegate&&[self.delegate respondsToSelector:@selector(moreViewBusinessCardAction:)]) {
        [self.delegate moreViewBusinessCardAction:self];
    }
}

- (void)moreAction:(id)sender
{
    UIButton *button = (UIButton*)sender;
    if (button && _delegate && [_delegate respondsToSelector:@selector(moreView:didItemInMoreViewAtIndex:)]) {
        [_delegate moreView:self didItemInMoreViewAtIndex:button.tag-MOREVIEW_BUTTON_TAG];
    }
}

@end
