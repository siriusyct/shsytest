//
//  CMHttpSession.h
//  momock
//
//  Created by apple on 15/3/24.
//  Copyright (c) 2015年 Gmobi. All rights reserved.
//

#ifndef momock_MMHttpSession_h
#define momock_MMHttpSession_h

#import <Foundation/Foundation.h>

#define MM_HTTP_STATE_WAITING 0
#define MM_HTTP_STATE_STARTED 1
#define MM_HTTP_STATE_HEADER_RECEIVED 2
#define MM_HTTP_STATE_CONTENT_RECEIVING 3
#define MM_HTTP_STATE_CONTENT_RECEIVED 4
#define MM_HTTP_STATE_ERROR 5
#define MM_HTTP_STATE_FINISHED 6

#define MM_HTTP_RESULT_DATA @"data"
#define MM_HTTP_RESULT_ERROR @"error"
#define MM_HTTP_RESULT_DOWNLOAD_URL @"url"
#define MM_HTTP_RESULT_LOCAL_URI @"locoluri"

#define MM_HTTP_STATUS_ERROR 800

typedef void (^MMHttpSessionCallback)(int status, int code, NSDictionary* resultData);
typedef void (^MMHttpSessionProgressCallback)(NSString* url, double progress);

@interface MMHttpSession: NSObject <NSURLSessionDelegate>{
    NSURLSession* session;
    NSMutableDictionary *reqHeader;
    NSDictionary* rspHeader;
    NSURL* reqUrl;
    NSMutableURLRequest* request;
    NSURLSessionDataTask* mmDataTask;
    NSURLSessionDownloadTask* mmDownloadTask;
    NSURLSessionUploadTask* mmUploadTask;
    int mmStatus;
}

@property (retain) NSURLSession* session;
@property (retain) NSMutableDictionary* reqHeader;
@property (retain) NSDictionary* rspHeader;
@property (retain) NSURL* reqUrl;
@property (retain) NSMutableURLRequest* request;
@property (retain) NSURLSessionDataTask* mmDataTask;
@property (retain) NSURLSessionDownloadTask* mmDownloadTask;
@property (retain) NSURLSessionUploadTask* mmUploadTask;
@property (nonatomic, strong) MMHttpSessionCallback mmCallbackHandler;
@property (nonatomic, strong) MMHttpSessionProgressCallback mmProgressCallbackHandler;
@property (assign) int mmStatus;

-(void) doGet: (NSString*) url
    reqHeader: (NSMutableDictionary*) header
     callback: (MMHttpSessionCallback) cb;

-(void) doPost: (NSString*) url
     reqHeader: (NSMutableDictionary*) header
       reqBody: (NSString*) body
      callback: (MMHttpSessionCallback) cb;

-(void) doPostJSON: (NSString*) url
     reqHeader: (NSMutableDictionary*) header
       reqBody: (NSDictionary*) body
      callback: (MMHttpSessionCallback) cb;

-(NSString*) download: (NSString*) url
            reqHeader: (NSMutableDictionary*) header
             filePath: (NSString*) file
             callback: (MMHttpSessionCallback) cb
     progressCallback: (MMHttpSessionProgressCallback) proCb;

-(void) doDelete: (NSString*) url
       reqHeader: (NSMutableDictionary*) header
         reqBody: (NSString*) body
        callback: (MMHttpSessionCallback) cb;

-(void) doPut: (NSString*) url
       reqHeader: (NSMutableDictionary*) header
         reqBody: (NSString*) body
        callback: (MMHttpSessionCallback) cb;

-(void) doPutJSON: (NSString*) url
         reqHeader: (NSMutableDictionary*) header
           reqBody: (NSDictionary*) body
          callback: (MMHttpSessionCallback) cb;

@end


#endif
