//
//  UIDevice+afm_Hardware.h
//  dwdmonitor
//
//  Created by dianwoda on 16/9/29.
//  Copyright © 2016年 dianwoda. All rights reserved.
//

#import <UIKit/UIKit.h>

#define IFPGA_NAMESTRING                @"iFPGA"

#define IPHONE_1G_NAMESTRING            @"iPhone 1G"
#define IPHONE_3G_NAMESTRING            @"iPhone 3G"
#define IPHONE_3GS_NAMESTRING           @"iPhone 3GS" 
#define IPHONE_4_NAMESTRING             @"iPhone 4" 
#define IPHONE_4S_NAMESTRING            @"iPhone 4S"
#define IPHONE_5_NAMESTRING             @"iPhone 5"
#define IPHONE_5C_NAMESTRING            @"iPhone 5C"
#define IPHONE_5S_NAMESTRING            @"iPhone 5S"
#define IPHONE_6_NAMESTRING             @"iPhone 6"
#define IPHONE_6_PLUS_NAMESTRING        @"iPhone 6 Plus"
#define IPHONE_6S_NAMESTRING            @"iPhone 6S"
#define IPHONE_6S_PLUS_NAMESTRING       @"iPhone 6S Plus"
#define IPHONE_SE_NAMESTRING            @"iPhone SE"
#define IPHONE_UNKNOWN_NAMESTRING       @"Unknown iPhone"

#define IPOD_1G_NAMESTRING              @"iPod touch 1G"
#define IPOD_2G_NAMESTRING              @"iPod touch 2G"
#define IPOD_3G_NAMESTRING              @"iPod touch 3G"
#define IPOD_4G_NAMESTRING              @"iPod touch 4G"
#define IPOD_5G_NAMESTRING              @"iPod touch 5G"
#define IPOD_6G_NAMESTRING              @"iPod touch 6G"
#define IPOD_UNKNOWN_NAMESTRING         @"Unknown iPod"

#define IPAD_1G_NAMESTRING              @"iPad 1G"
#define IPAD_2G_NAMESTRING              @"iPad 2G"
#define IPAD_3G_NAMESTRING              @"iPad 3G"
#define IPAD_4G_NAMESTRING              @"iPad 4G"
#define IPAD_AIR_NAMESTRING             @"iPad Air"
#define IPAD_AIR2_NAMESTRING            @"iPad Air 2"
#define IPAD_PRO_12_9_NAMESTRING        @"iPad Pro 12.9-inch"
#define IPAD_PRO_9_7_NAMESTRING         @"iPad Pro 9.7-inch"

#define IPAD_MINI_1G_NAMESTRING         @"iPad mini 1G"
#define IPAD_MINI_2G_NAMESTRING         @"iPad mini 2G"
#define IPAD_MINI_3G_NAMESTRING         @"iPad mini 3G"
#define IPAD_MINI_4G_NAMESTRING         @"iPad mini 4G"
#define IPAD_UNKNOWN_NAMESTRING         @"Unknown iPad"

#define APPLETV_2G_NAMESTRING           @"Apple TV 2G"
#define APPLETV_3G_NAMESTRING           @"Apple TV 3G"
#define APPLETV_4G_NAMESTRING           @"Apple TV 4G"
#define APPLETV_UNKNOWN_NAMESTRING      @"Unknown Apple TV"

#define IOS_FAMILY_UNKNOWN_DEVICE       @"Unknown iOS device"

#define SIMULATOR_NAMESTRING            @"iPhone Simulator"
#define SIMULATOR_IPHONE_NAMESTRING     @"iPhone Simulator"
#define SIMULATOR_IPAD_NAMESTRING       @"iPad Simulator"
#define SIMULATOR_APPLETV_NAMESTRING    @"Apple TV Simulator" // :)

