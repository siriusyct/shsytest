//
//  SettingService.m
//  shsytest
//
//  Created by jizhai_zl on 2017/2/27.
//  Copyright © 2017年 zl. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MMJsonDatabase.h"
#import "SettingService.h"
#import "MMSystemHelper.h"
#import "MMLogger.h"

#define SETTING_COL_NAME  @"internetstirsetting"
#define DEFAULT_DATA_STR @"data_key"

SettingService* settingInstance = nil;

@implementation SettingService


+(SettingService*) get{
    @synchronized(self){
        if (settingInstance == nil){
            settingInstance = [SettingService alloc];
            [settingInstance initDB];
        }
    }
    return settingInstance;
}

-(void) initDB {
    MMJsonDatabase* jdb = [MMJsonDatabase get];
    _col = [jdb getCollection:SETTING_COL_NAME];
}

-(void) setStringValue: (NSString*) key
               data : (NSString*) value{
    if (_col != nil && key != nil) {
        NSMutableDictionary* saveData = nil;
        if (value != nil){
            saveData = [NSMutableDictionary dictionaryWithCapacity:1];
            [saveData setObject:value forKey:DEFAULT_DATA_STR];
        }
        [_col set:key setData:saveData];
    }
}

-(NSString*) getStringValue: (NSString*) key
                   defValue: (NSString*) def{
    NSString* retValue = def;
    
    if (_col != nil && key != nil){
        NSDictionary* data = [_col get:key];
        if (data != nil) {
            NSString* ret = [data objectForKey:DEFAULT_DATA_STR];
            if (ret != nil)
                retValue = ret;
        }
    }
    return retValue;
}

-(void) setBooleanValue: (NSString*) key
                   data: (BOOL) value{
    if (_col != nil && key != nil) {
        NSMutableDictionary* saveData = [NSMutableDictionary dictionaryWithCapacity:1];
        NSNumber* tmpNum = [NSNumber numberWithBool:value];
        [saveData setObject:tmpNum forKey:DEFAULT_DATA_STR];
        
        [_col set:key setData:saveData];
    }
    
}
-(BOOL) getBooleanValue: (NSString*) key
               defValue: (BOOL) def{
    BOOL retValue = def;
    
    if (_col != nil && key != nil){
        NSDictionary* data = [_col get:key];
        if (data != nil) {
            NSNumber* ret = [data objectForKey:DEFAULT_DATA_STR];
            if (ret != nil)
                retValue = [ret boolValue];
        }
    }
    return retValue;
}

-(void) setIntValue: (NSString*) key
               data: (int) value{
    if (_col != nil && key != nil) {
        NSMutableDictionary* saveData = [NSMutableDictionary dictionaryWithCapacity:1];
        NSNumber* tmpNum = [NSNumber numberWithInt:value];
        [saveData setObject:tmpNum forKey:DEFAULT_DATA_STR];
        
        [_col set:key setData:saveData];
    }
}
-(int) getIntValue: (NSString*) key
          defValue: (int) def{
    int retValue = def;
    
    if (_col != nil && key != nil){
        NSDictionary* data = [_col get:key];
        if (data != nil) {
            NSNumber* ret = [data objectForKey:DEFAULT_DATA_STR];
            if (ret != nil)
                retValue = [ret intValue];
        }
    }
    return retValue;
}

-(void) setFloatValue: (NSString*) key
                 data: (float) value{
    if (_col != nil && key != nil) {
        NSMutableDictionary* saveData = [NSMutableDictionary dictionaryWithCapacity:1];
        NSNumber* tmpNum = [NSNumber numberWithFloat:value];
        [saveData setObject:tmpNum forKey:DEFAULT_DATA_STR];
        
        [_col set:key setData:saveData];
    }
}
-(float) getFloatValue: (NSString*) key
              defValue: (float) def{
    float retValue = def;
    
    if (_col != nil && key != nil){
        NSDictionary* data = [_col get:key];
        if (data != nil) {
            NSNumber* ret = [data objectForKey:DEFAULT_DATA_STR];
            if (ret != nil)
                retValue = [ret floatValue];
        }
    }
    return retValue;
}


-(void) setDictoryValue: (NSString*) key
                   data: (NSDictionary*) value{
    if (_col != nil && key != nil){
        [_col set:key setData:value];
    }
}

-(NSDictionary*) getDictoryValue: (NSString*) key
                        defValue: (NSDictionary*) def {
    NSDictionary* retValue = def;
    
    if (_col != nil && key != nil){
        NSDictionary* data = [_col get:key];
        if (data != nil) {
            retValue = data;
        }
    }
    return retValue;
}

-(void) setArrayValue: (NSString*) key
                 data: (NSArray*) value{
    if (_col != nil && key != nil){
        [_col set:key setData:value];
    }
}

-(NSArray*) getArrayValue: (NSString*) key
                 defValue: (NSArray*) def{
    NSArray* retValue = def;
    
    if (_col != nil && key != nil){
        NSArray* data = [_col get:key];
        if (data != nil) {
            retValue = data;
        }
    }
    return retValue;
}

@end
