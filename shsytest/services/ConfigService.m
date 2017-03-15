//
//  ConfigService.m
//  shsytest
//
//  Created by jizhai_zl on 2017/2/27.
//  Copyright © 2017年 zl. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ConfigService.h"
#import "SettingService.h"
#import "MMSystemHelper.h"
#import "MMLogger.h"

//#import "MMImageView.h"
//#import "NewsGridItem.h"

#import <CommonCrypto/CommonDigest.h>


ConfigService* configInstance = nil;

@implementation ConfigService



+(ConfigService*) get{
    @synchronized(self){
        if (configInstance == nil){
            configInstance = [ConfigService alloc];
           // [configInstance getGridWidthWithHeight];
        }
    }
    
    return configInstance;
}


//-(NSString*) getCelebCacheFolder{
//    
//    if (self.celebCacheFolderPath == nil){
//        NSArray *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//        NSString *documentPath = [path objectAtIndex:0];
//        NSFileManager *fileMgr = [NSFileManager defaultManager];
//        // create   celebcache folder
//        self.celebCacheFolderPath = [NSString stringWithFormat:@"%@/%@", documentPath, MM_CELEB_CACHE_FOLDER];
//        BOOL isDir = NO;
//        BOOL folderExist = [fileMgr fileExistsAtPath:self.celebCacheFolderPath isDirectory:&isDir];
//        if (!(isDir == YES && folderExist == YES)){
//            NSError* cfError = nil;
//            [fileMgr createDirectoryAtPath:self.celebCacheFolderPath withIntermediateDirectories:YES attributes:nil error:&cfError];
//        }
//    }
//    
//    return self.celebCacheFolderPath;
//}
//-(NSString*) getlaunchFolder{
//    
//    if (self.launchFolderPath == nil){
//        NSArray *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//        NSString *documentPath = [path objectAtIndex:0];
//        NSFileManager *fileMgr = [NSFileManager defaultManager];
//        // create   launch folder
//        self.launchFolderPath = [NSString stringWithFormat:@"%@/%@", documentPath, MM_LAUNCH_FOLDER];
//        BOOL isDir = NO;
//        BOOL folderExist = [fileMgr fileExistsAtPath:self.launchFolderPath isDirectory:&isDir];
//        if (!(isDir == YES && folderExist == YES)){
//            NSError* cfError = nil;
//            [fileMgr createDirectoryAtPath:self.launchFolderPath withIntermediateDirectories:YES attributes:nil error:&cfError];
//        }
//    }
//    
//    return self.launchFolderPath;
//}


-(void) initLocaleConfig{
    
    [self releaseDetailPageHtmlFiles];
}

-(void) copyToLocaleFileSystem: (NSString*) dst
                        fromFile: (NSString*) src{
    if (src == nil || dst == nil)
        return;
    
    NSFileManager *fileMgr = [NSFileManager defaultManager];
    BOOL bRet = [fileMgr fileExistsAtPath:dst];
    if (bRet) {
        NSError *err;
        [fileMgr removeItemAtPath:dst error:&err];
    }
    
    NSData* data = [NSData dataWithContentsOfFile:src];
    //MMLogDebug(@"copy file data %d", data == nil);
    if (data != nil){
        //[fileMgr createFileAtPath:dst contents:nil attributes:nil];
        BOOL ret = [data writeToFile:dst atomically:YES];
        MMLogDebug(@"copy file write data %d", ret);
        //NSFileHandle* fH = [NSFileHandle fileHandleForWritingAtPath:dst];
        //[fH writeData:data];
        //[fH closeFile];
    }
}

