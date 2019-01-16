//
//  CVPIxelBufferTools.m
//  Taker
//
//  Created by qws on 2018/5/29.
//  Copyright © 2018年 com.pepsin.fork.video_taker. All rights reserved.
//

#import "CVPixelBufferTools.h"

@implementation CVPixelBufferTools
+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    static id instance;
    dispatch_once(&onceToken, ^{
        instance = [self new];
    });
    return instance;
}

#pragma mark -
#pragma mark - CVPixelBufferTools

/**
 创建一个无数据的CVPixelBuffer，大小格式和传入的pixelbuffer一样
 
 @param inputPixelBuffer 传入的
 @return 无数据的
 */
+ (CVPixelBufferRef)creatPixelBufferSameStyleWithOtherPixelBuffer:(CVPixelBufferRef)inputPixelBuffer
{
    CVPixelBufferRef outputPixelBuffer = NULL;
    
    size_t pixelWidth  = CVPixelBufferGetWidth(inputPixelBuffer);
    size_t pixelHeight = CVPixelBufferGetHeight(inputPixelBuffer);
    OSType formatType  = CVPixelBufferGetPixelFormatType(inputPixelBuffer);
    
    NSDictionary *outputPixelBufferAttributes = [self createPixelBufferAttributes:inputPixelBuffer];
    
    CVPixelBufferCreate(kCFAllocatorDefault, pixelWidth, pixelHeight,formatType, (__bridge CFDictionaryRef)outputPixelBufferAttributes, &outputPixelBuffer);
    
    return outputPixelBuffer;
}




/**
 把CIImage转化为一个CVPixelBuffer 大小格式和传入的pixelBuffer一样
 
 @param image CIImage
 @param inputPixelBuffer 参考的pixelbuffer
 @return CVPixelBufferRef
 */
+ (CVPixelBufferRef)getPixelBufferFromCIImage:(CIImage *)image pixelBuffer:(CVPixelBufferRef)inputPixelBuffer
{
    if (inputPixelBuffer == NULL) {
        NSLog(@"Error : getPixelBufferFromCIImage image did not have pixelbuffer");
        return nil;
    }
    
    CVPixelBufferRef outputPixelBuffer = [self creatPixelBufferSameStyleWithOtherPixelBuffer:inputPixelBuffer];
    
    CVPixelBufferLockBaseAddress(outputPixelBuffer, 0);
    CIContext *context = [CIContext contextWithOptions:@{kCIContextWorkingFormat : @(kCIFormatRGBAh)}];
    [context render:image toCVPixelBuffer:outputPixelBuffer];
    CVPixelBufferUnlockBaseAddress(outputPixelBuffer, 0);
    CVPixelBufferRetain(outputPixelBuffer);
    return outputPixelBuffer;
}




/**
 把UIImage转化为CVPixelBuffer
 
 @param image UIImage
 @return CVPixelBufferRef
 */
+ (CVPixelBufferRef)getPixelBufferFromUIImage:(UIImage *)image {
    return [self getPixelBufferFromCGImage:image.CGImage];
}



/**
 把CGImage转化为CVPixelBuffer
 
 @param image CGImageRef
 @return CVPixelBufferRef
 */