typedef enum {
    UIDeviceUnknown,
    
    UIDeviceSimulator,
    UIDeviceSimulatoriPhone,
    UIDeviceSimulatoriPad,
    UIDeviceSimulatorAppleTV,
    
    UIDevice1GiPhone,
    UIDevice3GiPhone,
    UIDevice3GSiPhone,
    UIDevice4iPhone,
    UIDevice4SiPhone,
    UIDevice5iPhone,
    UIDevice5CiPhone,
    UIDevice5SiPhone,
    UIDevice6iPhone,
    UIDevice6PlusiPhone,
    UIDevice6SiPhone,
    UIDevice6SPlusiPhone,
    UIDeviceSEiPhone,
    
    UIDevice1GiPod,
    UIDevice2GiPod,
    UIDevice3GiPod,
    UIDevice4GiPod,
    UIDevice5GiPod,
    UIDevice6GiPod,
    
    UIDevice1GiPad,
    UIDevice2GiPad,
    UIDevice3GiPad,
    UIDevice4GiPad,
    UIDeviceAiriPad,
    UIDeviceAir2iPad,
    UIDeviceProiPad_12_9,
    UIDeviceProiPad_9_7,
    
    UIDevice1GiPadMini,
    UIDevice2GiPadMini,
    UIDevice3GiPadMini,
    UIDevice4GiPadMini,

    UIDeviceAppleTV2,
    UIDeviceAppleTV3,
    UIDeviceAppleTV4,
    
    UIDeviceUnknowniPhone,
    UIDeviceUnknowniPod,
    UIDeviceUnknowniPad,
    UIDeviceUnknownAppleTV,
    UIDeviceIFPGA,

} UIDevicePlatform;

typedef enum {
    UIDeviceFamilyiPhone,
    UIDeviceFamilyiPod,
    UIDeviceFamilyiPad,
    UIDeviceFamilyAppleTV,
    UIDeviceFamilyUnknown,
    
} UIDeviceFamily;

// 设备CPU类型性能分级
typedef NS_ENUM(NSInteger,UIDeviceCPUPerformanceType) {
    UIDevice_CPU_Samsung  =  0, // iPhone(1、3G、3GS)、iPod Touch (1、2、3)
    UIDevice_CPU_A4 = 1,        // iPhone(4) 、iPad(1)、iPod Touch (4)、AppleTV(1)
    UIDevice_CPU_A5 = 2,        // iPhone(4s) 、iPad(2、mini)、iPod Touch (5)、AppleTV(2、3)
    UIDevice_CPU_A5X = 3,       // iPad(3)
    UIDevice_CPU_A6 = 4,        // iPhone(5、5c)
    UIDevice_CPU_A6X = 5,       // iPad(4)
    UIDevice_CPU_A7 = 6,        // iPhone(5s) iPad (air、 mini2、mini3)
    UIDevice_CPU_A8 = 7,        // iPhone(6、 6 plus)
    UIDevice_CPU_A8X = 8,       // iPad (air2)、iPod Touch（6）、AppleTV(4)
    UIDevice_CPU_A9 = 9,        // iPhone (6s、 6s plus 、SE)
    UIDevice_CPU_A9X = 10,      // iPad Pro（12.9寸） 和 IPad Pro（9.7寸
    UIDevice_CPU_Unknown = 200
};


@interface UIDevice (Hardware)
- (NSString *) platform;
- (NSString *) hwmodel;
- (UIDevicePlatform) platformMTType;
- (NSString *) platformString;

- (NSUInteger) cpuFrequency;
- (NSUInteger) busFrequency;
- (NSUInteger) cpuCount;
- (NSUInteger) totalMemory;
- (NSUInteger) userMemory;

- (double) availableMemory;

- (NSNumber *) totalDiskSpace;
- (NSNumber *) freeDiskSpace;

- (BOOL)isJailbroken;
- (BOOL)isAppSyncExist;

- (NSString *) macaddress;
- (NSString *) minimacaddress;

- (NSString *) idfaString;
- (NSString *) idfvString;

- (BOOL) hasRetinaDisplay;
- (UIDeviceFamily) deviceFamily;

/*
 *  判断机型是否比device好，如果大于或者等于的话，则返回YES,否则返回NO
 */
- (BOOL) isBetterThanDevice:(UIDevicePlatform) device;

/*
 *  判断机型是否比device差，如果小于或者等于的话，则返回YES,否则返回NO
 */
- (BOOL) isLessThanDevice:(UIDevicePlatform) device;


/**
 *  返回当前设备的CPU类型
 *
 *  @return
 */
- (UIDeviceCPUPerformanceType)deviceCPUType;

/**
 *  返回指定platform设备对应的CPU性能等级
 *
 *  @param platform 
 *
 *  @return
 */
+ (UIDeviceCPUPerformanceType)deviceCPUTypeWithDevice:(NSString *)platform;

@end
