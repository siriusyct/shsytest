//
//  MMImageHolder.h
//  Go2ReachSample
//
//  Created by apple on 15/10/22.
//  Copyright © 2015年 Gmobi. All rights reserved.
//

#ifndef momock_MMImageHolder_h
#define momock_MMImageHolder_h

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#define MMIMAGE_PREFIX_HTTP @"http://"
#define MMIMAGE_PREFIX_HTTPS @"https://"
#define MMIMAGE_PREFIX_FILE @"file://"
#define MMIMAGE_PREFIX_RES @"res://"

#define MMIMAGE_GIF_IMAGES @"gif_images"
#define MMIMAGE_GIF_TIMES @"gif_times"
#define MMIMAGE_GIF_TOTALTIME @"gif_totaltime"

@protocol MMImageHolderDelegate <NSObject>

-(void) imageLoaded: (NSString*) uri
            uiImage: (UIImage*) uiImage;

@end

@interface MMImageHolder : NSObject

@property BOOL isDownloading;
@property NSString* imageUri;
@property id<MMImageHolderDelegate> loadedDelegate;

+(MMImageHolder*) get: (NSString*) uri
        expectedWidth: (int) expectedWidth
       expectedHeight: (int) expectedHeight;

-(BOOL) isLoaded;
-(UIImage*) getAsUIImage;
-(BOOL) isGIFImage;
-(NSMutableDictionary*) getGifDatas;

@end

#endif /* MMImageHolder_h */
