//
//  DWDAppFluencyMonitor.h
//  dwdmonitor
//
//  Created by dianwoda on 16/9/29.
//  Copyright © 2016年 dianwoda. All rights reserved.
//


#import <Foundation/Foundation.h>

/**
 *  基于NSRunLoop监听主线程卡顿工具类
 */
@interface DWDAppFluencyMonitor : NSObject

@property (nonatomic, assign) BOOL logsEnabled;

+ (instancetype)sharedInstance;

/**
 *  开启监听
 */
- (void)startMonitoring;

/**
 *  关闭监听
 */
- (void)stopMonitoring;

@end

