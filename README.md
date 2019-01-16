# CVPixelBufferTools
CVPixelBuffer 工具集（CVPixelBuffer 与UIImage,CIImage,CGImage相互转化）


//Image to CVPixelBuffer 
+ (CVPixelBufferRef)getPixelBufferFromUIImage:(UIImage *)image;
+ (CVPixelBufferRef)getPixelBufferFromCGImage:(CGImageRef)image;
//从CIImage获取PixelBuffer，需要传入一个参考PixelBuffer（使用其格式）
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

//创建一个空的（黑）PixelBuffer,格式参数和传入的PixelBuffer相同
+ (CVPixelBufferRef)creatPixelBufferSameStyleWithOtherPixelBuffer:(CVPixelBufferRef)inputPixelBuffer;
//调整pixelBuffer的Size
+ (CVPixelBufferRef)resizePixelBufferWith:(CVPixelBufferRef)pixelBuffer newSize:(CGSize)newSize;

//Log
+ (void)logBitMapInfoForCGImage:(CGImageRef)image;
