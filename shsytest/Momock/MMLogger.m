//
//  Logger.m
//  momock
//
//  Created by apple on 15/3/11.
//  Copyright (c) 2015年 Gmobi. All rights reserved.
//

#import "MMLogger.h"
#import <stdlib.h>

static MMLogger *instance;

@implementation MMLogger

@synthesize debug;
@synthesize logFileHdl;
@synthesize writerBuf;
@synthesize level;
@synthesize appName;
@synthesize logName;

+(void)openLog: (NSString*) file
      logLevel: (int) plevel
   maxLogCount: (int) maxLogFile{
    @synchronized(self){
        if (instance == nil){
            instance = [MMLogger alloc];
            
            instance.logName = [[NSString alloc] initWithString:file];
            
            NSString* currentDate;
            NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
            [formatter setDateFormat:@"YYYYMMddhhmmss"];
            currentDate = [formatter stringFromDate:[NSDate date]];
            
            NSArray *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *documentPath = [path objectAtIndex:0];
            
            NSFileManager *fileMgr = [NSFileManager defaultManager];
            
            // create MMlogs folder
            NSString* logsFolder = [NSString stringWithFormat:@"%@/MMlogs", documentPath];
            BOOL isDir = NO;
            BOOL logsFolderExist = [fileMgr fileExistsAtPath:logsFolder isDirectory:&isDir];
            if (!(isDir == YES && logsFolderExist == YES)){
                NSError* cfError = nil;
                [fileMgr createDirectoryAtPath:logsFolder withIntermediateDirectories:YES attributes:nil error:&cfError];
            }
            
            NSString* logPath = [NSString stringWithFormat:@"%@/MMlogs/%@[%@].log", documentPath, instance.logName, currentDate];
            
            
            BOOL bRet = [fileMgr fileExistsAtPath:logPath];
            if (bRet) {
                NSError *err;
                [fileMgr removeItemAtPath:logPath error:&err];
            }
            
            NSMutableArray *fileLogs = [NSMutableArray arrayWithCapacity:maxLogFile+1];
            NSArray *tmpList = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:documentPath error:nil];
            
            for (NSString *fileName in tmpList){
                NSString* fullPath = [documentPath stringByAppendingFormat:@"/%@" ,fileName];
                if ([self isFileExistAtPath:fullPath]){
                    if ([[fileName pathExtension] isEqualToString:@"MMlogs"]){
                        [fileLogs addObject:fullPath];
                    }
                }
            }
            
            NSArray* sortedLogFiles = [fileLogs sortedArrayUsingSelector:@selector(compare:)];
            int sortedLogFilesCount = (int)sortedLogFiles.count - maxLogFile + 1;
            for (int i = 0; i < sortedLogFilesCount; i++){
                NSString* expiredLog = [sortedLogFiles objectAtIndex:i];
                if (expiredLog != nil){
                    NSError *err1;
                    [fileMgr removeItemAtPath:expiredLog error:&err1];
                }
            }
            
            instance.level = plevel;
            
            [fileMgr createFileAtPath:logPath contents:nil attributes:nil];
            
            instance.logFileHdl = [NSFileHandle fileHandleForWritingAtPath:logPath];
            
            instance.writerBuf = [[NSMutableData alloc] init];
            
            [instance.logFileHdl writeData:[@"========log start========\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
            
            [instance startLogThread];
        }
    }
}

+(BOOL)isFileExistAtPath: (NSString*) fileFullPath{
    BOOL isExist = NO;
    isExist = [[NSFileManager defaultManager] fileExistsAtPath:fileFullPath];
    return isExist;
}

+(void)closeLog{
    
}

-(void)startLogThread{
    NSThread* logThread = [[NSThread alloc] initWithTarget:self
                                                  selector:@selector(flushLogBufToFile)
                                                    object:nil];
    [logThread start];
}

-(void)flushLogBufToFile{
    while (YES) {
        if (!instance || !(instance.writerBuf) || !(instance.logFileHdl))
            break;
        
        if ([instance.writerBuf length] > 0){
            [instance.logFileHdl writeData:instance.writerBuf];
            [instance resetWriteBuf];
        }
        
        [NSThread sleepForTimeInterval:5];
    }
}

-(void)resetWriteBuf{
    if (instance && instance.writerBuf){
        [instance.writerBuf resetBytesInRange:NSMakeRange(0, [instance.writerBuf length])];
        [instance.writerBuf setLength:0];
    }
}

void writeLog(const char* file, int line,const char* func, NSString* slevel, int ilevel ,NSString* fmt, ...){
    @try {
        if (instance){
            if (ilevel < instance.level)
                return;
            
            va_list args;
            va_start(args, fmt);
            NSString* str = [[NSString alloc] initWithFormat:fmt arguments:args];
            //NSLogv(fmt, args);
            va_end(args);
            
            NSLog(@"%@", str);
            
            NSString* currentDate;
            NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
            [formatter setDateFormat:@"YYYY-MM-dd hh:mm:ss.SSS"];
            currentDate = [formatter stringFromDate:[NSDate date]];
            
            NSString* logStr = [[NSString alloc] initWithFormat:@"%@ [%@] %s %s %d : %@\r\n", currentDate, slevel, file, func, line, str];
            NSData *wLogData = [logStr dataUsingEncoding:NSUTF8StringEncoding];
            [instance.writerBuf appendData:wLogData];
            
            if (instance && [instance.writerBuf length] > 2048){
                [instance.logFileHdl writeData:instance.writerBuf];
                [instance resetWriteBuf];
            }
        }
    }
    @catch (NSException *exception) {
        
    }
}


@end

