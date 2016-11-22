//
//  UIDevice+afm_Hardware.m
//  dwdmonitor
//
//  Created by dianwoda on 16/9/29.
//  Copyright © 2016年 dianwoda. All rights reserved.
//

#include <sys/socket.h> // Per msqr
#include <sys/sysctl.h>
#include <net/if.h>
#include <net/if_dl.h>
#include <mach/mach.h>

#import "UIDevice+afm_Hardware.h"

//for idfa
#import <AdSupport/AdSupport.h>

@implementation UIDevice (Hardware)
/*
 Platforms
 
 iFPGA ->        ??
 
 iPhone1,1 ->    iPhone 1G, M68
 iPhone1,2 ->    iPhone 3G, N82
 iPhone2,1 ->    iPhone 3GS, N88
 iPhone3,1 ->    iPhone 4/AT&T, N89
 iPhone3,2 ->    iPhone 4/Other Carrier?, ??
 iPhone3,3 ->    iPhone 4/Verizon, TBD
 iPhone4,1 ->    (iPhone 4S/GSM), TBD
 iPhone4,2 ->    (iPhone 4S/CDMA), TBD
 iPhone4,3 ->    (iPhone 4S/???)
 iPhone5,1 ->    iPhone 5
 iPhone5,2 ->    iPhone 5
 iPhone5,3 ->    iPhone 5c
 iPhone5,4 ->    iPhone 5c
 iPhone6,1 ->    iPhone 5s
 iPhone6,2 ->    iPhone 5s
 iPhone7,1 ->    iPhone 6 Plus
 iPhone7,2 ->    iPhone 6
 iPhone8,1 ->    iPhone 6s Plus
 iPhone8,2 ->    iPhone 6s
 
 iPod1,1   ->    iPod touch 1G, N45
 iPod2,1   ->    iPod touch 2G, N72
 iPod2,2   ->    Unknown, ??
 iPod3,1   ->    iPod touch 3G, N18
 iPod4,1   ->    iPod touch 4G, N80
 
 // Thanks NSForge
 iPad1,1   ->    iPad 1G, WiFi and 3G, K48
 iPad2,1   ->    iPad 2G, WiFi, K93
 iPad2,2   ->    iPad 2G, GSM 3G, K94
 iPad2,3   ->    iPad 2G, CDMA 3G, K95
 iPad2,4   ->    iPad 2G,
 iPad3,1   ->    (iPad 3G, WiFi)
 iPad3,2   ->    (iPad 3G, GSM)
 iPad3,3   ->    (iPad 3G, CDMA)
 iPad3,4   ->    (iPad 3G)
 iPad3,5   ->    (iPad 3G)
 iPad3,6   ->    (iPad 3G)
 iPad4,1   ->    (iPad Air, WiFi)
 iPad4,2   ->    (iPad Air, GSM)
 iPad4,3   ->    (iPad Air, CDMA)
 iPad5,3   ->    (iPad Air 2)
 iPad5,4   ->    (iPad Air 2)
 
 iPad2,5   ->    iPad Mini 1G,
 iPad2,6   ->    iPad Mini 1G,
 iPad2,7   ->    iPad Mini 1G,
 iPad4,4   ->    iPad Mini 2G,
 iPad4,5   ->    iPad Mini 2G,
 iPad4,6   ->    iPad Mini 2G,
 iPad4,7   ->    iPad Mini 3G,
 iPad4,8   ->    iPad Mini 3G,
 iPad4,9   ->    iPad Mini 3G,
 
 AppleTV2,1 ->   AppleTV 2, A1378
 AppleTV3,1 ->   AppleTV 3, A1427
 AppleTV3,2 ->   AppleTV 4, A1469
 
 i386, x86_64 -> iPhone Simulator
 */


#pragma mark sysctlbyname utils
- (NSString *) getSysInfoByName:(char *)typeSpecifier
{
    size_t size;
    sysctlbyname(typeSpecifier, NULL, &size, NULL, 0);
    
    char *answer = malloc(size);
    sysctlbyname(typeSpecifier, answer, &size, NULL, 0);
    
    NSString *results = [NSString stringWithCString:answer encoding: NSUTF8StringEncoding];

    free(answer);
    return results;
}

