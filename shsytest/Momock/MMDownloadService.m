//
//  MMDownloadService.m
//  PoPoNews
//
//  Created by apple on 15/5/13.
//  Copyright (c) 2015年 Gmobi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MMDownloadService.h"
#import "MMLogger.h"

static MMDownloadService* dsInstance = nil;

@implementation MMDownloadItem


@end


@implementation MMDownloadService

+(MMDownloadService*) getInstance{
    @synchronized(self){
        if (dsInstance == nil){
            dsInstance = [MMDownloadService alloc];
            dsInstance.downloadingList = [[NSMutableArray alloc] initWithCapacity:1];
            dsInstance.waitingList = [[NSMutableArray alloc] initWithCapacity:1];
            dsInstance.isDownloadRunning = NO;
            dsInstance.serviceStatus = SERVICE_STATUS_INIT;
        }
    }
    return dsInstance;
}

-(void) runningDownload{
    while (YES) {
        if (!dsInstance || !(dsInstance.downloadingList) || !(dsInstance.waitingList)){
            dsInstance.isDownloadRunning = NO;
            MMLogDebug(@"Download service stop 1");
            return;
        }
        
        if (dsInstance.serviceStatus == SERVICE_STATUS_PAUSE || dsInstance.serviceStatus == SERVICE_STATUS_STOP){
            dsInstance.isDownloadRunning = NO;
            MMLogDebug(@"Download service stop 2");
            return;
        }
        
        NSUInteger downloadTotalCount = [dsInstance.downloadingList count];
        for (int i = 0; i < downloadTotalCount; i++) {
            MMDownloadItem* item = [dsInstance.downloadingList objectAtIndex:i];
            if (DOWNLOAD_SERVICE_STATUS_FINISH_SUCC == item.status || DOWNLOAD_SERVICE_STATUS_FINISH_FAIL == item.status){
                [dsInstance.downloadingList removeObjectAtIndex:i];
                i--;
                downloadTotalCount--;
            }
        }
        
        NSUInteger downloadCount = [dsInstance.downloadingList count];
        if (downloadCount < 30) {
            NSUInteger waitingCount = [dsInstance.waitingList count];
            if (waitingCount <= 0 && downloadCount <= 0){
                dsInstance.isDownloadRunning = NO;
                MMLogDebug(@"Download service stop 3");
                return;
            }
            
            if (waitingCount > 0){
                MMDownloadItem* item = [dsInstance.waitingList objectAtIndex:0];
                if (item != nil){
                    [dsInstance.waitingList removeObjectAtIndex:0];
                    [dsInstance.downloadingList addObject:item];
                    item.status = DOWNLOAD_SERVICE_STATUS_DOWNLOADING;
                    //MMLogDebug(@"Download service download starting item = %@", item);
                    
                    MMHttpSession* httpSession = [MMHttpSession alloc];
                    [httpSession download:item.url reqHeader:item.header filePath:item.localUri callback:^(int status, int code, NSDictionary *resultData) {
                        @synchronized(self) {
                            
                            NSString* url = nil;
                            if (resultData != nil){
                                url = [resultData objectForKey:MM_HTTP_RESULT_DOWNLOAD_URL];
                                //MMLogInfo(@" Download service download finish code = %d, url = %@", code, url);
                            }
                            if (url == nil)
                                return;
                            
                            //NSString* localUri = [resultData objectForKey:MM_HTTP_RESULT_LOCAL_URI];
                            
                            MMDownloadItem* finishItem = [self getDownloadingItemByUrl:url];
                            
                            MMLogInfo(@" Download service download finish item = %@, url : %@", finishItem, url);
                            if (finishItem != nil){
                                if (finishItem.callback != nil){
                                    //MMLogDebug(@"Download service download finish callback");
                                    if (finishItem.status != 1){
                                        MMLogInfo(@"Download service download finish update repeat %@ status %d", finishItem, finishItem.status);
                                        MMLogInfo(@"url = %@", url);
                                        MMLogInfo(@"item url = %@", finishItem.url);
                                    }
                                    if (code == 200){
                                        finishItem.status = DOWNLOAD_SERVICE_STATUS_FINISH_SUCC;
                                        finishItem.callback(DOWNLOAD_SUCCESS, resultData);
                                    } else {
                                        finishItem.status = DOWNLOAD_SERVICE_STATUS_FINISH_FAIL;
                                        finishItem.callback(DOWNLOAD_FAILED, resultData);
                                    }
                                    //MMLogInfo(@"Download service download finish update  %@ status %d", finishItem, finishItem.status);
                                }
                                //[dsInstance.downloadingList removeObject:item];
                            }
                        }
                    } progressCallback:^(NSString* url, double progress){
                        @synchronized(self) {
                            // progress
                            MMDownloadItem* progressitem = [self getDownloadingItemByUrl:url];
                            if (progressitem != nil && progressitem.cbProgress != nil){
                                progressitem.cbProgress(progress);
                            }
                        }
                    }];
                    
                    item.session = httpSession;
                }
            }
            
            [NSThread sleepForTimeInterval:0.1];
        } else
            [NSThread sleepForTimeInterval:5];
    }
}