+ (CVPixelBufferRef)getPixelBufferFromCGImage:(CGImageRef)image {
    CVPixelBufferRef pixelBuffer;
    size_t width = CGImageGetWidth(image);
    size_t height = CGImageGetHeight(image);
    size_t bytePerRow = CGImageGetBytesPerRow(image);
    size_t bitsPerComponent = CGImageGetBitsPerComponent(image);
    CGColorSpaceRef colorSpace = CGImageGetColorSpace(image);
    
    OSType pixelFormatType = kCVPixelFormatType_32BGRA;
    
    NSDictionary *pixelAttributes =
    @{(__bridge NSString *)kCVPixelBufferCGImageCompatibilityKey : @(YES),
      (__bridge NSString *)kCVPixelBufferCGBitmapContextCompatibilityKey : @(YES),
      (__bridge NSString *)kCVPixelBufferWidthKey : @(width),
      (__bridge NSString *)kCVPixelBufferHeightKey : @(height)};
    
    CVReturn ret = CVPixelBufferCreate(kCFAllocatorDefault, width, height, pixelFormatType, (__bridge CFDictionaryRef)pixelAttributes, &pixelBuffer);
    if (ret != kCVReturnSuccess) {
        
    }
    
    CVPixelBufferLockBaseAddress(pixelBuffer, 0);
    void *baseData = CVPixelBufferGetBaseAddress(pixelBuffer);
    CGContextRef context = CGBitmapContextCreate(baseData, width, height, bitsPerComponent, bytePerRow, colorSpace,  kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);
    CGContextConcatCTM(context, CGAffineTransformIdentity);
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), image);
    CGColorSpaceRelease(colorSpace);
    CGContextRelease(context);
    CVPixelBufferUnlockBaseAddress(pixelBuffer, 0);
    
    return pixelBuffer;
}



+ (void)logBitMapInfoForCGImage:(CGImageRef)image {
    size_t width = CGImageGetWidth(image);
    size_t height = CGImageGetHeight(image);
    size_t bitsPerPixel = CGImageGetBitsPerPixel(image);
    size_t bitsPerComponent = CGImageGetBitsPerComponent(image);
    size_t bytesPerRow = CGImageGetBytesPerRow(image);
    CGBitmapInfo info = CGImageGetBitmapInfo(image);
    CGImageAlphaInfo alphainfo = CGImageGetAlphaInfo(image);

    NSLog(
          @"\n"
          "===== %@ =====\n"
          "CGImageGetHeight: %d\n"
          "CGImageGetWidth:  %d\n"
          "CGImageGetColorSpace: %@\n"
          "CGImageGetBitsPerPixel:     %d\n"
          "CGImageGetBitsPerComponent: %d\n"
          "CGImageGetBytesPerRow:      %d\n"
          "CGImageGetBitmapInfo: 0x%.8X\n"
          "  kCGBitmapAlphaInfoMask     = %s\n"
          "  kCGBitmapFloatComponents   = %s\n"
          "  kCGBitmapByteOrderMask     = 0x%.8X\n"
          "  kCGBitmapByteOrderDefault  = %s\n"
          "  kCGBitmapByteOrder16Little = %s\n"
          "  kCGBitmapByteOrder32Little = %s\n"
          "  kCGBitmapByteOrder16Big    = %s\n"
          "  kCGBitmapByteOrder32Big    = %s\n"
          "  kCGImageAlphaNone          = %s\n"
          "  kCGImageAlphaPremultipliedLast    = %s\n"
          "  kCGImageAlphaPremultipliedFirst   = %s\n"
          "  kCGImageAlphaLast          = %s\n"
          "  kCGImageAlphaFirst         = %s\n"
          "  kCGImageAlphaNoneSkipLast  = %s\n"
          "  kCGImageAlphaNoneSkipFirst = %s\n"
          "  kCGImageAlphaOnly    = %s\n",
          @"123",
          (int)width,
          (int)height,
          CGImageGetColorSpace(image),
          (int)bitsPerPixel,
          (int)bitsPerComponent,
          (int)bytesPerRow,
          (unsigned)info,
          (info & kCGBitmapAlphaInfoMask)     ? "YES" : "NO",
          (info & kCGBitmapFloatComponents)   ? "YES" : "NO",
          (info & kCGBitmapByteOrderMask),
          ((info & kCGBitmapByteOrderMask) == kCGBitmapByteOrderDefault)  ? "YES" : "NO",
          ((info & kCGBitmapByteOrderMask) == kCGBitmapByteOrder16Little) ? "YES" : "NO",
          ((info & kCGBitmapByteOrderMask) == kCGBitmapByteOrder32Little) ? "YES" : "NO",
          ((info & kCGBitmapByteOrderMask) == kCGBitmapByteOrder16Big)    ? "YES" : "NO",
          ((info & kCGBitmapByteOrderMask) == kCGBitmapByteOrder32Big)    ? "YES" : "NO",
          (alphainfo == kCGImageAlphaNone) ? "YES" : "NO",
          (alphainfo == kCGImageAlphaPremultipliedLast) ? "YES" : "NO",
          (alphainfo == kCGImageAlphaPremultipliedFirst) ? "YES" : "NO",
          (alphainfo == kCGImageAlphaLast) ? "YES" : "NO",
          (alphainfo == kCGImageAlphaFirst) ? "YES" : "NO",
          (alphainfo == kCGImageAlphaNoneSkipLast) ? "YES" : "NO",
          (alphainfo == kCGImageAlphaNoneSkipFirst) ? "YES" : "NO",
          (alphainfo == kCGImageAlphaOnly) ? "YES" : "NO"
          );
}




