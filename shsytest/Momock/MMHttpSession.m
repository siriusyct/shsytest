//
//  CMHttpSession.m
//  momockDemo
//
//  Created by apple on 15/3/24.
//  Copyright (c) 2015年 Gmobi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MMHttpSession.h"
#import "MMLogger.h"

@implementation MMHttpSession

@synthesize session;
@synthesize reqHeader;
@synthesize rspHeader;
@synthesize reqUrl;
@synthesize request;
@synthesize mmDataTask;
@synthesize mmDownloadTask;
@synthesize mmUploadTask;
@synthesize mmStatus;

-(void) initSession{
    NSURLSessionConfiguration *sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
    session = [NSURLSession sessionWithConfiguration:sessionConfig delegate:self delegateQueue:nil];
}

-(void) setRequestHeader: (NSMutableDictionary*) header{
    if (request != nil && header != nil){
        reqHeader = header;
        for(NSString* key in header){
            NSString* value = [header objectForKey:key];
            [request addValue:value forHTTPHeaderField:key];
        }
    }
}

-(void) execute{
    mmDataTask = [session dataTaskWithRequest:request
                            completionHandler:
                  ^(NSData *data, NSURLResponse *response, NSError *error) {
                      
                      if (response != nil){
                          NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*)response;
                          NSInteger httpCode = [httpResponse statusCode];
                          MMLogDebug(@"CMHttpSession response headers of %@  [%d]", [httpResponse URL], httpCode);
                          
                          NSDictionary* rspH = [httpResponse allHeaderFields];
                          if (rspH != nil){
                              for(NSString* key in rspH){
                                  MMLogDebug(@"%@ = %@", key, [rspH objectForKey:key]);
                              }
                              
                              rspHeader = [rspH copy];
                              mmStatus = MM_HTTP_STATE_HEADER_RECEIVED;
                          }
                          
                          if (self.mmCallbackHandler != nil){
                            
                              NSMutableDictionary* resultData = [NSMutableDictionary dictionaryWithCapacity:2];
                              if (data != nil){
                                  [resultData setObject:data forKey:MM_HTTP_RESULT_DATA];
                                  mmStatus = MM_HTTP_STATE_CONTENT_RECEIVED;
                              }
                              
                              if (error != nil)
                                  [resultData setObject:error forKey:MM_HTTP_RESULT_ERROR];
                              self.mmCallbackHandler(mmStatus, (int)httpCode, resultData);
                          }
                      } else {
                          if (self.mmCallbackHandler != nil){
                              mmStatus = MM_HTTP_STATE_ERROR;
                              
                              MMLogDebug(@"CMHttpSession error: %@", error);
                              
                              NSMutableDictionary* resultData = [NSMutableDictionary dictionaryWithCapacity:2];
                              if (data != nil){
                                  [resultData setObject:data forKey:MM_HTTP_RESULT_DATA];
                              }
                              if (error != nil)
                                  [resultData setObject:error forKey:MM_HTTP_RESULT_ERROR];
                              self.mmCallbackHandler(mmStatus, MM_HTTP_STATUS_ERROR, resultData);
                          }
                      }
                  }];
    mmStatus = MM_HTTP_STATE_STARTED;
    [mmDataTask resume];
}

-(void) doGet: (NSString*) url
    reqHeader: (NSMutableDictionary*) header
     callback: (MMHttpSessionCallback) cb{
    
    mmStatus = MM_HTTP_STATE_WAITING;
    
    [self initSession];
    reqUrl = [NSURL URLWithString:url];
    NSURLRequest* reqReq = [NSURLRequest requestWithURL:reqUrl];
    
    request = [reqReq mutableCopy];
    if (header != nil){
        [self setRequestHeader:header];
    }
    request.HTTPMethod = @"GET";
    
    self.mmCallbackHandler = cb;
    
    [self execute];
}

