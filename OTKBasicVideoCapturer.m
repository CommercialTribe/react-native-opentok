//
//  OTKBasicVideoCapturer.m
//  Getting Started
//
//  Created by rpc on 03/03/15.
//  Copyright (c) 2015 OpenTok. All rights reserved.
//

#import "OTKBasicVideoCapturer.h"
#define kFramesPerSecond 15
#define kImageWidth 160
#define kImageHeight 320
#define kTimerInterval dispatch_time(DISPATCH_TIME_NOW, (int64_t)((1 / kFramesPerSecond) * NSEC_PER_SEC))

@interface OTKBasicVideoCapturer ()
@property (nonatomic, assign) BOOL captureStarted;
@property (nonatomic, strong) OTVideoFormat *format;
- (void)produceFrame;
@end

@implementation OTKBasicVideoCapturer

@synthesize videoCaptureConsumer;

- (void)initCapture
{
    self.format = [[OTVideoFormat alloc] init];
    self.format.pixelFormat = OTPixelFormatARGB;
    self.format.bytesPerRow = [@[@(kImageWidth * 4)] mutableCopy];
    self.format.imageHeight = kImageHeight;
    self.format.imageWidth = kImageWidth;
    
//    self.format = [OTVideoFormat videoFormatNV12WithWidth:320 height:480];
}

- (void)releaseCapture
{
    self.format = nil;
}

- (int32_t)startCapture
{
    self.captureStarted = YES;
    dispatch_after(kTimerInterval,
                   dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0),
                   ^{
                       [self produceFrame];
                   });
    
    return 0;
}

- (int32_t)stopCapture
{
    self.captureStarted = NO;
    return 0;
}

- (BOOL)isCaptureStarted
{
    return self.captureStarted;
}

- (int32_t)captureSettings:(OTVideoFormat*)videoFormat
{
    return 0;
}

- (void)produceFrame
{
    NSLog(@"producing a frame");
    OTVideoFrame *frame = [[OTVideoFrame alloc] initWithFormat:self.format];
    
    // Generate a image with random pixels
    u_int8_t *imageData[1];
    imageData[0] = malloc(sizeof(uint8_t) * kImageHeight * kImageWidth * 4);
    for (int i = 0; i < kImageHeight; i++) {
        int baseRow = i * kImageWidth * 4;
        for(int j = 0; j < kImageWidth; j++) {
            int baseAddres = baseRow + j * 4;
            imageData[0][baseAddres] = 255;   // A
            imageData[0][baseAddres+1] = (i+j)/3 % 255; // R
            imageData[0][baseAddres+2] = (i-j)/3 % 255; // G
            imageData[0][baseAddres+3] = (i + j + j)/3 % 255; // B
        }
    }
//    frame.orientation = OTVideoOrientationLeft;
    [frame setPlanesWithPointers:imageData numPlanes:1];
    [self.videoCaptureConsumer consumeFrame:frame];
    
    free(imageData[0]);
    
    if (self.captureStarted) {
        dispatch_after(kTimerInterval,
                       dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0),
                       ^{
                           [self produceFrame];
                       });
    }
}

@end