-(void) startDownload {
    if (dsInstance.isDownloadRunning == NO){
        dsInstance.isDownloadRunning = YES;
        dsInstance.serviceStatus = SERVICE_STATUS_RUNNING;
        NSThread* downloadThread = [[NSThread alloc] initWithTarget:self
                                                      selector:@selector(runningDownload)
                                                        object:nil];
        [downloadThread start];
    }
}

-(MMDownloadItem*) getDownloadingItemByUrl: (NSString*) url{
    MMDownloadItem* ret = nil;
    
    if (dsInstance.downloadingList != nil && url != nil){
        for (int i = 0; i < [dsInstance.downloadingList count]; i++){
            MMDownloadItem* item = [dsInstance.downloadingList objectAtIndex:i];
            if (item != nil){
                if ( [item.url compare:url] == NSOrderedSame ){
                    ret = item;
                }
            }
        }
    }
    
    return ret;
}

-(void) download: (MMDownloadItem*) item {
    if (item != nil){
        item.status = DOWNLOAD_SERVICE_STATUS_WAITING;
        [dsInstance.waitingList addObject:item];
        
        if (dsInstance.isDownloadRunning == NO)
            [self startDownload];
    }
}

-(void) download: (NSString*) url
       reqHeader: (NSMutableDictionary*) header
        filePath: (NSString*) file
        wifiOnly: (BOOL) wifi
        callback: (MMDownloadCallback) cb
progressCallback: (MMDownloadProgressCallback) proCb{
    if (url != nil && file != nil){
        MMDownloadItem* item = [MMDownloadItem alloc];
        item.url = url;
        item.header = header;
        item.localUri = file;
        item.wifiOnly = wifi;
        item.callback = cb;
        item.cbProgress = proCb;
        
        [self download:item];
    }
}

-(void) stopService{
    dsInstance.serviceStatus = SERVICE_STATUS_STOP;
    
    if (dsInstance.waitingList != nil){
        [dsInstance.waitingList removeAllObjects];
    }
    
    if (dsInstance.downloadingList != nil){
        for (int i = 0; i < [dsInstance.downloadingList count]; i++){
            MMDownloadItem* item = [dsInstance.downloadingList objectAtIndex:i];
            if (item != nil && item.session != nil)
                [item.session.mmDownloadTask cancel];
        }
        
        [dsInstance.downloadingList removeAllObjects];
    }
}

-(void) startService{
    [self startDownload];
}

-(void) pauseService{
    dsInstance.serviceStatus = SERVICE_STATUS_PAUSE;
    
    if (dsInstance.downloadingList != nil){
        for (int i = 0; i < [dsInstance.downloadingList count]; i++){
            MMDownloadItem* item = [dsInstance.downloadingList objectAtIndex:i];
            if (item != nil && item.session != nil) {
                [item.session.mmDownloadTask cancel];
                item.session = nil;
                if (dsInstance.waitingList != nil)
                    [dsInstance.waitingList insertObject:item atIndex:0];
            }
        }
        
        [dsInstance.downloadingList removeAllObjects];
    }
}

@end