-(void) doPost: (NSString*) url
     reqHeader: (NSMutableDictionary*) header
       reqBody: (NSString*) body
      callback: (MMHttpSessionCallback) cb{
    
    mmStatus = MM_HTTP_STATE_WAITING;
    
    [self initSession];
    reqUrl = [NSURL URLWithString:url];
    NSURLRequest* reqReq = [NSURLRequest requestWithURL:reqUrl];
    
    request = [reqReq mutableCopy];
    if (header != nil){
        [self setRequestHeader:header];
    }
    if (body != nil)
        request.HTTPBody = [body dataUsingEncoding:NSUTF8StringEncoding];
    
    request.HTTPMethod = @"POST";
    
    self.mmCallbackHandler = cb;
    
    [self execute];
}

-(void) doPostJSON: (NSString*) url
         reqHeader: (NSMutableDictionary*) header
           reqBody: (NSDictionary*) body
          callback: (MMHttpSessionCallback) cb{
    mmStatus = MM_HTTP_STATE_WAITING;
    
    [self initSession];
    reqUrl = [NSURL URLWithString:url];
    NSURLRequest* reqReq = [NSURLRequest requestWithURL:reqUrl];
    
    request = [reqReq mutableCopy];
    if (header != nil){
        [self setRequestHeader:header];
    }
    
    NSDictionary* jsonHeader = [NSDictionary dictionaryWithObject:@"application/json" forKey:@"Content-Type"];
    [self setRequestHeader:jsonHeader];
    
    if (body != nil){
        NSError* error = nil;
        NSData* tmpBodyData = [NSJSONSerialization dataWithJSONObject:body options:NSJSONWritingPrettyPrinted error:&error];
        NSString* tmpBodyStr = [[NSString alloc] initWithData:tmpBodyData encoding:NSUTF8StringEncoding];
        MMLogDebug(@"MMHttpService: Post Body = %@", tmpBodyStr);
        request.HTTPBody = tmpBodyData;
    }
    request.HTTPMethod = @"POST";
    
    self.mmCallbackHandler = cb;
    
    [self execute];
}

-(NSString*) download: (NSString*) url
            reqHeader: (NSMutableDictionary*) header
             filePath: (NSString*) file
             callback: (MMHttpSessionCallback) cb
     progressCallback: (MMHttpSessionProgressCallback) proCb{
    
    mmStatus = MM_HTTP_STATE_WAITING;
    
    [self initSession];
    reqUrl = [NSURL URLWithString:url];
    NSURLRequest* reqReq = [NSURLRequest requestWithURL:reqUrl];
    
    request = [reqReq mutableCopy];
    if (header != nil){
        [self setRequestHeader:header];
    }
    self.mmCallbackHandler = cb;
    
    if (proCb != nil)
        self.mmProgressCallbackHandler = proCb;
    else
        self.mmProgressCallbackHandler = nil;
    
    mmDownloadTask = [session downloadTaskWithRequest:request completionHandler:^(NSURL *location, NSURLResponse *response, NSError *error) {
        
        @synchronized(self) {
            NSInteger httpCode = 0;
            if (response != nil){
                NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*)response;
                httpCode = [httpResponse statusCode];
                //MMLogDebug(@"CMHttpSession response headers of %@  [%d]", [httpResponse URL], httpCode);
            }
            
            if (error != nil){
                //MMLogDebug(@"CMHttpSession download error : %@", error);
            }
            
            MMLogDebug(@"CMHttpSession download uri : %@", location);
            
            if (error == nil && file != nil){
                NSError* fError = nil;
                NSFileManager *fileMgr = [NSFileManager defaultManager];
                if ([fileMgr fileExistsAtPath:file]){
                    [fileMgr removeItemAtPath:file error:&fError];
                }
                NSURL* targFile = [NSURL fileURLWithPath:file];
                [fileMgr moveItemAtURL:location toURL:targFile error:&fError];
                //MMLogDebug(@"CMHttpSession download file move to : %@", file);
            }
            
            if (self.mmCallbackHandler != nil){
                
                //MMLogDebug(@"CMHttpSession download file callback : %@", self.mmCallbackHandler);
                
                NSMutableDictionary* resultData = [NSMutableDictionary dictionaryWithCapacity:2];
                if (file != nil){
                    [resultData setObject:file forKey:MM_HTTP_RESULT_DATA];
                    mmStatus = MM_HTTP_STATE_CONTENT_RECEIVED;
                }
                
                if (error != nil)
                    [resultData setObject:error forKey:MM_HTTP_RESULT_ERROR];
                
                if (url != nil)
                    [resultData setObject:[reqUrl absoluteString] forKey:MM_HTTP_RESULT_DOWNLOAD_URL];
                
                [resultData setObject:file forKey:MM_HTTP_RESULT_LOCAL_URI];
                
                self.mmCallbackHandler(mmStatus, (int)httpCode, resultData);
            }
        }
    }];
    [mmDownloadTask resume];
    
    return file;
}


