//
//  OKTokenNoResultView.h
//  OneKey
//
//  Created by zj on 2021/3/2.
//  Copyright © 2021 Onekey. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface OKTokenNoResultView : UIView
@property (nonatomic, copy) void(^addTokenCallback)(void);
+ (nullable instancetype)getView;
@end

NS_ASSUME_NONNULL_END
