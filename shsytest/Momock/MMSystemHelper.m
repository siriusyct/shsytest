//
//  SystemHelper.m
//  PoPoNews
//
//  Created by apple on 15/4/1.
//  Copyright (c) 2015年 Gmobi. All rights reserved.
//
#import "sys/utsname.h"
#import <Foundation/Foundation.h>
#import <AdSupport/AdSupport.h>
#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonHMAC.h>
#import <netdb.h>
#import <arpa/inet.h>
#import "MMSystemHelper.h"
#import "ITSApplication.h"

static NetWorkType currentNetType = NoNet;

@implementation MMStoreKitController

-(void) openAppStore: (NSString*) appId{
    SKStoreProductViewController* storeP = [[SKStoreProductViewController alloc] init];
    storeP.delegate = self;
    [storeP loadProductWithParameters:@{SKStoreProductParameterITunesItemIdentifier: appId} completionBlock:^(BOOL result, NSError * _Nullable error) {
        
        if (error == nil){
            [self presentViewController:storeP animated:YES completion:^{
                
            }];
        }
    }];
}

-(void) productViewControllerDidFinish:(SKStoreProductViewController *)viewController{
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

@end

@implementation MMSystemHelper

+(CGFloat) getScreenScale{
    return [UIScreen mainScreen].scale;
}

+(CGFloat) getScreenWidth{
    CGRect rect = [[UIScreen mainScreen] bounds];
    CGSize sSize = rect.size;
    CGFloat width = sSize.width;
    
    return width;
}

+(CGFloat) getScreenHeight{
    CGRect rect = [[UIScreen mainScreen] bounds];
    CGSize sSize = rect.size;
    
    CGFloat height = sSize.height;
    
    return height;
}

+(CGFloat) getStatusBarHeight{
    //CGRect statusBarRect = [[UIApplication sharedApplication] statusBarFrame];
    //CGSize sStatusBar = statusBarRect.size;
    //CGFloat barHeight = sStatusBar.height;
    
    //return barHeight;
    
    return 20;
}


+(NSString*) getAppVersion{
    NSString* appVer = @"";
    NSDictionary* infoDictionary = [[NSBundle mainBundle] infoDictionary];
    if (infoDictionary != nil)
        appVer = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
        
    return appVer;
}

+(NSString*) getIdForVendor{
#if __IPHONE_OS_VERSION_MIN_REQUIRED >= 60000
    // iOS 6.0 or later
    NSString* DeviceID = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
#else
    // iOS 5.X or earlier
    NSString* DeviceID = [[UIDevice currentDevice] uniqueIdentifier];
#endif

    return DeviceID;
}

+(NSString*) getIdForAD{
//    NSString* adId = [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
//    return adId;
    return @"";
}

+(NSString*) getUA {
    struct utsname systemInfo;
    
    uname(&systemInfo);
    
    //get the device model
    
    NSString *model = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
    
    //NSString *version =    [[UIDevice currentDevice] systemVersion];
    
    NSString *ua = [NSString stringWithFormat:@"ios;MANUFACTURER/APPLE;MODEL/%@;BOARD/APPLE;BRAND/APPLE;DEVICE/APPLE;HARDWARE/APPLE;PRODUCT/APPLE", model];
    
    return ua;
}

+(NSString*) getOSVersion {
    struct utsname systemInfo;
    
    uname(&systemInfo);
    
    //get the device model
    NSString *version = [[UIDevice currentDevice] systemVersion];
    
    return version;
}

+(NSString*) getTimeStamp{
    //NSDate *localDate = [NSDate date];
    //NSString *timeSp = [NSString stringWithFormat:@"%ld", (long)[localDate timeIntervalSince1970]];
    UInt64 dTime = [self getMillisecondTimestamp];
    NSString *timeSp = [NSString stringWithFormat:@"%llu", dTime];
    return timeSp;
}

+(NSString*) getTimeStampSeconds{
    NSDate *localDate = [NSDate date];
    NSString *timeSp = [NSString stringWithFormat:@"%ld", (long)[localDate timeIntervalSince1970]];
    return timeSp;
}

+(UInt64) getMillisecondTimestamp{
    NSDate *localDate = [NSDate date];
    NSTimeInterval dTime = [localDate timeIntervalSince1970];
    UInt64 timeSp = dTime * 1000;
    return timeSp;
}

+(NSString*) getLanguage{
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    NSArray* allLangs = [defaults objectForKey:@"AppleLanguages"];
    NSString* lang = [allLangs objectAtIndex:0];
    return lang;
}

+(NSString*) getCountry{
    NSLocale* currentLocale = [NSLocale currentLocale];
    NSString* country = [currentLocale objectForKey:NSLocaleCountryCode];
    return country;
}

+(NSString*) getAppPackageId{
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString* appIdentifier = [infoDictionary objectForKey:@"CFBundleIdentifier"];
    return appIdentifier;
}

+(UIColor *) string2UIColor:(NSString *)str
{
    if (!str || [str isEqualToString:@""]) {
        return nil;
    }
    unsigned red,green,blue;
    NSRange range;
    unsigned alpha = 255.0f;
    int alphaLen = 0;
    range.length = 2;
    
    
    if (str.length > 8){
        alphaLen = 2;
        range.location = 1;
        [[NSScanner scannerWithString:[str substringWithRange:range]] scanHexInt:&alpha];
    }
    
    range.location = 1 + alphaLen;
    [[NSScanner scannerWithString:[str substringWithRange:range]] scanHexInt:&red];
    range.location = 3 + alphaLen;
    [[NSScanner scannerWithString:[str substringWithRange:range]] scanHexInt:&green];
    range.location = 5 + alphaLen;
    [[NSScanner scannerWithString:[str substringWithRange:range]] scanHexInt:&blue];
    UIColor *color= [UIColor colorWithRed:red/255.0f green:green/255.0f blue:blue/255.0f alpha:alpha/255.0f];
    
    return color;
}

+(void) startCheckNetworkType{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(checkNetworkStatus:)
                                                 name:kReachabilityChangedNotification object:nil];
    Reachability *NetReachable = [Reachability reachabilityWithHostName:@"www.baidu.com"];
    [NetReachable startNotifier];
}