- (NSString *) platform
{
    return [self getSysInfoByName:"hw.machine"];
}


// Thanks, Tom Harrington (Atomicbird)
- (NSString *) hwmodel
{
    return [self getSysInfoByName:"hw.model"];
}

#pragma mark sysctl utils
- (NSUInteger) getSysInfo: (uint) typeSpecifier
{
    size_t size = sizeof(int);
    int results;
    int mib[2] = {CTL_HW, typeSpecifier};
    sysctl(mib, 2, &results, &size, NULL, 0);
    return (NSUInteger) results;
}

- (NSUInteger) cpuFrequency
{
    return [self getSysInfo:HW_CPU_FREQ];
}

- (NSUInteger) busFrequency
{
    return [self getSysInfo:HW_BUS_FREQ];
}

- (NSUInteger) cpuCount
{
    return [self getSysInfo:HW_NCPU];
}

- (NSUInteger) totalMemory
{
    return [self getSysInfo:HW_PHYSMEM];
}

- (NSUInteger) userMemory
{
    return [self getSysInfo:HW_USERMEM];
}

- (NSUInteger) maxSocketBufferSize
{
    return [self getSysInfo:KIPC_MAXSOCKBUF];
}

- (double)availableMemory {
	vm_statistics_data_t vmStats;
	mach_msg_type_number_t infoCount = HOST_VM_INFO_COUNT;
	kern_return_t kernReturn = host_statistics(mach_host_self(), HOST_VM_INFO, (host_info_t)&vmStats, &infoCount);
    
	if(kernReturn != KERN_SUCCESS) {
		return NSNotFound;
	}
    
	return ((vm_page_size * vmStats.free_count) / 1024.0) / 1024.0;
}

#pragma mark file system -- Thanks Joachim Bean!

/*
 extern NSString *NSFileSystemSize;
 extern NSString *NSFileSystemFreeSize;
 extern NSString *NSFileSystemNodes;
 extern NSString *NSFileSystemFreeNodes;
 extern NSString *NSFileSystemNumber;
*/

- (NSNumber *) totalDiskSpace
{
    NSDictionary *fattributes = [[NSFileManager defaultManager] attributesOfFileSystemForPath:NSHomeDirectory() error:nil];
    return [fattributes objectForKey:NSFileSystemSize];
}

- (NSNumber *) freeDiskSpace
{
    NSDictionary *fattributes = [[NSFileManager defaultManager] attributesOfFileSystemForPath:NSHomeDirectory() error:nil];
    return [fattributes objectForKey:NSFileSystemFreeSize];
}

#pragma mark platform type and name utils
- (UIDevicePlatform) platformMTType
{
    NSString *platform = [self platform];
    return [UIDevice platformMTTypeFor:platform];
}

