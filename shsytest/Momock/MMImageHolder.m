//
//  MMImageHolder.m
//  Go2ReachSample
//
//  Created by apple on 15/10/22.
//  Copyright © 2015年 Gmobi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ImageIO/ImageIO.h>
#import "MMImageHolder.h"
#import "MMSystemHelper.h"
#import "MMHttpSession.h"

@implementation MMImageHolder

-(NSString*) getFullUri: (NSString*) uri
                  width: (int) width
                 height: (int) height{
    if (uri == nil) return nil;
    if (width != 0 && height != 0){
        return [NSString stringWithFormat:@"%@#%dx%d", uri, width, height];
    }
    return uri;
}

-(NSString*) getCacheFile: (NSString*) uri{
    if (uri == nil) return nil;
    NSString* cacheFolder = [MMSystemHelper getMMCacheFolder];
    NSString* md5Str = [MMSystemHelper getMd5String:uri];
    
    return [NSString stringWithFormat:@"%@/%@", cacheFolder, md5Str];
}

+(MMImageHolder*) get: (NSString*) uri
        expectedWidth: (int) expectedWidth
       expectedHeight: (int) expectedHeight{
    MMImageHolder* imageHld = [MMImageHolder alloc];
    NSString* imUri = [imageHld getFullUri:uri width:expectedWidth height:expectedHeight];
    
    [imageHld setImageUri:imUri];
    
    return imageHld;
}

-(BOOL) isLoaded{
    NSString* file = [self getCacheFile:self.imageUri];
    
    if (file == nil) return NO;
    
    NSFileManager *fileMgr = [NSFileManager defaultManager];
    BOOL isDir = NO;
    BOOL fileExist = [fileMgr fileExistsAtPath:file isDirectory:&isDir];
    
    return fileExist;
}

-(UIImage*) getAsUIImage{
    
    NSString* file = [self getCacheFile:self.imageUri];
    
    if (file == nil) return nil;
    
    NSFileManager *fileMgr = [NSFileManager defaultManager];
    BOOL isDir = NO;
    BOOL fileExist = [fileMgr fileExistsAtPath:file isDirectory:&isDir];
    if (fileExist == NO){
        [self downloadImage];
    } else {
        return [UIImage imageWithContentsOfFile:file];
    }
    
    return nil;
}


-(void) downloadImage{
    if (self.imageUri == nil || self.isDownloading == YES)
        return;
    
    self.isDownloading = YES;
    NSString* localFile = [self getCacheFile:self.imageUri];
    //download image
    MMHttpSession* httpSession = [MMHttpSession alloc];
    [httpSession download:self.self.imageUri reqHeader:nil filePath:localFile callback:^(int status, int code, NSDictionary *resultData) {
        self.isDownloading = NO;
        if (code == 200){
            if (self.loadedDelegate != nil &&
                [self.loadedDelegate respondsToSelector:@selector(imageLoaded:uiImage:)]) {
                [self.loadedDelegate imageLoaded:self.imageUri uiImage:[self getAsUIImage]];
            }
        }
    } progressCallback:nil];
}

-(BOOL) isGIFImage{
    NSString* file = [self getCacheFile:self.imageUri];
    
    if (file == nil) return NO;
    
    NSURL* fileUrl = [NSURL fileURLWithPath:file];
    CGImageSourceRef gifSource = CGImageSourceCreateWithURL((CFURLRef)fileUrl, NULL);
    if (gifSource == nil) return NO;
    size_t count = CGImageSourceGetCount(gifSource);
    if (count > 1){
        return YES;
    }
    
    return NO;
}

-(NSMutableDictionary*) getGifDatas{
    NSString* file = [self getCacheFile:self.imageUri];
    
    if (file == nil) return nil;
    
    NSURL* fileUrl = [NSURL fileURLWithPath:file];
    CGImageSourceRef gifSource = CGImageSourceCreateWithURL((CFURLRef)fileUrl, NULL);
    if (gifSource == nil) return nil;
    size_t count = CGImageSourceGetCount(gifSource);
    if (count > 1){
        NSMutableDictionary* ret = [NSMutableDictionary dictionaryWithCapacity:1];
        
        NSMutableArray *images = [NSMutableArray arrayWithCapacity:1];
        NSMutableArray *times = [NSMutableArray arrayWithCapacity:1];
        NSMutableArray *keyTimes = [NSMutableArray arrayWithCapacity:1];
        
        float totalTime = 0;
        for (size_t i = 0; i < count; i++) {
            CGImageRef cgimage= CGImageSourceCreateImageAtIndex(gifSource, i, NULL);
            [images addObject:(__bridge id)cgimage];
            CGImageRelease(cgimage);
            
            NSDictionary *properties = (__bridge NSDictionary *)CGImageSourceCopyPropertiesAtIndex(gifSource, i, NULL);
            NSDictionary *gifProperties = [properties valueForKey:(__bridge NSString *)kCGImagePropertyGIFDictionary];
            NSString *gifDelayTime = [gifProperties valueForKey:(__bridge NSString* )kCGImagePropertyGIFDelayTime];
            [times addObject:gifDelayTime];
            totalTime += [gifDelayTime floatValue];
            
            //_size.width = [[properties valueForKey:(NSString*)kCGImagePropertyPixelWidth] floatValue];
            //_size.height = [[properties valueForKey:(NSString*)kCGImagePropertyPixelHeight] floatValue];
        }
        
        float currentTime = 0;
        for (size_t i = 0; i < times.count; i++) {
            float keyTime = currentTime / totalTime;
            [keyTimes addObject:[NSNumber numberWithFloat:keyTime]];
            currentTime += [[times objectAtIndex:i] floatValue];
        }
        
        [ret setObject:images forKey:MMIMAGE_GIF_IMAGES];
        [ret setObject:keyTimes forKey:MMIMAGE_GIF_TIMES];
        NSNumber* tt = [[NSNumber alloc] initWithFloat:totalTime];
        [ret setObject:tt forKey:MMIMAGE_GIF_TOTALTIME];
        
        return ret;
    }
    
    return nil;
}


@end