+(void) stopCheckNetworkType{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kReachabilityChangedNotification object:nil];
}

+(void) checkNetworkStatus:(NSNotification *)not
{
    Reachability *NetReachable = not.object;
    NetworkStatus NetStatus = [NetReachable currentReachabilityStatus];
    switch (NetStatus) {
        case NotReachable:
        {
            currentNetType = NoNet;
        }
            break;
        case ReachableViaWiFi:
        {
            currentNetType = WifiNet;
        }
            break;
        case ReachableViaWWAN:
        {
            currentNetType = OtherNet;
        }
            break;
        default:
            break;
    }
}

+(NetWorkType) getNetworkType{
    return currentNetType;
}

//URLEncode
+(NSString*)encodeString:(NSString*)unencodedString{
    
    // CharactersToBeEscaped = @":&=;+!@#$()~',*";
    // CharactersToLeaveUnescaped = @"[].";
    
    NSString *encodedString = (NSString *)
    CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                              (CFStringRef)unencodedString,
                                                              NULL,
                                                              (CFStringRef)@"!*'();:@&=+$,%#[]",
                                                              kCFStringEncodingUTF8));
    
    return encodedString;
}

//URLDEcode
+(NSString *)decodeString:(NSString*)encodedString

{
    //NSString *decodedString = [encodedString stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding ];
    NSString *decodedString  = (__bridge_transfer NSString *)CFURLCreateStringByReplacingPercentEscapesUsingEncoding(NULL, (__bridge CFStringRef)encodedString, CFSTR(""),
        CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding));
    return decodedString;
}