+ (UIDevicePlatform)platformMTTypeFor:(NSString *)platform {
    
    // The ever mysterious iFPGA
    if ([platform isEqualToString:@"iFPGA"])        return UIDeviceIFPGA;
    
    // iPhone
    if ([platform isEqualToString:@"iPhone1,1"])    return UIDevice1GiPhone;
    if ([platform isEqualToString:@"iPhone1,2"])    return UIDevice3GiPhone;
    if ([platform hasPrefix:@"iPhone2"])            return UIDevice3GSiPhone;
    if ([platform hasPrefix:@"iPhone3"])            return UIDevice4iPhone;
    if ([platform hasPrefix:@"iPhone4"])            return UIDevice4SiPhone;
    
    if ([platform hasPrefix:@"iPhone5,1"] ||
        [platform hasPrefix:@"iPhone5,2"])           return UIDevice5iPhone;
    if ([platform hasPrefix:@"iPhone5,3"] ||
        [platform hasPrefix:@"iPhone5,4"])           return UIDevice5CiPhone;
    if ([platform hasPrefix:@"iPhone6,1"] ||
        [platform hasPrefix:@"iPhone6,2"])           return UIDevice5SiPhone;
    if ([platform hasPrefix:@"iPhone7,1"])            return UIDevice6PlusiPhone;
    if ([platform hasPrefix:@"iPhone7,2"])            return UIDevice6iPhone;
    if ([platform hasPrefix:@"iPhone8,1"])            return UIDevice6SiPhone;
    if ([platform hasPrefix:@"iPhone8,2"])            return UIDevice6SPlusiPhone;
    if ([platform hasPrefix:@"iPhone8,4"])            return UIDeviceSEiPhone;
    
    // iPod
    if ([platform hasPrefix:@"iPod1"])              return UIDevice1GiPod;
    if ([platform hasPrefix:@"iPod2"])              return UIDevice2GiPod;
    if ([platform hasPrefix:@"iPod3"])              return UIDevice3GiPod;
    if ([platform hasPrefix:@"iPod4"])              return UIDevice4GiPod;
    if ([platform hasPrefix:@"iPod5"])              return UIDevice5GiPod;
    if ([platform hasPrefix:@"iPod7"])              return UIDevice6GiPod;
    
    // iPad
    if ([platform hasPrefix:@"iPad1"])              return UIDevice1GiPad;
    if ([platform hasPrefix:@"iPad2,1"] ||
        [platform hasPrefix:@"iPad2,2"] ||
        [platform hasPrefix:@"iPad2,3"] ||
        [platform hasPrefix:@"iPad2,4"])              return UIDevice2GiPad;
    if ([platform hasPrefix:@"iPad2,5"] ||
        [platform hasPrefix:@"iPad2,6"] ||
        [platform hasPrefix:@"iPad2,7"])              return UIDevice1GiPadMini;
    if ([platform hasPrefix:@"iPad3,1"] ||
        [platform hasPrefix:@"iPad3,2"] ||
        [platform hasPrefix:@"iPad3,3"])              return UIDevice3GiPad;
    if ([platform hasPrefix:@"iPad3,4"] ||
        [platform hasPrefix:@"iPad3,5"] ||
        [platform hasPrefix:@"iPad3,6"])              return UIDevice4GiPad;
    if ([platform hasPrefix:@"iPad4,1"] ||
        [platform hasPrefix:@"iPad4,2"] ||
        [platform hasPrefix:@"iPad4,3"])              return UIDeviceAiriPad;
    if ([platform hasPrefix:@"iPad4,4"] ||
        [platform hasPrefix:@"iPad4,5"] ||
        [platform hasPrefix:@"iPad4,6"])              return UIDevice2GiPadMini;
    if ([platform hasPrefix:@"iPad4,7"] ||
        [platform hasPrefix:@"iPad4,8"] ||
        [platform hasPrefix:@"iPad4,9"])              return UIDevice3GiPadMini;
    if ([platform hasPrefix:@"iPad5,1"] ||
        [platform hasPrefix:@"iPad5,2"])              return UIDevice4GiPadMini;
    if ([platform hasPrefix:@"iPad5,3"] ||
        [platform hasPrefix:@"iPad5,4"])              return UIDeviceAir2iPad;
    
    if ([platform hasPrefix:@"iPad6,3"] ||
        [platform hasPrefix:@"iPad6,4"])              return UIDeviceProiPad_9_7;
    if ([platform hasPrefix:@"iPad6,7"] ||
        [platform hasPrefix:@"iPad6,8"])              return UIDeviceProiPad_12_9;
    
    // Apple TV
    if ([platform hasPrefix:@"AppleTV2,1"])           return UIDeviceAppleTV2;
    if ([platform hasPrefix:@"AppleTV3,1"] ||
        [platform hasPrefix:@"AppleTV3,2"])           return UIDeviceAppleTV3;
    if ([platform hasPrefix:@"AppleTV5,3"])           return UIDeviceAppleTV4;
    
    if ([platform hasPrefix:@"iPhone"])             return UIDeviceUnknowniPhone;
    if ([platform hasPrefix:@"iPod"])               return UIDeviceUnknowniPod;
    if ([platform hasPrefix:@"iPad"])               return UIDeviceUnknowniPad;
    if ([platform hasPrefix:@"AppleTV"])            return UIDeviceUnknownAppleTV;
    
    // Simulator thanks Jordan Breeding
    if ([platform hasSuffix:@"86"] || [platform isEqual:@"x86_64"])
    {
        BOOL smallerScreen = [[UIScreen mainScreen] bounds].size.width < 768;
        return smallerScreen ? UIDeviceSimulatoriPhone : UIDeviceSimulatoriPad;
    }
    
    return UIDeviceUnknown;
}


