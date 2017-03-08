//
//  JsonDatabase.h
//  momock
//
//  Created by apple on 15/1/6.
//  Copyright (c) 2015年 Gmobi. All rights reserved.
//

#ifndef momock_JsonDatabase_h
#define momock_JsonDatabase_h

#import <Foundation/Foundation.h>
#import <sqlite3.h>

typedef BOOL (^IMomockFilter)(NSString* iid, NSDictionary* doc);

@interface MySQLiteOpenHelper : NSObject{
    sqlite3 *db;
    NSLock *lock;
}

+(MySQLiteOpenHelper*)getSQLiteDB;
+(void)closeSQLiteDB;

@property sqlite3* db;
@property NSLock* lock;

-(void)setData: (NSString*) dId
      saveName: (NSString*) name
      saveData: (NSString*) data;

-(NSString*)getStringData: (NSString*) dId
                  tarName: (NSString*) name;

-(void)deleteData: (NSString*) dId
          delName: (NSString*) name;

@end

@interface Collection : NSObject{
    MySQLiteOpenHelper* sqlHelper;
    NSString *name;
    NSMutableDictionary *cacheDocs;
    BOOL cacheable;
}

@property MySQLiteOpenHelper* sqlHelper;
@property NSString *name;
@property NSMutableDictionary *cacheDocs;
@property BOOL cacheable;

-(void) init: (MySQLiteOpenHelper*) helper
                  tagName: (NSString*) tName;

-(id) get: (NSString*) iid;
-(NSString*) set: (NSString*) iid
         setData: (id) data;
-(int) size;
-(NSMutableArray*) list;
-(NSMutableArray*) getDataListByStartCount: (int) start
                                 listCount: (int) count;
@end

@interface Document : NSObject{
    Collection *col;
    NSString *iid;
    id jo;
}

@property Collection *col;
@property NSString *iid;
@property id jo;


-(void)init: (Collection*) pCol
      docId: (NSString*) documentId
    docData: (id) data;

-(NSString*) getId;
-(id) getData;

@end

@interface MMJsonDatabase : NSObject{
    NSMutableDictionary* cols;
    MySQLiteOpenHelper* sqlHelper;
}

@property NSMutableDictionary* cols;
@property MySQLiteOpenHelper* sqlHelper;

+(MMJsonDatabase*) get;

-(Collection*) getCollection: (NSString*) name;

-(void) forceClose;

@end

#endif