+(NSString*) dateFormatStr: (long) time
                   format: (NSString*) uFormat{
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    if (uFormat != nil)
        [dateFormatter setDateFormat:uFormat];
    else
        [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSDate* confromTimeSp = [NSDate dateWithTimeIntervalSince1970:time];
    NSString* currentDateStr = [dateFormatter stringFromDate:confromTimeSp];
    
    return currentDateStr;
}


+(long) fileSizeForDir:(NSString*)path
{
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    long size = 0;
    NSArray* array = [fileManager contentsOfDirectoryAtPath:path error:nil];
    for(int i = 0; i<[array count]; i++)
    {
        NSString *fullPath = [path stringByAppendingPathComponent:[array objectAtIndex:i]];
        
        BOOL isDir;
        if ( !([fileManager fileExistsAtPath:fullPath isDirectory:&isDir] && isDir) )
        {
            NSDictionary *fileAttributeDic=[fileManager attributesOfItemAtPath:fullPath error:nil];
            size += fileAttributeDic.fileSize;
        }
        else
        {
            size += [self fileSizeForDir:fullPath];
        }
    }
    return size;
}


+(void) removeFileForDir:(NSString*)path
{
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    NSArray* array = [fileManager contentsOfDirectoryAtPath:path error:nil];
    for(int i = 0; i<[array count]; i++)
    {
        NSString *fullPath = [path stringByAppendingPathComponent:[array objectAtIndex:i]];
        
        BOOL isDir;
        if ( !([fileManager fileExistsAtPath:fullPath isDirectory:&isDir] && isDir) )
        {
            NSError *err;
            [fileManager removeItemAtPath:fullPath error:&err];
            NSLog(@"remove file ret %@", err);
        }
        else
        {
            [self removeFileForDir:fullPath];
            NSError *err;
            [fileManager removeItemAtPath:fullPath error:&err];
            NSLog(@"remove file ret %@", err);
        }
    }
}

+(BOOL) isConnectedToNetwork
{
    // Create zero addy
    struct sockaddr_in zeroAddress;
    bzero(&zeroAddress, sizeof(zeroAddress));
    zeroAddress.sin_len = sizeof(zeroAddress);
    zeroAddress.sin_family = AF_INET;
    
    // Recover reachability flags
    SCNetworkReachabilityRef defaultRouteReachability = SCNetworkReachabilityCreateWithAddress(NULL, (struct sockaddr *)&zeroAddress);
    SCNetworkReachabilityFlags flags;
    
    BOOL didRetrieveFlags = SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags);
    CFRelease(defaultRouteReachability);
    
    if (!didRetrieveFlags)
    {
        printf("Error. Could not recover network reachability flags\n");
        return NO;
    }
    
    BOOL isReachable = ((flags & kSCNetworkFlagsReachable) != 0);
    BOOL needsConnection = ((flags & kSCNetworkFlagsConnectionRequired) != 0);
    return (isReachable && !needsConnection) ? YES : NO;
}
//+(CGSize)sizeWithString:(NSString *)str font:(UIFont *)font maxSize:(CGSize)maxSize
//{
//    NSDictionary *dict = @{NSFontAttributeName : font};
//    // 如果将来计算的文字的范围超出了指定的范围,返回的就是指定的范围
//    // 如果将来计算的文字的范围小于指定的范围, 返回的就是真实的范围
//    CGSize size = [str boundingRectWithSize:maxSize options:NSStringDrawingUsesLineFragmentOrigin attributes:dict context:nil].size;
//    return size;
//}

//动态 计算行高
//根据字符串的实际内容的多少 在固定的宽度和字体的大小，动态的计算出实际的高度
+ (CGFloat)textHeightFromTextString:(NSString *)text width:(CGFloat)textWidth fontSize:(CGFloat)size{
    
    if ([MMSystemHelper getCurrentIOS] >= 7.0) {
        //iOS7之后
        /*
         第一个参数: 预设空间 宽度固定  高度预设 一个最大值
         第二个参数: 行间距 如果超出范围是否截断
         第三个参数: 属性字典 可以设置字体大小
         */
        NSDictionary *dict = @{NSFontAttributeName:[UIFont systemFontOfSize:size]};
        CGRect rect = [text boundingRectWithSize:CGSizeMake(textWidth, MAXFLOAT) options:NSStringDrawingTruncatesLastVisibleLine|NSStringDrawingUsesFontLeading|NSStringDrawingUsesLineFragmentOrigin attributes:dict context:nil];
        //返回计算出的行高
        return rect.size.height;
        
    }else {
        //iOS7之前
        /*
         1.第一个参数  设置的字体固定大小
         2.预设 宽度和高度 宽度是固定的 高度一般写成最大值
         3.换行模式 字符换行
         */
        CGSize textSize = [text sizeWithFont:[UIFont systemFontOfSize:size] constrainedToSize:CGSizeMake(textWidth, MAXFLOAT) lineBreakMode:NSLineBreakByCharWrapping];
        return textSize.height;//返回 计算出得行高
    }
    
}
//获取iOS版本号
+ (double)getCurrentIOS {
    return [[[UIDevice currentDevice] systemVersion] doubleValue];
}

+(NSString *) getMd5String:(NSString *)src{
    if (src == nil)
        return nil;
    
    const char *cStr = [src UTF8String];
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    //CC_MD5( cStr, strlen(cStr), digest );
    CC_MD5( cStr, (uint32_t)src.length, digest );
    NSMutableString *result = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
        [result appendFormat:@"%02x", digest[i]];
    
    return result;
}


