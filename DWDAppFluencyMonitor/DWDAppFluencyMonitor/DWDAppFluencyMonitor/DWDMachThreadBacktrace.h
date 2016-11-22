//
//  DWDMachThreadBacktrace.h
//  dwdmonitor
//
//  Created by dianwoda on 16/9/29.
//  Copyright © 2016年 dianwoda. All rights reserved.
//


#ifndef DWDMachThreadBacktrace_h
#define DWDMachThreadBacktrace_h

#include <stdio.h>

#include <mach/mach.h>

/**
 *  fill a backtrace call stack array of given thread
 *
 *  @param thread   mach thread for tracing
 *  @param stack    caller space for saving stack trace info
 *  @param maxCount max stack array count
 *
 *  @return call stack address array
 */
int sxd_backtraceForMachThread(thread_t thread, void** stack, int maxCount);


#endif /* DWDMachThreadBacktrace_h */
