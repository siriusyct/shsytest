//
//  MMDictionaryHelper.m
//  Go2ReachSample
//
//  Created by apple on 15/9/10.
//  Copyright (c) 2015年 Gmobi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MMDictionaryHelper.h"

@implementation MMDictionaryHelper

+(id) select: (NSMutableDictionary*) node
        path: (NSString*) path
         def: (id) def{
    if (node == nil) return def;
    if (path == nil) return def;
    
    NSRange pos = [path rangeOfString:@"/"];
    
    NSString* current = pos.length == 0 ? path : [path substringToIndex:pos.location];
    NSString* next = pos.length == 0 ? nil : [path substringFromIndex:pos.location+1];
    
    NSEnumerator* dictEnum = [node keyEnumerator];
    NSString* key = nil;
    while ((key = [dictEnum nextObject])) {
        if ([current isEqualToString:key]){
            id val = [node objectForKey:current];
            if (next == nil) return val;
            
            if ([val isKindOfClass:[NSDictionary class]]){
                return [self select:val path:next def:def];
            } else
                return def;
        }
    }
    
    return def;
}

+(NSString*) selectString: (NSMutableDictionary*) node
                     path: (NSString*) path
                      def: (NSString*) def{
    id val = [self select:node path:path def:def];
    return val == nil || [val isEqual:[NSNull null]] ? def : val;
}

+(NSNumber*) selectNumber: (NSMutableDictionary*) node
                     path: (NSString*) path
                      def: (NSNumber*) def{
    id val = [self select:node path:path def:def];
    return val == nil || [val isEqual:[NSNull null]] ? def : val;
}

+(NSInteger) selectInteger: (NSMutableDictionary*) node
                     path: (NSString*) path
                      def: (NSInteger) def{
    NSNumber* val = [self selectNumber:node path:path def:nil];
    return val == nil || [val isEqual:[NSNull null]] ? def : [val integerValue];
}

@end