+(NSString*) gb2312ToUTF8:(NSData *) data{
    NSStringEncoding enc = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
    NSString *retStr = [[NSString  alloc] initWithData:data  encoding:enc];
    
    return retStr;
}

+(void) openSystemWebUrl: (NSString*) url{
    if (url == nil) return;
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
}

+(id) getAppInfoPlistData: (NSString*) key
                 defValue: (id) value{
    id ret = value;
    NSString* infoFile = [[NSBundle mainBundle] pathForResource:@"Info" ofType:@"plist"];
    NSMutableDictionary* dict = [[NSMutableDictionary alloc] initWithContentsOfFile:infoFile];
    if (dict != nil){
        id tmp = [dict objectForKey:key];
        if (tmp != nil)
            ret = tmp;
    }
    
    return ret;
}

+(NSString*) getAdvertisingID{
    //return [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
    return @"";
}


+(NSString*) getVendorID{
    return [[[UIDevice currentDevice] identifierForVendor] UUIDString];
}

+(NSString*) getMMCacheFolder{
    NSArray *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentPath = [path objectAtIndex:0];
    
    NSFileManager *fileMgr = [NSFileManager defaultManager];
    
    // create MMCache folder
    NSString* cacheFolder = [NSString stringWithFormat:@"%@/MMCaches", documentPath];
    BOOL isDir = NO;
    BOOL cacheFolderExist = [fileMgr fileExistsAtPath:cacheFolder isDirectory:&isDir];
    if (!(isDir == YES && cacheFolderExist == YES)){
        NSError* cfError = nil;
        [fileMgr createDirectoryAtPath:cacheFolder withIntermediateDirectories:YES attributes:nil error:&cfError];
    }
    
    return cacheFolder;
}

+(NSString*) DictTOjsonString:(id)object {
    if (object == nil) return nil;
    NSString *jsonString = nil;
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:object
                                                       options:NSJSONWritingPrettyPrinted // Pass 0 if you don't care about the readability of the generated string
                                                         error:&error];
    if (! jsonData) {
        NSLog(@"Got an error: %@", error);
    } else {
        jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    return jsonString;
}

+(void) openAppStore: (NSString*) appId{
    if (appId == nil) return;
    MMStoreKitController* mmStore = [[MMStoreKitController alloc] init];
    [mmStore openAppStore:appId];
}

+(void) openAppStoreByWeb: (NSString*) appId{
    if (appId == nil) return;
    NSString* url = [NSString stringWithFormat:@"itms-apps://itunes.apple.com/app/id%@?mt=8", appId];
    [self openSystemWebUrl:url];
}

+(int) minInt: (int) i1
           i2: (int) i2{
    int min = i1;
    if (i2 < min)
        min = i2;
    return min;
}

+(int) maxInt: (int) i1
           i2: (int) i2{
    int max = i1;
    if (i2 > max)
        max = i2;
    return max;
}

+(UIViewController*) getCurrentVC
{
    UIViewController *result = nil;
    
    UIWindow * window = [[UIApplication sharedApplication] keyWindow];
    if (window.windowLevel != UIWindowLevelNormal)
    {
        NSArray *windows = [[UIApplication sharedApplication] windows];
        for(UIWindow * tmpWin in windows)
        {
            if (tmpWin.windowLevel == UIWindowLevelNormal)
            {
                window = tmpWin;
                break;
            }
        }
    }
    
    UIView *frontView = [[window subviews] objectAtIndex:0];
    id nextResponder = [frontView nextResponder];
    
    if ([nextResponder isKindOfClass:[UIViewController class]])
        result = nextResponder;
    else
        result = window.rootViewController;
    
    return result;
}


+(BOOL) currentVCIsPortrait{
    UIViewController* vc = [self getCurrentVC];
    if (vc == nil) return YES;
    if (vc.interfaceOrientation == UIDeviceOrientationUnknown ||
        vc.interfaceOrientation == UIDeviceOrientationPortrait ||
        vc.interfaceOrientation == UIDeviceOrientationPortraitUpsideDown)
        return YES;
    else
        return NO;
}


/*  计算文本的高
 @param str   需要计算的文本
 @param font  文本显示的字体
 @param maxSize 文本显示的范围，可以理解为limit
 
 @return 文本占用的真实宽高
 */

