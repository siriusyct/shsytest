//
//  MMDictionaryHelper.h
//  Go2ReachSample
//
//  Created by apple on 15/9/10.
//  Copyright (c) 2015年 Gmobi. All rights reserved.
//

#ifndef momock_MMDictionaryHelper_h
#define momock_MMDictionaryHelper_h

#import <Foundation/Foundation.h>

@interface MMDictionaryHelper : NSObject

+(id) select: (NSMutableDictionary*) node
        path: (NSString*) path
         def: (id) def;

+(NSString*) selectString: (NSMutableDictionary*) node
                     path: (NSString*) path
                      def: (NSString*) def;

+(NSNumber*) selectNumber: (NSMutableDictionary*) node
                     path: (NSString*) path
                      def: (NSNumber*) def;

+(NSInteger) selectInteger: (NSMutableDictionary*) node
                      path: (NSString*) path
                       def: (NSInteger) def;

@end

#endif