- (NSString *) platformString
{
    switch ([self platformMTType])
    {
        case UIDevice1GiPhone: return IPHONE_1G_NAMESTRING;
        case UIDevice3GiPhone: return IPHONE_3G_NAMESTRING;
        case UIDevice3GSiPhone: return IPHONE_3GS_NAMESTRING;
        case UIDevice4iPhone: return IPHONE_4_NAMESTRING;
        case UIDevice4SiPhone: return IPHONE_4S_NAMESTRING;
        case UIDevice5iPhone: return IPHONE_5_NAMESTRING;
        case UIDevice5CiPhone: return IPHONE_5C_NAMESTRING;
        case UIDevice5SiPhone: return IPHONE_5S_NAMESTRING;
        case UIDevice6iPhone: return IPHONE_6_NAMESTRING;
        case UIDevice6PlusiPhone: return IPHONE_6_PLUS_NAMESTRING;
        case UIDevice6SiPhone: return IPHONE_6S_NAMESTRING;
        case UIDevice6SPlusiPhone: return IPHONE_6S_PLUS_NAMESTRING;
        case UIDeviceSEiPhone: return IPHONE_SE_NAMESTRING;
        case UIDeviceUnknowniPhone: return IPHONE_UNKNOWN_NAMESTRING;
            
        case UIDevice1GiPod: return IPOD_1G_NAMESTRING;
        case UIDevice2GiPod: return IPOD_2G_NAMESTRING;
        case UIDevice3GiPod: return IPOD_3G_NAMESTRING;
        case UIDevice4GiPod: return IPOD_4G_NAMESTRING;
        case UIDevice5GiPod: return IPOD_5G_NAMESTRING;
        case UIDevice6GiPod: return IPOD_6G_NAMESTRING;
        case UIDeviceUnknowniPod: return IPOD_UNKNOWN_NAMESTRING;
            
        case UIDevice1GiPad : return IPAD_1G_NAMESTRING;
        case UIDevice2GiPad : return IPAD_2G_NAMESTRING;
        case UIDevice3GiPad : return IPAD_3G_NAMESTRING;
        case UIDevice4GiPad : return IPAD_4G_NAMESTRING;
        case UIDeviceAiriPad : return IPAD_AIR_NAMESTRING;
        case UIDeviceAir2iPad : return IPAD_AIR2_NAMESTRING;
        case UIDeviceProiPad_9_7 : return IPAD_PRO_9_7_NAMESTRING;
        case UIDeviceProiPad_12_9 : return IPAD_PRO_12_9_NAMESTRING;
        case UIDevice1GiPadMini : return IPAD_MINI_1G_NAMESTRING;
        case UIDevice2GiPadMini : return IPAD_MINI_2G_NAMESTRING;
        case UIDevice3GiPadMini : return IPAD_MINI_3G_NAMESTRING;
        case UIDevice4GiPadMini : return IPAD_MINI_4G_NAMESTRING;
        case UIDeviceUnknowniPad : return IPAD_UNKNOWN_NAMESTRING;
            
        case UIDeviceAppleTV2 : return APPLETV_2G_NAMESTRING;
        case UIDeviceAppleTV3 : return APPLETV_3G_NAMESTRING;
        case UIDeviceAppleTV4 : return APPLETV_4G_NAMESTRING;
        case UIDeviceUnknownAppleTV: return APPLETV_UNKNOWN_NAMESTRING;
            
        case UIDeviceSimulator: return SIMULATOR_NAMESTRING;
        case UIDeviceSimulatoriPhone: return SIMULATOR_IPHONE_NAMESTRING;
        case UIDeviceSimulatoriPad: return SIMULATOR_IPAD_NAMESTRING;
        case UIDeviceSimulatorAppleTV: return SIMULATOR_APPLETV_NAMESTRING;
            
        case UIDeviceIFPGA: return IFPGA_NAMESTRING;
            
        default: return IOS_FAMILY_UNKNOWN_DEVICE;
    }
}


- (BOOL) hasRetinaDisplay
{
    return ([UIScreen mainScreen].scale >= 2.0f);
}