+(CGSize)sizeWithString:(NSString *)str font:(UIFont *)font maxSize:(CGSize)maxSize
{
    NSDictionary *dict = @{NSFontAttributeName : font};
    // 如果将来计算的文字的范围超出了指定的范围,返回的就是指定的范围
    // 如果将来计算的文字的范围小于指定的范围, 返回的就是真实的范围
    CGSize size = [str boundingRectWithSize:maxSize options:NSStringDrawingUsesLineFragmentOrigin attributes:dict context:nil].size;
    return size;
}


+ (NSString *) compareCurrentTime:(NSString *)str
{
    long long longTime = [str longLongValue];
    
    NSDate *d = [[NSDate alloc]initWithTimeIntervalSince1970:longTime/1000.0];
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *timeString = [formatter stringFromDate:d];
    
    //把字符串转为NSdate
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *timeDate = [dateFormatter dateFromString:timeString];
    
    //得到与当前时间差
    NSTimeInterval  timeInterval = [timeDate timeIntervalSinceNow];
    timeInterval = -timeInterval;
    //标准时间和北京时间差8个小时
    //    timeInterval = timeInterval - 8*60*60;
    int temp = 0;
    NSString *result;
    NSArray *time = [timeString componentsSeparatedByString:@" "];
    if (timeInterval < 60) {
        result = NSLocalizedString (@"time_util_just", nil);
    }
    else if((temp = timeInterval/60) < 60){
        result = [NSString stringWithFormat:@"%d%@",temp,NSLocalizedString(@"time_util_minutes", nil)];
    }
    
    else if((temp = temp/60) < 24){
        result = [NSString stringWithFormat:@"%d%@",temp,NSLocalizedString(@"time_util_hour", nil)];
    }
    
    else if((temp = temp/24) < 30){
        if (temp <= 2) {
            result = [NSString stringWithFormat:@"%@",[time objectAtIndex:0]];
            //            if (temp == 1) {
            //                result = [NSString stringWithFormat:@"%@",PPN_NSLocalizedString(@"time_util_yesterday", nil)];
            //            }else{
            //                result = [NSString stringWithFormat:@"%@",PPN_NSLocalizedString(@"time_util_before_yesterday", nil)];
            //            }
        }else{
            result = [NSString stringWithFormat:@"%@",[time objectAtIndex:0]];
        }
    }
    
    else if((temp = temp/30) < 12){
        result = [NSString stringWithFormat:@"%@",[time objectAtIndex:0]];
        //        result = [NSString stringWithFormat:@"%d月前",temp];
    }
    else{
        temp = temp/12;
        //        result = [NSString stringWithFormat:@"%d年前",temp];
        result = [NSString stringWithFormat:@"%@",[time objectAtIndex:0]];
    }
    return  result;
    
}
//判断是否全是空格

+ (BOOL) isEmpty:(NSString *) str {
    
    if (!str) {
        return true;
    } else {
        
        NSCharacterSet *set = [NSCharacterSet whitespaceAndNewlineCharacterSet];
        NSString *trimedString = [str stringByTrimmingCharactersInSet:set];
        
        if ([trimedString length] == 0) {
            return true;
        } else {
            return false;
        }
    }
}
+(BOOL) writeImage:(UIImage*)image toFileAtPath:(NSString*)aPath
{
    if ((image == nil) || (aPath == nil) || ([aPath isEqualToString:@""]))
        return NO;
    
    @try {
        NSData *imageData = nil;
        NSString *ext = [aPath pathExtension];
        if ([ext isEqualToString:@"png"]) {
            imageData = UIImagePNGRepresentation(image);
        } else {
            // the rest, we write to jpeg
            // 0. best, 1. lost. about compress.
            imageData = UIImageJPEGRepresentation(image, 1);
        }
        if ((imageData == nil) || ([imageData length] <= 0))
            return NO;
        [imageData writeToFile:aPath atomically:YES];
        return YES;
    } @catch (NSException *e){
        NSLog(@"create thumbnail exception.");
    }

    return NO;
}
//判断当前字符串是否包含网址链接,是则返回网址所在的NSRange,这样可以相应的操作(NSAttributedString去设置高亮等等)
+ (NSRange)getRangeOfEmailAddress:(NSString *)email
{
    NSString *re = @"/^(http|https)://([\\w-]+\\.)+[\\w-]+(/[\\w-./?%&=]*)?$/";
    NSRange range = [email rangeOfString:re options:NSRegularExpressionSearch];
    if (range.location != NSNotFound) {
        return range;
    }
    else {
        return NSMakeRange(0, 0);
    }
}
@end