/**
 把CVPixelBuffer转化为一个UIImage
 
 @param cvPixelBuffer
 @return UIImage
 */
+ (UIImage *)getUIImageFromCVPixelBuffer:(CVPixelBufferRef)cvPixelBuffer
{
    return [self getUIImageFromCVPixelBuffer:cvPixelBuffer uiOrientation:UIImageOrientationUp];
}




/**
 把CVPixelBuffer转化为一个UIImage
 
 @param cvPixelBuffer
 @param uiOrientation UIImageOrientation
 @return UIImage
 */
+ (UIImage *)getUIImageFromCVPixelBuffer:(CVPixelBufferRef)cvPixelBuffer uiOrientation:(UIImageOrientation)uiOrientation
{
    UIImage *image;
    @autoreleasepool{
        CGImageRef quartzImage = [self getCGImageFromCVPixelBuffer:cvPixelBuffer];
        image = [UIImage imageWithCGImage:quartzImage scale:1.0 orientation:uiOrientation];
        CGImageRelease(quartzImage);
    }
    return (image);
}




/**
 把CVPixelbuffer转化为CGImageRef
 
 @param cvPixelBuffer
 @return CGImageRef
 */
+ (CGImageRef)getCGImageFromCVPixelBuffer:(CVPixelBufferRef)cvPixelBuffer {
    CGImageRef quartzImage;
    @autoreleasepool {
        CVImageBufferRef imageBuffer = cvPixelBuffer;
        CVPixelBufferLockBaseAddress(imageBuffer, 0);
        
        void *baseAddress = CVPixelBufferGetBaseAddress(imageBuffer);
        size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer);
        size_t width = CVPixelBufferGetWidth(imageBuffer);
        size_t height = CVPixelBufferGetHeight(imageBuffer);
        
        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
        CGContextRef context = CGBitmapContextCreate(baseAddress, width, height, 8,
                                                     bytesPerRow, colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);//kCGBitmapByteOrderDefault | kCGImageAlphaNoneSkipLast
        quartzImage = CGBitmapContextCreateImage(context);
        CGContextRelease(context);
        CGColorSpaceRelease(colorSpace);
        CVPixelBufferUnlockBaseAddress(imageBuffer,0);
    }
    return quartzImage;
}




/**
 把pixelBuffer转化为data
 
 @param pixelBuffer 传入的
 @return unsigned char* 的data
 */
+ (unsigned char *)getImageDataFromPixelBuffer:(CVPixelBufferRef)pixelBuffer {
    
    CVPixelBufferLockBaseAddress(pixelBuffer, 0);
    
    void *baseAddress  = CVPixelBufferGetBaseAddress(pixelBuffer);
    size_t bytesPerRow = CVPixelBufferGetBytesPerRow(pixelBuffer); // width * bytesPerPixel;
    size_t width       = CVPixelBufferGetWidth(pixelBuffer);
    size_t height      = CVPixelBufferGetHeight(pixelBuffer);
    size_t bitsPerComponent = 8;
    size_t bytesPerPixel = bytesPerRow / width;
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    CGContextRef context = CGBitmapContextCreate(baseAddress,
                                                 width,
                                                 height,
                                                 bitsPerComponent,
                                                 bytesPerRow,
                                                 colorSpace,
                                                 kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);
    
    unsigned char * imagedata= malloc(width*height*bytesPerPixel);
    
    imagedata = CGBitmapContextGetData(context);
    
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    CVPixelBufferUnlockBaseAddress(pixelBuffer, 0);
    
    return imagedata;
}




