//
//  MealCameraController.m
//  TrueBite
//
//  Created by Brian Wong on 9/5/16.
//  Copyright © 2016 Brian Wong. All rights reserved.
//

#import "MealCameraController.h"
#import "FoodwiseDefines.h"
#import "UIFont+Extension.h"
#import "LayoutBounds.h"
#import "PriceFilterView.h"
#import "AssetSendViewController.h"

#import <AVFoundation/AVFoundation.h>

@interface MealCameraController()<UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIPickerViewDelegate, UIPickerViewDataSource, UIGestureRecognizerDelegate, PriceFilterDelegate>

@property (nonatomic, strong) AVCaptureSession *captureSession;
@property (nonatomic, strong) AVCaptureStillImageOutput *stillImageOutput;
@property (nonatomic, strong) AVCaptureDevice *captureDevice;
@property (nonatomic, strong) UIImage *capturedImage;

@property (nonatomic, strong) UIImageView *selectedImageView;

@property (nonatomic, strong) UIButton *captureButton;
@property (nonatomic, strong) UIButton *flashButton;
@property (nonatomic, strong) UIButton *orientationButton;
@property (nonatomic, strong) UIButton *cancelButton;

@property (nonatomic, strong) UIPinchGestureRecognizer *pinchToZoom;
@property (nonatomic, strong) UITapGestureRecognizer *tapToFocus;
@property (nonatomic, strong) UIImageView *focusView;

@end

@implementation MealCameraController

#define MIN_ZOOM 1
#define MAX_ZOOM 3

dispatch_queue_t sessionQueue;

static CGFloat previousZoom;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.captureSession = [[AVCaptureSession alloc]init];
    [self.captureSession setSessionPreset:AVCaptureSessionPresetPhoto];
    
    self.captureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    NSError *error;
    AVCaptureDeviceInput *deviceInput = [AVCaptureDeviceInput deviceInputWithDevice:self.captureDevice error:&error];
    
    if ([self.captureDevice lockForConfiguration:&error]) {
        [self.captureDevice setFlashMode:AVCaptureFlashModeAuto];
        [self.captureDevice unlockForConfiguration];
    }
    
    if ([self.captureSession canAddInput:deviceInput]) {
        [self.captureSession addInput:deviceInput];
    }
    
    AVCaptureVideoPreviewLayer *previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.captureSession];
    [previewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    CALayer *rootLayer = [self.view layer];
    [rootLayer setMasksToBounds:YES];
    CGRect frame = self.view.frame;
    [previewLayer setFrame:frame];
    [rootLayer insertSublayer:previewLayer atIndex:0];
    
    self.stillImageOutput = [[AVCaptureStillImageOutput alloc] init];
    NSDictionary *outputSettings = [[NSDictionary alloc] initWithObjectsAndKeys:AVVideoCodecJPEG, AVVideoCodecKey, nil];
    [self.stillImageOutput setOutputSettings:outputSettings];
    
    [self.captureSession addOutput:self.stillImageOutput];
    [self.captureSession startRunning];

    [self setupCameraControls];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)presentImage:(UIImage*)capturedImage
{
    AssetSendViewController *assetSendView = [[AssetSendViewController alloc]init];
    assetSendView.selectedImage = self.capturedImage;
    assetSendView.selectedRestaurant = self.selectedRestaurant;
    [self.navigationController pushViewController:assetSendView animated:NO];
}