-(void) doDelete: (NSString*) url
     reqHeader: (NSMutableDictionary*) header
       reqBody: (NSString*) body
      callback: (MMHttpSessionCallback) cb{
    
    mmStatus = MM_HTTP_STATE_WAITING;
    
    [self initSession];
    reqUrl = [NSURL URLWithString:url];
    NSURLRequest* reqReq = [NSURLRequest requestWithURL:reqUrl];
    
    request = [reqReq mutableCopy];
    if (header != nil){
        [self setRequestHeader:header];
    }
    if (body != nil)
        request.HTTPBody = [body dataUsingEncoding:NSUTF8StringEncoding];
    
    request.HTTPMethod = @"DELETE";
    
    self.mmCallbackHandler = cb;
    
    [self execute];
}

-(void) doPut: (NSString*) url
    reqHeader: (NSMutableDictionary*) header
      reqBody: (NSString*) body
     callback: (MMHttpSessionCallback) cb{
    mmStatus = MM_HTTP_STATE_WAITING;
    
    [self initSession];
    reqUrl = [NSURL URLWithString:url];
    NSURLRequest* reqReq = [NSURLRequest requestWithURL:reqUrl];
    
    request = [reqReq mutableCopy];
    if (header != nil){
        [self setRequestHeader:header];
    }
    if (body != nil)
        request.HTTPBody = [body dataUsingEncoding:NSUTF8StringEncoding];
    
    request.HTTPMethod = @"PUT";
    
    self.mmCallbackHandler = cb;
    
    [self execute];
}

-(void) doPutJSON: (NSString*) url
        reqHeader: (NSMutableDictionary*) header
          reqBody: (NSDictionary*) body
         callback: (MMHttpSessionCallback) cb{
    mmStatus = MM_HTTP_STATE_WAITING;
    
    [self initSession];
    reqUrl = [NSURL URLWithString:url];
    NSURLRequest* reqReq = [NSURLRequest requestWithURL:reqUrl];
    
    request = [reqReq mutableCopy];
    if (header != nil){
        [self setRequestHeader:header];
    }
    
    NSDictionary* jsonHeader = [NSDictionary dictionaryWithObject:@"application/json" forKey:@"Content-Type"];
    [self setRequestHeader:jsonHeader];
    
    if (body != nil){
        NSError* error = nil;
        NSData* tmpBodyData = [NSJSONSerialization dataWithJSONObject:body options:NSJSONWritingPrettyPrinted error:&error];
        NSString* tmpBodyStr = [[NSString alloc] initWithData:tmpBodyData encoding:NSUTF8StringEncoding];
        MMLogDebug(@"MMHttpService: Post Body = %@", tmpBodyStr);
        request.HTTPBody = tmpBodyData;
    }
    request.HTTPMethod = @"PUT";
    
    self.mmCallbackHandler = cb;
    
    [self execute];
}

-(void) URLSession:(NSURLSession*) session
      downloadTask:(NSURLSessionDownloadTask *)downloadTask
      didWriteData:(int64_t)bytesWritten
 totalBytesWritten:(int64_t)totalBytesWritten
totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite{
    
    if (self.mmProgressCallbackHandler != nil){
        double downloadProgress = totalBytesWritten / (double)totalBytesExpectedToWrite;
        self.mmProgressCallbackHandler([reqUrl absoluteString], downloadProgress);
    }
}

@end