////
////  OTKBasicVideoCapturer.m
////  Getting Started
////
////  Created by rpc on 03/03/15.
////  Copyright (c) 2015 OpenTok. All rights reserved.
////
//
//#import <AVFoundation/AVFoundation.h>
//#import "OTKBasicVideoCapturer.h"
//#import <math.h>
//
//@interface OTKBasicVideoCapturer ()<AVCaptureVideoDataOutputSampleBufferDelegate>
//@property (nonatomic, assign) BOOL captureStarted;
//@property (nonatomic, strong) OTVideoFormat *format;
//@property (nonatomic, strong) AVCaptureSession *captureSession;
//@property (nonatomic, strong) AVCaptureDeviceInput *inputDevice;
//@property (nonatomic, strong) NSString *sessionPreset;
//@property (nonatomic, assign) NSUInteger imageWidth;
//@property (nonatomic, assign) NSUInteger imageHeight;
//@property (nonatomic, assign) NSUInteger desiredFrameRate;
//@property (nonatomic, strong) dispatch_queue_t captureQueue;
//
//- (CGSize)sizeFromAVCapturePreset:(NSString *)capturePreset;
//- (double)bestFrameRateForDevice;
//@end
//
//@implementation OTKBasicVideoCapturer
//@synthesize videoCaptureConsumer;
//
//- (id)initWithPreset:(NSString *)preset andDesiredFrameRate:(NSUInteger)frameRate
//{
//    self = [super init];
//    if (self) {
//        self.sessionPreset = preset;
//        CGSize imageSize = [self sizeFromAVCapturePreset:self.sessionPreset];
//        _imageHeight = imageSize.height;
//        _imageWidth = imageSize.width;
//        _desiredFrameRate = frameRate;
//
//        _captureQueue = dispatch_queue_create("com.tokbox.OTKBasicVideoCapturer",DISPATCH_QUEUE_SERIAL);
//    }
//    return self;
//}
//
//- (void)initCapture
//{
//    NSError *error;
//    self.captureSession = [[AVCaptureSession alloc] init];
//
//    [self.captureSession beginConfiguration];
//
//    // Set device capture
//    self.captureSession.sessionPreset = self.sessionPreset;
//    AVCaptureDevice *videoDevice = [self frontCamera];
//    self.inputDevice = [AVCaptureDeviceInput deviceInputWithDevice:videoDevice error:&error];
//    [self.captureSession addInput:self.inputDevice];
//
//
//    AVCaptureVideoDataOutput *outputDevice = [[AVCaptureVideoDataOutput alloc] init];
//    outputDevice.alwaysDiscardsLateVideoFrames = YES;
//    outputDevice.videoSettings = @{
//                                   (NSString *)kCVPixelBufferPixelFormatTypeKey:@(kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange)
//                                   };
//
//    [outputDevice setSampleBufferDelegate:self queue:self.captureQueue];
//
//    [self.captureSession addOutput:outputDevice];
//
//    // Set framerate
//    double bestFrameRate = [self bestFrameRateForDevice];
//
//    CMTime desiredMinFrameDuration = CMTimeMake(1, bestFrameRate);
//    CMTime desiredMaxFrameDuration = CMTimeMake(1, bestFrameRate);
//
//    [self.inputDevice.device lockForConfiguration:&error];
//    self.inputDevice.device.activeVideoMaxFrameDuration = desiredMaxFrameDuration;
//    self.inputDevice.device.activeVideoMinFrameDuration = desiredMinFrameDuration;
//
//    [self.captureSession commitConfiguration];
//
//    self.format = [OTVideoFormat videoFormatNV12WithWidth:320
//                                                   height:480];
//}
//
//- (void)releaseCapture
//{
//    self.format = nil;
//}
//
//- (int32_t)startCapture
//{
//    self.captureStarted = YES;
//    [self.captureSession startRunning];
//
//    return 0;
//}
//
//- (int32_t)stopCapture
//{
//    self.captureStarted = NO;
//    [self.captureSession stopRunning];
//    return 0;
//}
//
//- (BOOL)isCaptureStarted
//{
//    return self.captureStarted;
//}
//
//- (int32_t)captureSettings:(OTVideoFormat*)videoFormat
//{
//     // @TODO: shouldnt we use self.format to copy the values from?
//    videoFormat.pixelFormat = OTPixelFormatNV12;
//    videoFormat.imageWidth = 320; // self.imageWidth; -- this is wrong
//    videoFormat.imageHeight = 480; // self.imageHeight; -- this is wrong
//
//    return 0;
//}
//
//#pragma mark - AVCaptureVideoDataOutputSampleBufferDelegate
//
//- (void)captureOutput:(AVCaptureOutput *)captureOutput
//  didDropSampleBuffer:(CMSampleBufferRef)sampleBuffer
//       fromConnection:(AVCaptureConnection *)connection
//{
//    NSLog(@"Frame dropped");
//}
//
//- (void)captureOutput:(AVCaptureOutput *)captureOutput
//didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer
//       fromConnection:(AVCaptureConnection *)connection
//{
//    if (!self.captureStarted)
//        return;
//
//    int cropX0 = 0, cropY0 = 0, cropHeight = 480, cropWidth = 320;
//
//    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
//    OTVideoFrame *frame = [[OTVideoFrame alloc] initWithFormat:self.format];
//
//    NSUInteger planeCount = CVPixelBufferGetPlaneCount(imageBuffer);
//
////    uint8_t *buffer = malloc(sizeof(uint8_t) * CVPixelBufferGetDataSize(imageBuffer));
//    uint8_t *buffer = malloc(sizeof(uint8_t) * cropWidth * cropHeight * 12 ); //12 = NVI, but take it from other place
//    uint8_t *dst = buffer;
//    uint8_t *planes[planeCount];
//    uint8_t *rowBaseAddress;
//
//    CVPixelBufferLockBaseAddress(imageBuffer, 0);
//    for (int i = 0; i < planeCount; i++) {
//        // Account for UV plane.
//        double uvReduction = pow(2, -i);
//        cropHeight = (int) (cropHeight * uvReduction);
//        cropWidth = (int) (cropWidth * uvReduction);
//        
//        int inputBytesPerRow = CVPixelBufferGetBytesPerRowOfPlane(imageBuffer, i);
//        int inputWidth = CVPixelBufferGetWidthOfPlane(imageBuffer, i);
//        int inputHeight = CVPixelBufferGetHeightOfPlane(imageBuffer, i);
//        int bytesPerPixel = inputBytesPerRow / inputWidth; // 8 or 4 I believe
//
//        // size_t planeSize = inputBytesPerRow * inputHeight;
//        // size_t outPlaneSize = bytesPerPixel * cropWidth * cropHeight;
//
//        int bytesToCopyPerRow = cropWidth * bytesPerPixel;
//
//        rowBaseAddress = CVPixelBufferGetBaseAddressOfPlane(imageBuffer, i);
//        planes[i] = dst;
//        for (int row = 0; row < cropHeight; row++) { // for each row
//
//            memcpy(dst,
//                   rowBaseAddress,
//                   bytesToCopyPerRow);
//
//            rowBaseAddress += inputBytesPerRow;
//            dst += bytesToCopyPerRow;
//        }
//
//    }
//
//    CMTime minFrameDuration = self.inputDevice.device.activeVideoMinFrameDuration;
//    frame.format.estimatedFramesPerSecond = minFrameDuration.timescale / minFrameDuration.value;
//    frame.format.estimatedCaptureDelay = 100;
//    frame.orientation = [self currentDeviceOrientation];
//
//    CMTime time = CMSampleBufferGetPresentationTimeStamp(sampleBuffer);
//    frame.timestamp = time;
//    [frame setPlanesWithPointers:planes numPlanes:planeCount];
//
//    [self.videoCaptureConsumer consumeFrame:frame];
//
//    free(buffer);
//    CVPixelBufferUnlockBaseAddress(imageBuffer, 0);
//}
//
//#pragma mark - Private methods
//
//- (CGSize)sizeFromAVCapturePreset:(NSString *)capturePreset
//{
//    if ([capturePreset isEqualToString:AVCaptureSessionPreset1280x720])
//        return CGSizeMake(1280, 720);
//    if ([capturePreset isEqualToString:AVCaptureSessionPreset1920x1080])
//        return CGSizeMake(1920, 1080);
//    if ([capturePreset isEqualToString:AVCaptureSessionPreset640x480])
//        return CGSizeMake(640, 480);
//    if ([capturePreset isEqualToString:AVCaptureSessionPreset352x288])
//        return CGSizeMake(352, 288);
//
//    // Not supported preset
//    return CGSizeMake(0, 0);
//}
//
//- (OTVideoOrientation)currentDeviceOrientation
//{
//    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
//    if (AVCaptureDevicePositionFront == self.inputDevice.device.position) {
//        switch (orientation) {
//            case UIInterfaceOrientationLandscapeLeft:
//                return OTVideoOrientationUp;
//            case UIInterfaceOrientationLandscapeRight:
//                return OTVideoOrientationDown;
//            case UIInterfaceOrientationPortrait:
//                return OTVideoOrientationLeft;
//            case UIInterfaceOrientationPortraitUpsideDown:
//                return OTVideoOrientationRight;
//            default:
//                return OTVideoOrientationUp;
//        }
//    } else {
//        switch (orientation) {
//            case UIInterfaceOrientationLandscapeLeft:
//                return OTVideoOrientationDown;
//            case UIInterfaceOrientationLandscapeRight:
//                return OTVideoOrientationUp;
//            case UIInterfaceOrientationPortrait:
//                return OTVideoOrientationLeft;
//            case UIInterfaceOrientationPortraitUpsideDown:
//                return OTVideoOrientationRight;
//            default:
//                return OTVideoOrientationUp;
//        }
//    }
//}
//
//- (double)bestFrameRateForDevice
//{
//    double bestFrameRate = 0;
//    for (AVFrameRateRange* range in
//         self.inputDevice.device.activeFormat.videoSupportedFrameRateRanges)
//    {
//        CMTime currentDuration = range.minFrameDuration;
//        double currentFrameRate = currentDuration.timescale / currentDuration.value;
//        if (currentFrameRate > bestFrameRate && currentFrameRate < self.desiredFrameRate) {
//            bestFrameRate = currentFrameRate;
//        }
//    }
//    return bestFrameRate;
//}
//
//- (AVCaptureDevice *)frontCamera
//{
//    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
//    for (AVCaptureDevice *device in devices) {
//        if ([device position] == AVCaptureDevicePositionFront) {
//            return device;
//        }
//    }
//    return nil;
//}
//
//@end