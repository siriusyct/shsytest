//
//  SDEventService.h
//  MediatekSmartDevice
//
//  Created by apple on 14-11-27.
//  Copyright (c) 2014年 Gmobi. All rights reserved.
//

#ifndef momock_MMEventService_h
#define momock_MMEventService_h

#import <Foundation/Foundation.h>

#define MM_EVENT_CONNECT_CHANGE @"ConnectChange"
#define MM_EVENT_DEVICE_INFO_GET_SUCCESS @"DeviceInfoSuccess"
#define MM_EVENT_UPDATE_CONNECT_CHANGE @"UpdateConnectChange"
#define MM_EVENT_UPDATE_PROGRESS @"UpdateProgress"
#define MM_EVENT_UPDATE_STATUS @"UpdateStatus"

@interface IEventItem : NSObject{
    id target;
    NSString *event;
    SEL selector;
}

@property id target;
@property NSString *event;
@property SEL selector;

-(void)setData: (id) tg
     eventName: (NSString*) e
   selectorHdl: (SEL) h;

@end

@interface MMEventService : NSObject{
    NSMutableArray *eventList;
}

@property NSMutableArray *eventList;

+(MMEventService*) getInstance;

-(void)send: (NSString*) event
  eventData: (id) data;

-(void)addEventHandler: (id) tg
             eventName: (NSString*) event
              selector: (SEL)handler;

-(void)removeEventHandler: (NSString*) event;

@end

#endif