/**
 把CMSampleBufferRef转化为UIImage
 
 @param sampleBuffer
 @return UIImage
 */
+ (UIImage *)getUIImageFromSampleBuffer:(CMSampleBufferRef)sampleBuffer
{
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    return [self getUIImageFromCVPixelBuffer:imageBuffer];
}




/**
 创建CVPixelBuffer attributes
 
 @param pixelBuffer 根据pixelBuffer
 @return NSDictionary
 */
+ (NSDictionary *)createPixelBufferAttributes:(CVPixelBufferRef)pixelBuffer
{
    NSArray *properties = [self getPixelBufferProperties:pixelBuffer];
    
    NSMutableDictionary *outputPixelBufferAttributes = [NSMutableDictionary dictionary];
    [outputPixelBufferAttributes setObject:properties[QSPixelPropertyFormat] forKey:(__bridge NSString *) kCVPixelBufferPixelFormatTypeKey];
    [outputPixelBufferAttributes setObject:properties[QSPixelPropertyWidth] forKey:(__bridge NSString *) kCVPixelBufferWidthKey];
    [outputPixelBufferAttributes setObject:properties[QSPixelPropertyHeight] forKey:(__bridge NSString *) kCVPixelBufferHeightKey];
    [outputPixelBufferAttributes setObject:@{} forKey:(__bridge NSString *) kCVPixelBufferIOSurfacePropertiesKey];
    
    return outputPixelBufferAttributes;
}




/**
 获取Pixelbuffer的属性
 
 @param pixelBuffer
 @return NSArray
 */
+ (NSArray *)getPixelBufferProperties:(CVPixelBufferRef)pixelBuffer
{
    NSMutableArray *arr = [NSMutableArray array];
    size_t pixelWidth  = CVPixelBufferGetWidth(pixelBuffer);
    size_t pixelHeight = CVPixelBufferGetHeight(pixelBuffer);
    OSType formatType  = CVPixelBufferGetPixelFormatType(pixelBuffer);
    size_t bytesPerRow = CVPixelBufferGetBytesPerRow(pixelBuffer);
    
    arr[QSPixelPropertyWidth] = @(pixelWidth);
    arr[QSPixelPropertyHeight] = @(pixelHeight);
    arr[QSPixelPropertyFormat] = @(formatType);
    arr[QSPixelPropertyBytesPerRow] = @(bytesPerRow);
    
    return arr;
}




/**
 获取PixelBuffer的formatDescription
 
 @param pixelBuffer
 @return CMFormatDescriptionRef
 */
+ (CMFormatDescriptionRef)getPixelBufferFormatDescription:(CVPixelBufferRef)pixelBuffer {
    CMFormatDescriptionRef formatDescription;
    CMVideoFormatDescriptionCreateForImageBuffer(kCFAllocatorDefault, pixelBuffer, &formatDescription);
    return formatDescription;
}




/**
 重设CVPixelBuffer 的size
 
 @param pixelBuffer 传入的
 @param newSize 新的size
 @return 新的CVPixelBufferRef
 */
+ (CVPixelBufferRef)resizePixelBufferWith:(CVPixelBufferRef)pixelBuffer newSize:(CGSize)newSize
{
    CIImage *inputImage = [CIImage imageWithCVPixelBuffer:pixelBuffer];
    
    CGRect extent = inputImage.extent;
    CGFloat x = (extent.size.width - newSize.width) / 2;
    CGFloat y = (extent.size.height - newSize.height) / 2;
    CGRect cropRect = CGRectMake(x, y, newSize.width, newSize.height);
    
    CIImage *outputImg = [inputImage imageByCroppingToRect:cropRect];
    CVPixelBufferRef outputPixelBuffer = [self getPixelBufferFromCIImage:outputImg pixelBuffer:pixelBuffer];
    
    return outputPixelBuffer;
}



@end