- (void)setupCameraControls
{
    self.captureButton = [[UIButton alloc]initWithFrame:CGRectMake(self.view.frame.size.width/2 - self.view.frame.size.height * 0.075, self.view.frame.size.height * 0.85, self.view.frame.size.height * 0.15, self.view.frame.size.height * 0.15)];
    self.captureButton.backgroundColor = [UIColor clearColor];
    [self.captureButton setImage:[UIImage imageNamed:@"capture"] forState:UIControlStateNormal];
    [self.captureButton addTarget:self action:@selector(takePhoto:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.captureButton];
    
    self.flashButton = [[UIButton alloc]initWithFrame:CGRectMake(CGRectGetMaxX(self.captureButton.frame), CGRectGetMaxY(self.captureButton.frame) - self.view.frame.size.height * 0.12, self.view.frame.size.height * 0.12, self.view.frame.size.height * 0.12)];
    self.flashButton.backgroundColor = [UIColor clearColor];
    [self.flashButton setImage:[[UIImage imageNamed:@"flash_auto"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forState:UIControlStateNormal];
    [self.flashButton addTarget:self action:@selector(toggleFlashMode) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.flashButton];
    
    self.orientationButton = [[UIButton alloc]initWithFrame:CGRectMake(CGRectGetMinX(self.captureButton.frame) - self.view.frame.size.height * 0.12, CGRectGetMaxY(self.captureButton.frame) - self.view.frame.size.height * 0.12, self.view.frame.size.height * 0.12, self.view.frame.size.height * 0.12)];
    self.orientationButton.backgroundColor = [UIColor clearColor];
    [self.orientationButton setImage:[UIImage imageNamed:@"flip_camera"] forState:UIControlStateNormal];
    [self.orientationButton addTarget:self action:@selector(flipCamera) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.orientationButton];
    
    self.cancelButton = [[UIButton alloc]initWithFrame:CGRectMake(CGRectGetMinX(self.orientationButton.frame) - self.view.frame.size.height * 0.09, CGRectGetMaxY(self.captureButton.frame) - self.view.frame.size.height * 0.11, self.view.frame.size.height * 0.12, self.view.frame.size.height * 0.12)];
    self.cancelButton.backgroundColor = [UIColor clearColor];
    [self.cancelButton setImage:[UIImage imageNamed:@"exit"] forState:UIControlStateNormal];
    [self.cancelButton addTarget:self action:@selector(exitCamera) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.cancelButton];
    
    self.pinchToZoom = [[UIPinchGestureRecognizer alloc]initWithTarget:self action:@selector(handlePinchToZoomRecognizer:)];
    [self.view addGestureRecognizer:self.pinchToZoom];
    
    self.focusView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.height * 0.1, self.view.frame.size.height * 0.1)];
    self.focusView.backgroundColor = [UIColor clearColor];
    self.focusView.contentMode = UIViewContentModeScaleAspectFit;
    self.focusView.alpha = 0.0;
    [self.focusView setImage:[UIImage imageNamed:@"auto_focus"]];
    [self.view addSubview:self.focusView];
    
    self.tapToFocus = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleTapToFocus:)];
    [self.view addGestureRecognizer:self.tapToFocus];
    
    sessionQueue = dispatch_queue_create( "com.apple.sample.capturepipeline.session", DISPATCH_QUEUE_SERIAL );
}

#pragma mark UI Convenience methods

- (void)exitCamera
{
    [self.navigationController popViewControllerAnimated:NO];
}

- (void)takePhoto:(UIButton *)sender {
    AVCaptureConnection *videoConnection = nil;
    for (AVCaptureConnection *connection in self.stillImageOutput.connections) {
        for (AVCaptureInputPort *port in [connection inputPorts]) {
            if ([[port mediaType] isEqual:AVMediaTypeVideo]) {
                videoConnection = connection;
                break;
            }
        }
        if (videoConnection) {
            break;
        }
    }
    
    [self.stillImageOutput captureStillImageAsynchronouslyFromConnection:videoConnection completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
        if (imageDataSampleBuffer) {
            NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
            UIImage *image = [UIImage imageWithData:imageData];
            
            //Front camera mirrors photo, so unmirror it
            AVCaptureInput* currentCameraInput = [_captureSession.inputs objectAtIndex:0];
            if(((AVCaptureDeviceInput*)currentCameraInput).device.position == AVCaptureDevicePositionFront){
                image = [UIImage imageWithCGImage:image.CGImage scale:image.scale orientation:UIImageOrientationLeftMirrored];
            }
            
            self.capturedImage = image;
            [self presentImage:self.capturedImage];
        }
    }];
}

- (void)toggleFlashMode
{
    AVCaptureDevice *device = self.captureDevice;
    AVCaptureFlashMode flashMode = self.captureDevice.flashMode;
    if (device.hasFlash && [device isFlashModeSupported:flashMode]) {
        NSError *error = nil;
        if ([device lockForConfiguration:&error]) {
            switch (flashMode) {
                case AVCaptureFlashModeOff: {
                    [device setFlashMode:AVCaptureFlashModeAuto];
                    [self setupFlashButtonForMode:AVCaptureFlashModeAuto];
                    break;
                }
                case AVCaptureFlashModeOn: {
                    [device setFlashMode:AVCaptureFlashModeOff];
                    [self setupFlashButtonForMode:AVCaptureFlashModeOff];
                    break;
                }
                case AVCaptureFlashModeAuto: {
                    [device setFlashMode:AVCaptureFlashModeOn];
                    [self setupFlashButtonForMode:AVCaptureFlashModeOn];
                    break;
                }
            }
            [device unlockForConfiguration];
        } else {
            //Error
        }
    }
}

