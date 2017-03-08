//
//  ConfigService.h
//  shsytest
//
//  Created by apple on 15/4/20.
//  Copyright (c) 2015年 zl. All rights reserved.
//

#ifndef shsytest_ConfigService_h
#define shsytest_ConfigService_h

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>



@interface ConfigService: NSObject

@property (assign) int type;

+(ConfigService*) get;

-(void) initLocaleConfig;

@end

#endif