- (UIDeviceFamily) deviceFamily
{
    NSString *platform = [self platform];
    if ([platform hasPrefix:@"iPhone"]) return UIDeviceFamilyiPhone;
    if ([platform hasPrefix:@"iPod"]) return UIDeviceFamilyiPod;
    if ([platform hasPrefix:@"iPad"]) return UIDeviceFamilyiPad;
    if ([platform hasPrefix:@"AppleTV"]) return UIDeviceFamilyAppleTV;
    
    return UIDeviceFamilyUnknown;
}

#pragma mark MAC addy
// Return the local MAC addy
// Courtesy of FreeBSD hackers email list
// Accidentally munged during previous update. Fixed thanks to mlamb.
- (NSString *) macaddress
{
    int 				mib[6];
	size_t 				len;
	char 				*buf;
	unsigned char	 	*ptr;
	struct if_msghdr 	*ifm;
	struct sockaddr_dl 	*sdl;
    
	mib[0] = CTL_NET;
	mib[1] = AF_ROUTE;
	mib[2] = 0;
	mib[3] = AF_LINK;
	mib[4] = NET_RT_IFLIST;
    
	if ((mib[5] = if_nametoindex("en0")) == 0) {
		printf("Error: if_nametoindex error\n");
		return NULL;
	}
    
	if (sysctl(mib, 6, NULL, &len, NULL, 0) < 0) {
		printf("Error: sysctl, take 1\n");
		return NULL;
	}
    
	if ((buf = malloc(len)) == NULL) {
		printf("Could not allocate memory. error!\n");
		return NULL;
	}
    
	if (sysctl(mib, 6, buf, &len, NULL, 0) < 0) {
		printf("Error: sysctl, take 2");
		free(buf);
		return NULL;
	}
    
	ifm = (struct if_msghdr *)buf;
	sdl = (struct sockaddr_dl *)(ifm + 1);
	ptr = (unsigned char *)LLADDR(sdl);
	NSString *macString = [NSString stringWithFormat:@"%02X:%02X:%02X:%02X:%02X:%02X",
                           *ptr, *(ptr+1), *(ptr+2), *(ptr+3), *(ptr+4), *(ptr+5)];
	free(buf);
    
	return macString;
}

- (NSString *) minimacaddress
{
    return [[self macaddress] stringByReplacingOccurrencesOfString:@":" withString:@""];
}

- (NSString *) idfaString {
    NSBundle *adSupportBundle = [NSBundle bundleWithPath:@"/System/Library/Frameworks/AdSupport.framework"];
    [adSupportBundle load];
    
    if (adSupportBundle == nil) {
        return @"";
    }
    else{
        
        Class asIdentifierMClass = NSClassFromString(@"ASIdentifierManager");
        
        if(asIdentifierMClass == nil){
            return @"";
        }
        else{
            
            //for no arc
            //ASIdentifierManager *asIM = [[[asIdentifierMClass alloc] init] autorelease];
            //for arc
            ASIdentifierManager *asIM = [[asIdentifierMClass alloc] init];
            
            if (asIM == nil) {
                return @"";
            }
            else{
                
                if(asIM.advertisingTrackingEnabled){
                    return [asIM.advertisingIdentifier UUIDString];
                }
                else{
                    return [asIM.advertisingIdentifier UUIDString];
                }
            }
        }
    }
}

- (NSString *) idfvString
{
    if([[UIDevice currentDevice] respondsToSelector:@selector(identifierForVendor)]) {
        return [[UIDevice currentDevice].identifierForVendor UUIDString];
    }
    
    return @"";
}

- (BOOL)isJailbroken
{
    BOOL isbash = NO;
    
    FILE *f = fopen("/bin/bash", "r");
    if (f != NULL)
    {
        //Device is jailbroken
        isbash = YES;
        fclose(f);
    }
    
    return isbash;
}

