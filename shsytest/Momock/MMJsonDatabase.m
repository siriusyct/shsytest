//
//  JsonDatabase.m
//  momock
//
//  Created by apple on 15/1/6.
//  Copyright (c) 2015年 Gmobi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MMJsonDatabase.h"

#define IDX_ID   0
#define IDX_NAME 1
#define IDX_JSON 2

#define IDX_ID_KEY     @"iid"
#define IDX_NAME_KEY   @"name"
#define IDX_JSON_KEY   @"jo"

MySQLiteOpenHelper* sqlInstance;

@implementation MySQLiteOpenHelper

@synthesize db;
@synthesize lock;

/***
 * MySQLiteOpenHelper
 * getSQLiteDB
 */
+(MySQLiteOpenHelper*)getSQLiteDB{
    @synchronized(self){
        if (sqlInstance == nil){
            sqlInstance = [MySQLiteOpenHelper alloc];
            sqlite3 *td;
            
            NSArray *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *documentPath = [path objectAtIndex:0];
            NSString *dbPath = [documentPath stringByAppendingString:@"/momocklib.db"];
            
            int openRet = sqlite3_open([dbPath UTF8String], &td);
            if (openRet == SQLITE_OK){
                
                char *errorMsg;
                const char *createSQL = "CREATE TABLE IF NOT EXISTS data(id TEXT, name TEXT, json TEXT, dataTime BIGINT, PRIMARY KEY(name, id))";
                sqlite3_exec(td, createSQL, NULL, NULL, &errorMsg);
                
                sqlInstance.lock = [[NSLock alloc] init];
                sqlInstance.db = td;
            }
        }
    }
    
    return sqlInstance;
}

+(void)closeSQLiteDB{
    @synchronized(self){
        if (sqlInstance != nil){
            sqlite3_close(sqlInstance.db);
            sqlInstance = nil;
        }
    }
}

-(UInt64) getMillisecond{
    NSDate *localDate = [NSDate date];
    NSTimeInterval dTime = [localDate timeIntervalSince1970];
    UInt64 timeSp = dTime * 1000;
    return timeSp;
}

