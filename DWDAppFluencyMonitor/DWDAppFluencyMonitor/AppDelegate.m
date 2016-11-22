//
//  AppDelegate.m
//  DWDAppFluencyMonitor
//
//  Created by dianwoda on 16/11/22.
//  Copyright © 2016年 dianwoda. All rights reserved.
//

#import "AppDelegate.h"
#import "DWDAppFluencyMonitor.h"
@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    
    [[DWDAppFluencyMonitor sharedInstance] startMonitoring];
    return YES;
}



@end
