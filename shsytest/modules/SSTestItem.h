//
//  SSTestItem.h
//  shsytest
//
//  Created by jizhai_zl on 2017/3/16.
//  Copyright © 2017年 zl. All rights reserved.
//

#ifndef SSTestItem_h
#define SSTestItem_h

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface SSTestItem : NSObject

@property (assign) int index;
@property NSString* qid;
@property NSString* qimage;
@property int qoptions;
@property NSString* qanswer;
@property NSString* explanation;

@property int mistakeCount;


@end

#endif /* SSTestItem_h */
