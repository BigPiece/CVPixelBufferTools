//
//  CVPIxelBufferTools.h
//  Taker
//
//  Created by qws on 2018/5/29.
//  Copyright © 2018年 com.pepsin.fork.video_taker. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, QSPixelProperty) {
    QSPixelPropertyWidth,
    QSPixelPropertyHeight,
    QSPixelPropertyFormat,
    QSPixelPropertyBytesPerRow,
    
};
@interface CVPixelBufferTools : NSObject
+ (instancetype)sharedInstance;
//Image to CVPixelBuffer
+ (CVPixelBufferRef)getPixelBufferFromUIImage:(UIImage *)image;
+ (CVPixelBufferRef)getPixelBufferFromCGImage:(CGImageRef)image;
+ (CVPixelBufferRef)getPixelBufferFromCIImage:(CIImage *)image pixelBuffer:(CVPixelBufferRef)inputPixelBuffer;

//CVPixelBuffer to iamge/data
+ (UIImage *)getUIImageFromSampleBuffer:(CMSampleBufferRef)sampleBuffer;
+ (UIImage *)getUIImageFromCVPixelBuffer:(CVPixelBufferRef)cvPixelBuffer;
+ (UIImage *)getUIImageFromCVPixelBuffer:(CVPixelBufferRef)cvPixelBuffer uiOrientation:(UIImageOrientation)uiOrientation;
+ (CGImageRef)getCGImageFromCVPixelBuffer:(CVPixelBufferRef)cvPixelBuffer;
+ (unsigned char *)getImageDataFromPixelBuffer:(CVPixelBufferRef)pixelBuffer;

//get CVPixelBuffer Properties
+ (NSDictionary *)createPixelBufferAttributes:(CVPixelBufferRef)pixelBuffer;
+ (NSArray *)getPixelBufferProperties:(CVPixelBufferRef)pixelBuffer;
+ (CMFormatDescriptionRef)getPixelBufferFormatDescription:(CVPixelBufferRef)pixelBuffer;

//modify CVPixelBuffer
+ (CVPixelBufferRef)creatPixelBufferSameStyleWithOtherPixelBuffer:(CVPixelBufferRef)inputPixelBuffer;
+ (CVPixelBufferRef)resizePixelBufferWith:(CVPixelBufferRef)pixelBuffer newSize:(CGSize)newSize;

//Log
+ (void)logBitMapInfoForCGImage:(CGImageRef)image;

@end