- (BOOL)isAppSyncExist
{
    BOOL isbash = NO;
    BOOL isappsync = NO;
    FILE *f = fopen("/bin/bash", "r");
    if (f != NULL)
    {
        //Device is jailbroken
        isbash = YES;
        fclose(f);
    }
    
    if (isbash)
    {
        f = fopen("/Library/MobileSubstrate/DynamicLibraries/AppSync.plist", "r");
        if (f != NULL)
        {
            isappsync = YES;
            fclose(f);
        }
        
        if (isappsync == NO)
        {
            NSError *err;
            NSArray *files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:@"/private/var/lib/dpkg/info" error:&err];
            
            for (int i = 0; i < files.count; i++)
            {
                NSString *fname = [files objectAtIndex:i];
                if ([fname rangeOfString:@"appsync" options:NSCaseInsensitiveSearch].location != NSNotFound)
                {
                    isappsync = YES;
                    break;
                }
            }
        }
        
        if (isappsync == NO)
        {
            NSError *err;
            NSArray *files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:@"/var/lib/dpkg/info" error:&err];
            
            for (int i = 0; i < files.count; i++)
            {
                NSString *fname = [files objectAtIndex:i];
                if ([fname rangeOfString:@"appsync" options:NSCaseInsensitiveSearch].location != NSNotFound)
                {
                    isappsync = YES;
                    break;
                }
            }
        }
    }
    else {
        NSLog(@"/bin/bash == NULL,Device is not jailbroken");
    }
    
    return isappsync;
}

// Illicit Bluetooth check -- cannot be used in App Store
/* 
Class  btclass = NSClassFromString(@"GKBluetoothSupport");
if ([btclass respondsToSelector:@selector(bluetoothStatus)])
{
    printf("BTStatus %d\n", ((int)[btclass performSelector:@selector(bluetoothStatus)] & 1) != 0);
    bluetooth = ((int)[btclass performSelector:@selector(bluetoothStatus)] & 1) != 0;
    printf("Bluetooth %s enabled\n", bluetooth ? "is" : "isn't");
}
*/

+ (CGFloat)hardwareNumber:(UIDevicePlatform)hardware {
    CGFloat num = 100.0f;
    switch (hardware) {
        case UIDeviceUnknown:num = 200.0f;break;
            
        case UIDevice1GiPhone:num = 1.1f;break;
        case UIDevice3GiPhone:num = 1.2f;break;
        case UIDevice3GSiPhone:num = 2.1f;break;
        case UIDevice4iPhone:num = 3.1f;break;
        case UIDevice4SiPhone:num = 4.1f;break;
        case UIDevice5iPhone:num = 5.1f;break;
        case UIDevice5CiPhone:num = 5.1f;break;
        case UIDevice5SiPhone:num = 6.1f;break;
        case UIDevice6iPhone:num = 7.1f;break;
        case UIDevice6PlusiPhone:num = 7.2f;break;
        case UIDevice6SiPhone:num = 8.1f;break;
        case UIDevice6SPlusiPhone:num = 8.2f;break;
        case UIDeviceSEiPhone:num = 8.4f;break;
            
        case UIDevice1GiPod:num = 1.1f;break;
        case UIDevice2GiPod:num = 2.1f;break;
        case UIDevice3GiPod:num = 3.1f;break;
        case UIDevice4GiPod:num = 4.1f;break;
        case UIDevice5GiPod:num = 5.1f;break;
        case UIDevice6GiPod:num = 7.1f;break;
            
        case UIDevice1GiPad:num = 1.1f;break;
        case UIDevice2GiPad:num = 2.1f;break;
        case UIDevice3GiPad:num = 3.1f;break;
        case UIDevice4GiPad:num = 3.1f;break;
        case UIDeviceAiriPad:num = 4.1f;break;
        case UIDeviceAir2iPad:num = 5.1f;break;

        case UIDeviceProiPad_9_7:num = 6.4f;break;
        case UIDeviceProiPad_12_9:num = 6.8f;break;

        case UIDevice1GiPadMini:num = 2.1f;break;
        case UIDevice2GiPadMini:num = 4.1f;break;
        case UIDevice3GiPadMini:num = 4.1f;break;
        case UIDevice4GiPadMini:num = 5.1f;break;
            
        default:
            num = 100.0f;
            break;
    }
    return num;
}

- (BOOL) isBetterThanDevice:(UIDevicePlatform) device
{
    UIDeviceCPUPerformanceType curDeviceCPUType = [self deviceCPUType];
    UIDeviceCPUPerformanceType deviceCPUType = [[self class] deviceCPUTypeWithPlatformMTType:device];
    return curDeviceCPUType >= deviceCPUType;
}

