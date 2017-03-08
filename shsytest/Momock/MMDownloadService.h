//
//  MMDownloadService.h
//  PoPoNews
//
//  Created by apple on 15/5/13.
//  Copyright (c) 2015年 Gmobi. All rights reserved.
//

#ifndef PoPoNews_MMDownloadService_h
#define PoPoNews_MMDownloadService_h

#import <Foundation/Foundation.h>
#import "MMHttpSession.h"


#define DOWNLOAD_FAILED  0
#define DOWNLOAD_SUCCESS 1

#define MAX_DOWNLOADING_ITEM 30

#define SERVICE_STATUS_INIT 0
#define SERVICE_STATUS_RUNNING 1
#define SERVICE_STATUS_PAUSE 2
#define SERVICE_STATUS_STOP 3

#define DOWNLOAD_SERVICE_STATUS_WAITING 0
#define DOWNLOAD_SERVICE_STATUS_DOWNLOADING 1
#define DOWNLOAD_SERVICE_STATUS_FINISH_SUCC 2
#define DOWNLOAD_SERVICE_STATUS_FINISH_FAIL 3

typedef void (^MMDownloadCallback)(int status, NSDictionary* resultData);
typedef void (^MMDownloadProgressCallback)(double progress);

@interface MMDownloadItem : NSObject

@property (retain) MMHttpSession* session;
@property (copy) NSString* url;
@property (copy) NSMutableDictionary* header;
@property (copy) NSString* localUri;
@property (strong) MMDownloadCallback callback;
@property (strong) MMDownloadProgressCallback cbProgress;
@property (assign) BOOL wifiOnly;
@property (assign) int status;

@end

@interface MMDownloadService : NSObject

@property NSMutableArray* downloadingList;
@property NSMutableArray* waitingList;
@property BOOL isDownloadRunning;
@property int serviceStatus;

+(MMDownloadService*) getInstance;

-(void) stopService;
-(void) startService;
-(void) pauseService;

-(void) download: (MMDownloadItem*) item;

-(void) download: (NSString*) url
            reqHeader: (NSMutableDictionary*) header
             filePath: (NSString*) file
             wifiOnly: (BOOL) wifi
             callback: (MMDownloadCallback) cb
     progressCallback: (MMDownloadProgressCallback) proCb;

@end

#endif