-(void) releaseDetailPageHtmlFiles{
    
//    NSArray *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//    NSString *documentPath = [path objectAtIndex:0];
//    
//    NSFileManager *fileMgr = [NSFileManager defaultManager];
//    
//    // create cache folder
//    NSString* cacheFolder = [NSString stringWithFormat:@"%@/%@", documentPath, CACHE_FILES_FOLDER];
//    BOOL isDir = NO;
//    BOOL cacheFolderExist = [fileMgr fileExistsAtPath:cacheFolder isDirectory:&isDir];
//    if (!(isDir == YES && cacheFolderExist == YES)){
//        NSError* cfError = nil;
//        [fileMgr createDirectoryAtPath:cacheFolder withIntermediateDirectories:YES attributes:nil error:&cfError];
//    }
//    
//    // create cache/detail folder
//    NSString* detailFolder = [NSString stringWithFormat:@"%@/%@/%@", documentPath, CACHE_FILES_FOLDER, DETAIL_PAGE_FOLDER];
//    BOOL detailFolderExist = [fileMgr fileExistsAtPath:detailFolder isDirectory:&isDir];
//    if (!(isDir == YES && detailFolderExist == YES)){
//        NSError* cfError = nil;
//        [fileMgr createDirectoryAtPath:detailFolder withIntermediateDirectories:YES attributes:nil error:&cfError];
//    }
//    
//    NSString* zeptoPath = [NSString stringWithFormat:@"%@/%@/%@/zepto.min.js", documentPath, CACHE_FILES_FOLDER, DETAIL_PAGE_FOLDER];
//    NSBundle* bundle = [NSBundle mainBundle];
//    NSString* resZeptoPath = [bundle pathForResource:@"zepto.min" ofType:@"js"];
//    [self copyToLocaleFileSystem:zeptoPath fromFile:resZeptoPath];
//
//    NSString* tempHtmlPath = [NSString stringWithFormat:@"%@/%@/%@/template_regular.html", documentPath, CACHE_FILES_FOLDER, DETAIL_PAGE_FOLDER];
//    NSString* resTempHtmlPath = [bundle pathForResource:@"template_regular" ofType:@"html"];
//    [self copyToLocaleFileSystem:tempHtmlPath fromFile:resTempHtmlPath];
//    
//    NSString* stylePath = [NSString stringWithFormat:@"%@/%@/%@/style.css", documentPath, CACHE_FILES_FOLDER, DETAIL_PAGE_FOLDER];
//    NSString* resStylePath = [bundle pathForResource:@"style" ofType:@"css"];
//    [self copyToLocaleFileSystem:stylePath fromFile:resStylePath];
//    
//    NSString* mainPath = [NSString stringWithFormat:@"%@/%@/%@/main.js", documentPath, CACHE_FILES_FOLDER, DETAIL_PAGE_FOLDER];
//    NSString* resMainPath = [bundle pathForResource:@"main" ofType:@"js"];
//    [self copyToLocaleFileSystem:mainPath fromFile:resMainPath];
//    
//    NSString* js2nPath = [NSString stringWithFormat:@"%@/%@/%@/JSToNativeService.js", documentPath, CACHE_FILES_FOLDER, DETAIL_PAGE_FOLDER];
//    NSString* resJs2NPath = [bundle pathForResource:@"JSToNativeService" ofType:@"js"];
//    [self copyToLocaleFileSystem:js2nPath fromFile:resJs2NPath];
//    
//    NSString* handlebarPath = [NSString stringWithFormat:@"%@/%@/%@/handlebars-v2.0.0.js", documentPath, CACHE_FILES_FOLDER, DETAIL_PAGE_FOLDER];
//    NSString* resHandlebarPath = [bundle pathForResource:@"handlebars-v2.0.0" ofType:@"js"];
//    [self copyToLocaleFileSystem:handlebarPath fromFile:resHandlebarPath];
//    
//    NSString* flipsnapPath = [NSString stringWithFormat:@"%@/%@/%@/flipsnap.js", documentPath, CACHE_FILES_FOLDER, DETAIL_PAGE_FOLDER];
//    NSString* resFlipsnapPath = [bundle pathForResource:@"flipsnap" ofType:@"js"];
//    [self copyToLocaleFileSystem:flipsnapPath fromFile:resFlipsnapPath];
//    
//    // ad.png
//    NSString* tempAdPath = [NSString stringWithFormat:@"%@/%@/%@/ad.png", documentPath, CACHE_FILES_FOLDER, DETAIL_PAGE_FOLDER];
//    NSString* resAdPath = [bundle pathForResource:@"ad" ofType:@"png"];
//    [self copyToLocaleFileSystem:tempAdPath fromFile:resAdPath];
//    
//    // create cache/detail/temp folder
//    NSString* detailTempFolder = [NSString stringWithFormat:@"%@/%@/%@/temp", documentPath, CACHE_FILES_FOLDER, DETAIL_PAGE_FOLDER];
//    BOOL detailTempFolderExist = [fileMgr fileExistsAtPath:detailTempFolder isDirectory:&isDir];
//    if (!(isDir == YES && detailTempFolderExist == YES)){
//        NSError* cfError = nil;
//        [fileMgr createDirectoryAtPath:detailTempFolder withIntermediateDirectories:YES attributes:nil error:&cfError];
//    }
}

//-(NSString*) getImageCacheFolder{
//    NSArray *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//    NSString *documentPath = [path objectAtIndex:0];
//    NSFileManager *fileMgr = [NSFileManager defaultManager];
//    
//    // create mmimage cache folder
//    NSString* mmimageCacheFolder = [NSString stringWithFormat:@"%@/%@", documentPath, MM_WEB_IMAGE_CACHE_FOLDER];
//    BOOL isDir = NO;
//    BOOL folderExist = [fileMgr fileExistsAtPath:mmimageCacheFolder isDirectory:&isDir];
//    if (!(isDir == YES && folderExist == YES)){
//        NSError* cfError = nil;
//        [fileMgr createDirectoryAtPath:mmimageCacheFolder withIntermediateDirectories:YES attributes:nil error:&cfError];
//    }
//    
//    return mmimageCacheFolder;
//}
//- (NSString *)cachedFileNameForKey:(NSString *)key {
//    const char *str = [key UTF8String];
//    if (str == NULL) {
//        str = "";
//    }
//    unsigned char r[CC_MD5_DIGEST_LENGTH];
//    CC_MD5(str, (CC_LONG)strlen(str), r);
//    NSString *filename = [NSString stringWithFormat:@"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
//                          r[0], r[1], r[2], r[3], r[4], r[5], r[6], r[7], r[8], r[9], r[10], r[11], r[12], r[13], r[14], r[15]];
//    
//    return filename;
//}
@end