- (void)setupFlashButtonForMode:(AVCaptureFlashMode)torchMode
{
    switch (torchMode) {
        case AVCaptureTorchModeAuto:
            [self.flashButton setImage:[UIImage imageNamed:@"flash_auto"] forState:UIControlStateNormal];
            [self.flashButton setTag:AVCaptureTorchModeAuto];
            break;
        case AVCaptureTorchModeOn:
            [self.flashButton setImage:[UIImage imageNamed:@"flash"] forState:UIControlStateNormal];
            [self.flashButton setTag:AVCaptureTorchModeOn];
            break;
        case AVCaptureTorchModeOff:
            [self.flashButton setImage:[UIImage imageNamed:@"flash_off"] forState:UIControlStateNormal];
            [self.flashButton setTag:AVCaptureTorchModeOff];
            break;
        default:
            break;
    }
}


- (void)flipCamera
{
    {
        //Change camera source
        if(self.captureSession)
        {
            //Indicate that some changes will be made to the session
            [self.captureSession beginConfiguration];
            
            //Remove existing input
            AVCaptureInput* currentCameraInput = [_captureSession.inputs objectAtIndex:0];
            [self.captureSession removeInput:currentCameraInput];
            
            //Get new input
            AVCaptureDevice *newCamera = nil;
            if(((AVCaptureDeviceInput*)currentCameraInput).device.position == AVCaptureDevicePositionBack)
            {
                newCamera = [self cameraWithPosition:AVCaptureDevicePositionFront];
            }
            else
            {
                newCamera = [self cameraWithPosition:AVCaptureDevicePositionBack];
            }
            
            //Add input to session
            NSError *err = nil;
            AVCaptureDeviceInput *newVideoInput = [[AVCaptureDeviceInput alloc] initWithDevice:newCamera error:&err];
            if(!newVideoInput || err)
            {
                NSLog(@"Error creating capture device input: %@", err.localizedDescription);
            }
            else
            {
                [self.captureSession addInput:newVideoInput];
            }
            
            //Commit all the configuration changes at once
            [self.captureSession commitConfiguration];
        }
    }
}

//Tap to focus

- (void)handleTapToFocus:(UITapGestureRecognizer *)gestureRecognizer
{
    CGPoint pointOfInterest = [gestureRecognizer locationInView:[gestureRecognizer view]];
    
    //handle focus
    UIDeviceOrientation deviceOrientation = [UIDevice currentDevice].orientation;
    CGPoint devicePoint;
    CGFloat y_max = 1, x_max = 1;
    
    switch (deviceOrientation) {
        case UIDeviceOrientationFaceUp:
        case UIDeviceOrientationPortrait:
        case UIDeviceOrientationPortraitUpsideDown:
        case UIDeviceOrientationFaceDown:
        case UIDeviceOrientationUnknown:
            x_max = CGRectGetWidth(APPLICATION_FRAME);
            y_max = CGRectGetHeight(APPLICATION_FRAME);
            break;
        case UIDeviceOrientationLandscapeLeft:
        case UIDeviceOrientationLandscapeRight:
            x_max = CGRectGetHeight(APPLICATION_FRAME);
            y_max = CGRectGetWidth(APPLICATION_FRAME);
            break;
    }
    
    devicePoint = CGPointMake(pointOfInterest.y/y_max, 1-pointOfInterest.x/x_max);
    
    //Only if we are able to focus show the animation
    if ([self focusAndExposeAtPoint:devicePoint]) {
        [self.focusView setCenter:pointOfInterest];
        [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut|UIViewAnimationOptionBeginFromCurrentState animations:^{
            [self.focusView setAlpha:1];
        } completion:^(BOOL finished){
            //Animate out
            [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut|UIViewAnimationOptionBeginFromCurrentState animations:^{
                [self.focusView setAlpha:0];
            } completion:nil];
        }];
    }
    else
    {
        //DLog(@"Failed to focus");
    }
}

