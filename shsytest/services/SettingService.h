//
//  SettingService.h
//  shsytest
//
//  Created by jizhai_zl on 2017/2/27.
//  Copyright © 2017年 zl. All rights reserved.
//

#ifndef PoPoNews_SettingService_h
#define PoPoNews_SettingService_h

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "MMJsonDatabase.h"

@interface SettingService: NSObject

@property Collection* col;

+(SettingService*) get;


-(void) setStringValue: (NSString*) key
                 data : (NSString*) value;
-(NSString*) getStringValue: (NSString*) key
                   defValue: (NSString*) def;

-(void) setBooleanValue: (NSString*) key
                   data: (BOOL) value;
-(BOOL) getBooleanValue: (NSString*) key
               defValue: (BOOL) def;

-(void) setIntValue: (NSString*) key
                   data: (int) value;
-(int) getIntValue: (NSString*) key
          defValue: (int) def;

-(void) setFloatValue: (NSString*) key
                   data: (float) value;
-(float) getFloatValue: (NSString*) key
              defValue: (float) def;


-(void) setDictoryValue: (NSString*) key
                   data: (NSDictionary*) value;
-(NSDictionary*) getDictoryValue: (NSString*) key
                        defValue: (NSDictionary*) def;

-(void) setArrayValue: (NSString*) key
                   data: (NSArray*) value;
-(NSArray*) getArrayValue: (NSString*) key
                        defValue: (NSArray*) def;

@end

#endif
