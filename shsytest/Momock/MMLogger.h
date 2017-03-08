//
//  Logger.h
//  momock
//
//  Created by apple on 15/3/11.
//  Copyright (c) 2015年 Gmobi. All rights reserved.
//


#ifndef momock_Logger_h
#define momock_Logger_h

#import <Foundation/Foundation.h>

#define MM_LOG_LEVEL_DEBUG @"Debug"
#define MM_LOG_LEVEL_INFO @"Info"
#define MM_LOG_LEVEL_WARN @"Warn"
#define MM_LOG_LEVEL_ERROR @"Error"

#define MM_LOG_I_LEVEL_ALL     0
#define MM_LOG_I_LEVEL_DEBUG   3
#define MM_LOG_I_LEVEL_INFO    4
#define MM_LOG_I_LEVEL_WARN    5
#define MM_LOG_I_LEVEL_ERROR   6
#define MM_LOG_I_LEVEL_NONE    7


#define MMLogDebug(format,...) writeLog(__FILE__,__LINE__,__FUNCTION__,MM_LOG_LEVEL_DEBUG, MM_LOG_I_LEVEL_DEBUG,format,##__VA_ARGS__);
#define MMLogInfo(format,...) writeLog(__FILE__,__LINE__,__FUNCTION__,MM_LOG_LEVEL_INFO, MM_LOG_I_LEVEL_INFO,format,##__VA_ARGS__);
#define MMLogWarn(format,...) writeLog(__FILE__,__LINE__,__FUNCTION__,MM_LOG_LEVEL_WARN,MM_LOG_I_LEVEL_WARN,format,##__VA_ARGS__);
#define MMLogError(format,...) writeLog(__FILE__,__LINE__,__FUNCTION__,MM_LOG_LEVEL_ERROR,MM_LOG_I_LEVEL_ERROR,format,##__VA_ARGS__);


@interface MMLogger : NSObject{
    BOOL debug;
    NSFileHandle *logFileHdl;
    NSMutableData *writerBuf;
    int level;
    NSString *logName;
    NSString *appName;
}

+(void)openLog: (NSString*) file
      logLevel: (int) plevel
   maxLogCount: (int) maxLogFile;

@property BOOL debug;
@property NSFileHandle *logFileHdl;
@property NSMutableData *writerBuf;
@property int level;
@property NSString* logName;
@property NSString* appName;

void writeLog(const char* file, int line,const char* func, NSString* slevel, int ilevel ,NSString* fmt, ...);

@end

#endif