- (void)focusWithMode:(AVCaptureFocusMode)focusMode exposeWithMode:(AVCaptureExposureMode)exposureMode atDevicePoint:(CGPoint)point monitorSubjectAreaChange:(BOOL)monitorSubjectAreaChange
{
    dispatch_async(sessionQueue, ^{
        AVCaptureDevice *device = self.captureDevice;
        NSError *error = nil;
        if ([device lockForConfiguration:&error])
        {
            if ([device isFocusPointOfInterestSupported] && [device isFocusModeSupported:focusMode])
            {
                [device setFocusPointOfInterest:point];
                [device setFocusMode:focusMode];
            }
            if ([device isExposurePointOfInterestSupported] && [device isExposureModeSupported:exposureMode])
            {
                [device setExposurePointOfInterest:point];
                [device setExposureMode:exposureMode];
            }
            [device setSubjectAreaChangeMonitoringEnabled:monitorSubjectAreaChange];
            [device unlockForConfiguration];
        }
        else
        {
            //DLog(@"%@", error);
        }

    });
}

- (BOOL)focusAndExposeAtPoint:(CGPoint)focusPoint
{
    BOOL isAbleToFocus = NO;

    if (!self.captureDevice.adjustingFocus &&  !self.captureDevice.adjustingExposure && self.captureDevice.position == AVCaptureDevicePositionBack) {

        dispatch_async(sessionQueue, ^{
            [self focusWithMode:AVCaptureFocusModeContinuousAutoFocus
                 exposeWithMode:AVCaptureExposureModeContinuousAutoExposure
                  atDevicePoint:focusPoint
                monitorSubjectAreaChange:YES];
        });
        
        isAbleToFocus = YES;
    }
    else if (!self.captureDevice.adjustingExposure && self.captureDevice.position == AVCaptureDevicePositionFront)
    {
        dispatch_async(sessionQueue, ^{
            [self focusWithMode:AVCaptureFocusModeContinuousAutoFocus
                 exposeWithMode:AVCaptureExposureModeContinuousAutoExposure
                  atDevicePoint:focusPoint
                monitorSubjectAreaChange:YES];
        });
        
        isAbleToFocus = YES;
    }
    
    return isAbleToFocus;
}


//Camera zoom

-(void) handlePinchToZoomRecognizer:(UIPinchGestureRecognizer*)gestureRecognizer {
    //If we are just starting the guesture, then lets reset
    if(gestureRecognizer.state == UIGestureRecognizerStateBegan)
    {
        previousZoom = (gestureRecognizer.scale - 1);
    }
    
    //Guesture should be rounded and zero based
    CGFloat gestureScale =  (gestureRecognizer.scale - 1);
    float currentZoomScale = self.captureDevice.videoZoomFactor;
    float deltaZoom = 0;
    
    //now we need to get the delta
    deltaZoom = gestureScale - previousZoom;
    previousZoom = gestureScale;
    
    if (currentZoomScale + deltaZoom > MIN_ZOOM && currentZoomScale + deltaZoom < MAX_ZOOM)
    {
        [self setZoomScale:currentZoomScale + deltaZoom];
    }
    else if (currentZoomScale + gestureScale < MIN_ZOOM)
    {
        [self setZoomScale:MIN_ZOOM];
    }
    else if (currentZoomScale + gestureScale > MAX_ZOOM)
    {
        [self setZoomScale:MAX_ZOOM];
    }
}

- (void)setZoomScale:(CGFloat)zoomScale
{
    if ([self.captureDevice respondsToSelector:@selector(setVideoZoomFactor:)]
        && self.captureDevice.activeFormat.videoMaxZoomFactor >= zoomScale
        && zoomScale > 1) {
        if ([self.captureDevice lockForConfiguration:nil]) {
            [self.captureDevice setVideoZoomFactor:zoomScale];
            [self.captureDevice unlockForConfiguration];
        }
    }
}

// Find a camera with the specified AVCaptureDevicePosition, returning nil if one is not found
- (AVCaptureDevice *) cameraWithPosition:(AVCaptureDevicePosition) position
{
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *device in devices) 
    {
        if ([device position] == position) return device;
    }
    return nil;
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

@end
