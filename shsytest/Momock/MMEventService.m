//
//  SDEventService.m
//  MediatekSmartDevice
//
//  Created by apple on 14-11-27.
//  Copyright (c) 2014年 Gmobi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MMEventService.h"
#import "MMLogger.h"

#define EVENT_KEY @"key"
#define EVENT_EVENT @"event"
#define EVENT_HANDLER @"handler"

static MMEventService *esInstance = nil;

@implementation IEventItem

@synthesize target;
@synthesize event;
@synthesize selector;

-(void)setData: (id) tg
     eventName: (NSString*) e
   selectorHdl: (SEL) h{
    target = tg;
    event = e;
    selector = h;
}

@end

@implementation MMEventService

@synthesize eventList;

+(MMEventService*)getInstance{
    @synchronized(self){
        if (esInstance == nil){
            esInstance = [MMEventService alloc];
            esInstance.eventList = [[NSMutableArray alloc] initWithCapacity:10];
        }
    }
    
    return esInstance;
}

-(void)send: (NSString*) event
  eventData: (id) data{
    if (esInstance == nil || event == nil)
        return;
    
    int i = 0;
    
    @try {
        for (i = 0; i < esInstance.eventList.count; i++) {
            IEventItem *tmp = [esInstance.eventList objectAtIndex:i];
            
            if (tmp && [event isEqualToString:[tmp event]]){
                SEL selector = [tmp selector];
                    
                if (selector && tmp.target)
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
                    [tmp.target performSelector:selector withObject:data];
#pragma clang diagnostic pop
                else{
                    [esInstance.eventList removeObjectAtIndex:i];
                    i--;
                }
            }
        }
    }
    @catch (NSException *exception) {
        MMLogError(@"%@", exception);
        if (esInstance && esInstance.eventList) {
            [esInstance.eventList removeObjectAtIndex:i];
        }
    }
    @finally {
        MMLogDebug(@"send event %@", event);
    }
}

-(void)addEventHandler: (id) tg
             eventName: (NSString*) event
              selector: (SEL)handler{
    
    if (tg == nil || event == nil || handler == nil)
        return;
    
    if (esInstance){
        [self removeEventHandler:event];
        
        IEventItem *item = [IEventItem alloc];
        [item setData:tg eventName:event selectorHdl:handler];
        [esInstance.eventList addObject:item];
    }
    
}

-(void)removeEventHandler: (NSString*) event{
    if (event == nil || esInstance == nil)
        return;
    
    int i = 0;
    for (i = 0; i < esInstance.eventList.count; i++) {
        IEventItem *tmp = [esInstance.eventList objectAtIndex:i];
        if (tmp && [event isEqualToString:[tmp event]]){
            [esInstance.eventList removeObjectAtIndex:i];
            break;
        }
    }
}


@end