- (BOOL) isLessThanDevice:(UIDevicePlatform) device
{
    UIDeviceCPUPerformanceType curDeviceCPUType = [self deviceCPUType];
    UIDeviceCPUPerformanceType deviceCPUType = [[self class] deviceCPUTypeWithPlatformMTType:device];
    return curDeviceCPUType < deviceCPUType;
}

/**
 *  返回当前设备的CPU类型
 *
 *  @return
 */
- (UIDeviceCPUPerformanceType)deviceCPUType {
    
    return [UIDevice deviceCPUTypeWithDevice:[self platform]];
}

+ (UIDeviceCPUPerformanceType)deviceCPUTypeWithPlatformMTType:(UIDevicePlatform)deviceMTType {
    UIDeviceCPUPerformanceType deviceCPUPerformanceType;
    switch (deviceMTType) {
        case UIDevice1GiPhone:
        case UIDevice3GiPhone:
        case UIDevice3GSiPhone:
        case UIDevice1GiPod:
        case UIDevice2GiPod:
        case UIDevice3GiPod:
            deviceCPUPerformanceType = UIDevice_CPU_Samsung;
            break;
        case UIDevice4iPhone:
        case UIDevice1GiPad:
        case UIDevice4GiPod:
        case UIDeviceAppleTV2:
            deviceCPUPerformanceType = UIDevice_CPU_A4;
            break;
        case UIDevice4SiPhone:
        case UIDevice2GiPad:
        case UIDevice1GiPadMini:
        case UIDevice5GiPod:
        case UIDeviceAppleTV3:
            deviceCPUPerformanceType = UIDevice_CPU_A5;
            break;
        case UIDevice3GiPad:
            deviceCPUPerformanceType = UIDevice_CPU_A5X;
            break;
        case UIDevice5iPhone:
        case UIDevice5CiPhone:
            deviceCPUPerformanceType = UIDevice_CPU_A6;
            break;
        case UIDevice4GiPad:
            deviceCPUPerformanceType = UIDevice_CPU_A6X;
            break;
        case UIDevice5SiPhone:
        case UIDeviceAiriPad:
        case UIDevice2GiPadMini:
        case UIDevice3GiPadMini:
            deviceCPUPerformanceType = UIDevice_CPU_A7;
            break;
        case UIDevice6iPhone:
        case UIDevice6PlusiPhone:
        case UIDeviceAppleTV4:
            deviceCPUPerformanceType = UIDevice_CPU_A8;
            break;
        case UIDeviceAir2iPad:
        case UIDevice6GiPod:
            deviceCPUPerformanceType = UIDevice_CPU_A8X;
            break;
        case UIDevice6SiPhone:
        case UIDevice6SPlusiPhone:
            deviceCPUPerformanceType = UIDevice_CPU_A9;
            break;
        case UIDeviceProiPad_9_7:
        case UIDeviceProiPad_12_9:
            deviceCPUPerformanceType = UIDevice_CPU_A9X;
            break;
        case UIDeviceUnknowniPhone:  // 未知iPhone当当前最新UIDevice6SiPhone同级别
            deviceCPUPerformanceType = UIDevice_CPU_A9;
            break;
        case UIDeviceUnknowniPad:   // 未知iPad当当前最新UIDeviceAir2iPad同级别
            deviceCPUPerformanceType = UIDevice_CPU_A9X;
            break;
        case UIDeviceUnknowniPod:   // 未知iPod当当前最新UIDevice6GiPod同级别
            deviceCPUPerformanceType = UIDevice_CPU_A8X;
            break;
        case UIDeviceUnknownAppleTV: // 未知TV当当前最新UIDeviceAppleTV4同级别
            deviceCPUPerformanceType = UIDevice_CPU_A8;
            break;
        default:
            deviceCPUPerformanceType = UIDevice_CPU_Unknown;
            break;
    }
    return deviceCPUPerformanceType;
}

+ (UIDeviceCPUPerformanceType)deviceCPUTypeWithDevice:(NSString *)platform {
    UIDevicePlatform deviceMTType = [self platformMTTypeFor:platform];
    return [self deviceCPUTypeWithPlatformMTType:deviceMTType];
}

@end