-(void)setData: (NSString*) dId
        saveName: (NSString*) name
        saveData: (NSString*) data{
    
    if (sqlInstance == nil)
        return;
    
    [sqlInstance.lock lock];
    
    UInt64 sp = [sqlInstance getMillisecond];
    
    char *query = "INSERT INTO data VALUES(?,?,?,?)";
    sqlite3_stmt *stmt;
    if (sqlite3_prepare_v2(sqlInstance.db, query, -1, &stmt, nil) == SQLITE_OK){
        sqlite3_bind_text(stmt, 1, [dId UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text(stmt, 2, [name UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text(stmt, 3, [data UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_int64(stmt, 4, sp);
    }
    
    if (sqlite3_step(stmt) != SQLITE_DONE){
        // log failed
    }
    
    sqlite3_finalize(stmt);
    
    [sqlInstance.lock unlock];
}


-(void)updateData: (NSString*) dId
      saveName: (NSString*) name
      saveData: (NSString*) data{
    
    if (sqlInstance == nil)
        return;
    
    [sqlInstance.lock lock];
    
    char *query = "UPDATE data SET json=? WHERE id=? and name=?";
    sqlite3_stmt *stmt;
    if (sqlite3_prepare_v2(sqlInstance.db, query, -1, &stmt, nil) == SQLITE_OK){
        sqlite3_bind_text(stmt, 1, [data UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text(stmt, 2, [dId UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text(stmt, 3, [name UTF8String], -1, SQLITE_TRANSIENT);
    }
    
    if (sqlite3_step(stmt) != SQLITE_DONE){
        // log failed
    }
    
    sqlite3_finalize(stmt);
    
    [sqlInstance.lock unlock];
}

-(NSString*)getStringData: (NSString*) dId
                  tarName: (NSString*) name{
    NSString* dataStr;
    
    if (sqlInstance == nil)
        return nil;
    
    [sqlInstance.lock lock];
    
    char *query = "SELECT * FROM data WHERE id=? and name=?";
    sqlite3_stmt *stmt;
    if (sqlite3_prepare_v2(sqlInstance.db, query, -1, &stmt, nil) == SQLITE_OK){
        sqlite3_bind_text(stmt, 1, [dId UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text(stmt, 2, [name UTF8String], -1, SQLITE_TRANSIENT);
    }
    
    if (sqlite3_step(stmt) == SQLITE_ROW) {
        char* rowData = (char*)sqlite3_column_text(stmt, IDX_JSON);
        dataStr = [[NSString alloc] initWithUTF8String:rowData];
    }
    
    sqlite3_finalize(stmt);
    
    [sqlInstance.lock unlock];
    
    return dataStr;
}


-(void)deleteData: (NSString*) dId
          delName: (NSString*) name {
    if (sqlInstance == nil)
        return;
    
    [sqlInstance.lock lock];
    
    char *query = "DELETE FROM data WHERE id=? AND name=?";
    sqlite3_stmt *stmt;
    if (sqlite3_prepare_v2(sqlInstance.db, query, -1, &stmt, nil) == SQLITE_OK){
        sqlite3_bind_text(stmt, 1, [dId UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text(stmt, 2, [name UTF8String], -1, SQLITE_TRANSIENT);
    }
    sqlite3_step(stmt);
    
    sqlite3_finalize(stmt);
    
    [sqlInstance.lock unlock];
}

-(int) getDataCount: (NSString*) name{
    int dataCount = 0;
    
    if (sqlInstance == nil)
        return 0;
    
    [sqlInstance.lock lock];
    
    char *query = "SELECT COUNT(*) AS dataCount FROM data WHERE name=?";
    sqlite3_stmt *stmt;
    
    int ret = sqlite3_prepare_v2(sqlInstance.db, query, -1, &stmt, nil);
    if (ret == SQLITE_OK){
        sqlite3_bind_text(stmt, 1, [name UTF8String], -1, SQLITE_TRANSIENT);
    }
    
    int actionRet = sqlite3_step(stmt);
    if (actionRet == SQLITE_OK) {
        dataCount = sqlite3_column_int(stmt, 0);
    }
    
    sqlite3_finalize(stmt);
    
    [sqlInstance.lock unlock];
    
    return dataCount;
}

-(NSMutableArray*)getStringDataArrayByStartEnd: (NSString*) name
                                    startIndex: (int) start
                                      dataCount: (int) count {
    NSMutableArray* dataArray = nil;
    
    if (sqlInstance == nil)
        return nil;
    
    [sqlInstance.lock lock];
    
    dataArray = [[NSMutableArray alloc] init];
    char *query = "SELECT * FROM data WHERE name=? ORDER BY dataTime ASC LIMIT ?,?";
    sqlite3_stmt *stmt;
    
    int ret = sqlite3_prepare_v2(sqlInstance.db, query, -1, &stmt, nil);
    if (ret == SQLITE_OK){
        sqlite3_bind_text(stmt, 1, [name UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_int(stmt, 2, start);
        sqlite3_bind_int(stmt, 3, count);
    }
    
    while (sqlite3_step(stmt) == SQLITE_ROW) {
        NSMutableDictionary* dicData = [NSMutableDictionary dictionaryWithCapacity:2];
        
        char* rowDataId = (char*)sqlite3_column_text(stmt, IDX_ID);
        NSString* dataIdStr = [[NSString alloc] initWithUTF8String:rowDataId];
        //char* rowDataName = (char*)sqlite3_column_text(stmt, IDX_NAME);
        //NSString* dataNameStr = [[NSString alloc] initWithUTF8String:rowDataName];
        char* rowDataJo = (char*)sqlite3_column_text(stmt, IDX_JSON);
        NSString* dataJoStr = [[NSString alloc] initWithUTF8String:rowDataJo];
        
        [dicData setObject:dataIdStr forKey:IDX_ID_KEY];
        //[dicData setObject:dataNameStr forKey:IDX_NAME_KEY];
        [dicData setObject:dataJoStr forKey:IDX_JSON_KEY];
        
        [dataArray addObject:dicData];
    }
    
    sqlite3_finalize(stmt);
    
    [sqlInstance.lock unlock];
    
    return dataArray;
}

-(NSMutableArray*)getStringDataArray: (NSString*) name {
    NSMutableArray* dataArray = nil;
    
    if (sqlInstance == nil)
        return nil;
    
    [sqlInstance.lock lock];
    
    dataArray = [[NSMutableArray alloc] init];
    char *query = "SELECT * FROM data WHERE name=? ORDER BY dataTime ASC";
    sqlite3_stmt *stmt;
    
    int ret = sqlite3_prepare_v2(sqlInstance.db, query, -1, &stmt, nil);
    if (ret == SQLITE_OK){
        sqlite3_bind_text(stmt, 1, [name UTF8String], -1, SQLITE_TRANSIENT);
    }
    
    while (sqlite3_step(stmt) == SQLITE_ROW) {
        NSMutableDictionary* dicData = [NSMutableDictionary dictionaryWithCapacity:2];
        
        char* rowDataId = (char*)sqlite3_column_text(stmt, IDX_ID);
        NSString* dataIdStr = [[NSString alloc] initWithUTF8String:rowDataId];
        char* rowDataName = (char*)sqlite3_column_text(stmt, IDX_NAME);
        NSString* dataNameStr = [[NSString alloc] initWithUTF8String:rowDataName];
        char* rowDataJo = (char*)sqlite3_column_text(stmt, IDX_JSON);
        NSString* dataJoStr = [[NSString alloc] initWithUTF8String:rowDataJo];
        
        [dicData setObject:dataIdStr forKey:IDX_ID_KEY];
        [dicData setObject:dataNameStr forKey:IDX_NAME_KEY];
        [dicData setObject:dataJoStr forKey:IDX_JSON_KEY];
        
        [dataArray addObject:dicData];
    }
    
    sqlite3_finalize(stmt);
    
    [sqlInstance.lock unlock];
    
    return dataArray;
}



@end

/***
 * Document
 */
@implementation Document

@synthesize col;
@synthesize iid;
@synthesize jo;


-(void)init: (Collection*) pCol
      docId: (NSString*) documentId
    docData: (id) data{
    col = pCol;
    iid = documentId;
    jo = data;
}

-(NSString*) getId{
    return iid;
}


-(id) getData{
    if (jo == nil){
        jo = [col get:iid];
    }
    return jo;
}


@end

/***
 * Collection
 */
@implementation Collection

@synthesize sqlHelper;
@synthesize name;
@synthesize cacheDocs;
@synthesize cacheable;

-(void) init: (MySQLiteOpenHelper*) helper
                  tagName: (NSString*) tName {
    sqlHelper = helper;
    name = tName;
    cacheable = NO;
}

-(id) parse: (NSString*) dStr{
    NSDictionary* retData = nil;
    if (dStr != nil){
        id jsonObj = nil;
        
        if ([dStr isKindOfClass:[NSString class]]){
            NSError *error;
            NSData *data = [dStr dataUsingEncoding:NSUTF8StringEncoding];
            jsonObj = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
        }
        
        if ([jsonObj isKindOfClass:[NSDictionary class]] || [jsonObj isKindOfClass:[NSArray class]]){
            retData = jsonObj;
        }
    }
    
    return retData;
}

-(id) get: (NSString*) iid{
    if (iid == nil)
        return nil;
    
    if (cacheable == YES && cacheDocs != nil){
        id obj = [cacheDocs objectForKey:iid];
        if (obj != nil && [obj isKindOfClass:[Document class]]){
            Document* docObj = (Document*)obj;
            id data = [docObj getData];
            return data;
            //return [self parse:dataStr];
        }
    }
    
    if (sqlHelper != nil){
        NSString* sqlStr = [sqlHelper getStringData:iid tarName:name];
        return [self parse:sqlStr];
    }
    
    return nil;
}

-(UInt64) getMicroseconds{
    NSDate *localDate = [NSDate date];
    NSTimeInterval dTime = [localDate timeIntervalSince1970];
    UInt64 timeSp = dTime * 1000 * 1000;
    return timeSp;
}

-(NSString*) set: (NSString*) iid
         setData: (id) data{
    NSString* ret = nil;
    
    if (iid == nil){
        UInt64 microSec = [self getMicroseconds];
        iid = [NSString stringWithFormat:@"%llu", microSec];
    }
    
    if (iid != nil && name != nil && sqlHelper != nil){
        
        if (data != nil){
            NSString* saveData = nil;
            
            if ([data isKindOfClass:[NSDictionary class]] || [data isKindOfClass:[NSMutableDictionary class]] || [data isKindOfClass:[NSArray class]] || [data isKindOfClass:[NSMutableArray class]]) {
                NSError *error;
                NSData* transData = [NSJSONSerialization dataWithJSONObject:data options:NSJSONWritingPrettyPrinted error:&error];
                NSString* transStr = [[NSString alloc] initWithData:transData encoding:NSUTF8StringEncoding];
                
                saveData = transStr;
            } else if ([data isKindOfClass:[NSString class]]){
                saveData = data;
            }
            
            if (saveData != nil){
                NSString* dataSaved = [sqlHelper getStringData:iid tarName:name];
                
                if (dataSaved == nil){
                    [sqlHelper setData:iid saveName:name saveData:saveData];
                    ret = iid;
                } else {
                    [sqlHelper updateData:iid saveName:name saveData:saveData];
                    ret = iid;
                }
                
                if (cacheable){
                    if (cacheDocs != nil){
                        Document* newDoc = [Document alloc];
                        //[newDoc init:self docId:iid docData:saveData];
                        [newDoc init:self docId:iid docData:(NSMutableDictionary*)([self parse:saveData])];
                        [cacheDocs removeObjectForKey:iid];
                        [cacheDocs setObject:newDoc forKey:iid];
                    }
                }
            }
        } else {
            if (cacheable){
                if (cacheDocs != nil){
                    [cacheDocs removeObjectForKey:iid];
                }
            }
            [sqlHelper deleteData:iid delName:name];
            ret = iid;
        }
    }
    
    return ret;
}

-(NSMutableArray*) getDataListByStartCount: (int) start
                                 listCount: (int) count{
    NSMutableArray* rows = [[NSMutableArray alloc] init];
    NSMutableArray* sqlList = [sqlHelper getStringDataArrayByStartEnd:name startIndex:start dataCount:count];
    if (sqlList != nil){
        for (id dicData in sqlList) {
            if ([dicData isKindOfClass:[NSMutableDictionary class]]){
                NSMutableDictionary* tDic = dicData;
                Document* tmpDoc = [Document alloc];
                NSString* tid = [tDic objectForKey:IDX_ID_KEY];
                //NSString* tName = [tDic objectForKey:IDX_NAME_KEY];
                NSString* tDataStr = [tDic objectForKey:IDX_JSON_KEY];
                NSMutableDictionary* tData = (NSMutableDictionary*)([self parse:tDataStr]);
                [tmpDoc init:self docId:tid docData:tData];
                
                [rows addObject:tmpDoc];
                
                if (count > 0 && [rows count] >= count) break;
            }
        }
    }
    return rows;
}

-(int) size{
    NSUInteger sizeCount = 0;
    if (cacheable && cacheDocs != nil){
        sizeCount = [cacheDocs count];
    } else {
        NSMutableArray* tmpArray = [self list];
        if (tmpArray != nil)
            sizeCount = [tmpArray count];
        //sizeCount = [sqlHelper getDataCount:name];
    }
    return (int)sizeCount;
}

-(NSMutableArray*) list{
    return [self list:nil delayLoad:NO maxData:0];
}

-(NSMutableArray*) list: (IMomockFilter) filter
       delayLoad: (BOOL) dl
         maxData: (int) max{
    NSMutableArray* rows = [[NSMutableArray alloc] init];
    if (cacheable && cacheDocs != nil){
        for (NSString* key in cacheDocs) {
            Document* tmpDoc = [cacheDocs objectForKey:key];
            NSString* iid = [tmpDoc getId];
            if (filter == nil){
                [rows addObject:tmpDoc];
            } else {
                NSDictionary* dicData = [tmpDoc getData];
                if (filter(iid, dicData)){
                    [rows addObject:tmpDoc];
                }
            }
            if (max > 0 && [rows count] >= max) break;
        }
        return rows;
    }
    
    if (sqlHelper != nil){
        NSMutableArray* sqlList = [sqlHelper getStringDataArray:name];
        if (sqlList != nil){
            for (id dicData in sqlList) {
                if ([dicData isKindOfClass:[NSMutableDictionary class]]){
                    NSMutableDictionary* tDic = dicData;
                    Document* tmpDoc = [Document alloc];
                    NSString* tid = [tDic objectForKey:IDX_ID_KEY];
                    //NSString* tName = [tDic objectForKey:IDX_NAME_KEY];
                    NSString* tDataStr = [tDic objectForKey:IDX_JSON_KEY];
                    NSMutableDictionary* tData = (NSMutableDictionary*)([self parse:tDataStr]);
                    [tmpDoc init:self docId:tid docData:tData];
                    
                    if (filter == nil){
                        [rows addObject:tmpDoc];
                    } else {
                        NSDictionary* dicData = [tmpDoc getData];
                        if (filter(tid, dicData)){
                            [rows addObject:tmpDoc];
                        }
                    }
                    if (max > 0 && [rows count] >= max) break;
                }
            }
        }
        
        return rows;
    }
    
    return nil;
}

-(BOOL) isCacheable{
    return cacheable;
}

-(void) setCacheableStatus:(BOOL)cache{
    if (cacheable != cache){
        if(cache){
            cacheDocs = [NSMutableDictionary dictionaryWithCapacity:2];
            NSMutableArray* arrList = [self list];
            for (Document* doc in arrList) {
                if ([doc isKindOfClass:[Document class]]){
                    [cacheDocs setObject:doc forKey:[doc getId]];
                }
            }
            cacheable = cache;
        }
    }
}

@end


/***
 * JsonDatabase
 */
@implementation MMJsonDatabase

@synthesize sqlHelper;
@synthesize cols;


+(MMJsonDatabase*) get{
    
    MMJsonDatabase* instance = [MMJsonDatabase alloc];
    
    instance.sqlHelper = [MySQLiteOpenHelper getSQLiteDB];
    instance.cols = [NSMutableDictionary dictionaryWithCapacity:2];
    
    return instance;
}

-(Collection*) getCollection: (NSString*) name{
    
    Collection* col = [cols objectForKey:name];
    if (col == nil){
        Collection* nCol = [Collection alloc];
        [nCol init:sqlHelper tagName:name];
        [cols setObject:nCol forKey:name];
    }
    
    return [cols objectForKey:name];
}

-(void) forceClose{
    if (sqlHelper != nil){
        [MySQLiteOpenHelper closeSQLiteDB];
        sqlHelper = nil;
    }
}

@end




