//
//  PriceFilterView.m
//  TrueBite
//
//  Created by Brian Wong on 9/5/16.
//  Copyright © 2016 Brian Wong. All rights reserved.
//

#import "PriceFilterView.h"
#import "FoodwiseDefines.h"
#import "UIFont+Extension.h"
#import "LayoutBounds.h"

typedef NS_ENUM(NSUInteger, TRUDigitPicker) {
    TRUDigitPickerOne,
    TRUDigitPickerTwo,
    TRUDigitPickerThree,
    TRUDigitPickerFour
};

@interface PriceFilterView () <UIPickerViewDelegate, UIPickerViewDataSource, UIGestureRecognizerDelegate>

//Flat digits to be edited/burned onto picture
@property (nonatomic, strong)UIView *priceView;

@property (nonatomic, strong)UILabel *dollarSign;
@property (nonatomic, strong)UILabel *firstDigitLabel;
@property (nonatomic, strong)UILabel *secondDigitLabel;
@property (nonatomic, strong)UILabel *thirdDigitLabel;
@property (nonatomic, strong)UILabel *fourthDigitLabel;

@property (nonatomic, strong)UIView *periodView;

//Populates the labels above
@property (nonatomic, strong)UIPickerView *firstDigitPicker;
@property (nonatomic, strong)UIPickerView *secondDigitPicker;
@property (nonatomic, strong)UIPickerView *thirdDigitPicker;
@property (nonatomic, strong)UIPickerView *fourthDigitPicker;

//Edit the labels
@property (nonatomic, strong)UIPinchGestureRecognizer *pinchGesture;
@property (nonatomic, strong)UIRotationGestureRecognizer *rotateGesture;
@property (nonatomic, strong)UIPanGestureRecognizer *panGesture;
@property (nonatomic, assign)BOOL editModeActive;

@property (nonatomic, strong)NSArray *pricePickerDigits;

@end

@implementation PriceFilterView

// Constants to adjust the max/min values of zoom
const CGFloat kMaxScale = 2.0;
const CGFloat kMinScale = 0.5;
CGFloat lastScale = 0.0;

#define PRICE_FONT_SIZE APPLICATION_FRAME.size.width * 0.22

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self)
    {
        self.backgroundColor = [UIColor clearColor];
        
        //In reverse order because UIPickerView only scrolls down, we want numbers to be moving in opposite direction intuitively
        self.pricePickerDigits = @[@"9", @"8", @"7", @"6", @"5", @"4", @"3", @"2", @"1", @"0"];
        
        self.priceView = [[UIView alloc]initWithFrame:CGRectMake(self.frame.size.width/2 - self.frame.size.width * 0.425, self.frame.size.height/1.4 - self.frame.size.height * 0.12, self.frame.size.width * 0.85, self.frame.size.height * 0.24)];
        [self addSubview:self.priceView];
        
//        UIButton *editFrameButton = [[UIButton alloc]initWithFrame:CGRectMake(frame.size.width/2 - frame.size.width * 0.1, 100, frame.size.width * 0.2, frame.size.height * 0.1)];
//        editFrameButton.backgroundColor = [UIColor lightGrayColor];
//        [editFrameButton setTitle:@"Edit" forState:UIControlStateNormal];
//        [editFrameButton addTarget:self action:@selector(editPriceFrame) forControlEvents:UIControlEventTouchUpInside];
//        [self addSubview:editFrameButton];
        
        //For editing the label's frame
        self.pinchGesture = [[UIPinchGestureRecognizer alloc]initWithTarget:self action:@selector(scalePriceView:)];
        self.pinchGesture.delegate = self;
        self.rotateGesture = [[UIRotationGestureRecognizer alloc]initWithTarget:self action:@selector(rotatePriceView:)];
        self.rotateGesture.delegate = self;
        self.panGesture = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(movePriceView:)];
        
        self.dollarSign = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, self.priceView.frame.size.width * 0.15, self.priceView.frame.size.height)];
        self.dollarSign.text = @"$";
        self.dollarSign.textColor = [UIColor whiteColor];
        self.dollarSign.font = [UIFont semiboldFontWithSize:self.frame.size.width * 0.17];
        self.dollarSign.textAlignment = NSTextAlignmentCenter;
        self.dollarSign.backgroundColor = [UIColor clearColor];
        [self.priceView addSubview:self.dollarSign];
        
        NSMutableArray *pickerArray = [NSMutableArray array];
        
        self.firstDigitLabel = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(self.dollarSign.frame), 0, self.priceView.frame.size.width * 0.2, self.priceView.frame.size.height)];
        self.firstDigitLabel.font = [UIFont semiboldFontWithSize:PRICE_FONT_SIZE];
        self.firstDigitLabel.textColor = [UIColor whiteColor];
        self.firstDigitLabel.textAlignment = NSTextAlignmentCenter;
        self.firstDigitLabel.backgroundColor = [UIColor clearColor];
        self.firstDigitLabel.text = @"0";
        [self.priceView addSubview:self.firstDigitLabel];
        
        self.firstDigitPicker = [[UIPickerView alloc]initWithFrame:self.firstDigitLabel.frame];
        self.firstDigitPicker.delegate = self;
        self.firstDigitPicker.dataSource = self;
        self.firstDigitPicker.backgroundColor = [UIColor clearColor];
        self.firstDigitPicker.tag = TRUDigitPickerOne;
        [self.firstDigitPicker selectRow:9 inComponent:0 animated:NO];//0 in our array
        [pickerArray addObject:self.firstDigitPicker];
        [self.priceView addSubview:self.firstDigitPicker];
        
        self.secondDigitLabel = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(self.firstDigitLabel.frame), 0, self.priceView.frame.size.width * 0.2, self.priceView.frame.size.height)];
        self.secondDigitLabel.font = [UIFont semiboldFontWithSize:PRICE_FONT_SIZE];
        self.secondDigitLabel.textColor = [UIColor whiteColor];
        self.secondDigitLabel.textAlignment = NSTextAlignmentCenter;
        self.secondDigitLabel.backgroundColor = [UIColor clearColor];
        self.secondDigitLabel.text = @"0";
        [self.priceView addSubview:self.secondDigitLabel];
        
        self.secondDigitPicker = [[UIPickerView alloc]initWithFrame:self.secondDigitLabel.frame];
        self.secondDigitPicker.delegate = self;
        self.secondDigitPicker.dataSource = self;
        self.secondDigitPicker.backgroundColor = [UIColor clearColor];
        self.secondDigitPicker.tag = TRUDigitPickerTwo;
        [self.secondDigitPicker selectRow:9 inComponent:0 animated:NO];
        [pickerArray addObject:self.secondDigitPicker];
        [self.priceView addSubview:self.secondDigitPicker];
        
        self.thirdDigitLabel = [[UILabel alloc]initWithFrame:CGRectMake(self.priceView.frame.size.width - self.priceView.frame.size.width * 0.4, 0, self.priceView.frame.size.width * 0.2, self.priceView.frame.size.height)];
        self.thirdDigitLabel.font = [UIFont semiboldFontWithSize:PRICE_FONT_SIZE];
        self.thirdDigitLabel.textColor = [UIColor whiteColor];
        self.thirdDigitLabel.textAlignment = NSTextAlignmentCenter;
        self.thirdDigitLabel.backgroundColor = [UIColor clearColor];
        self.thirdDigitLabel.text = @"0";
        [self.priceView addSubview:self.thirdDigitLabel];
        
        self.thirdDigitPicker = [[UIPickerView alloc]initWithFrame:self.thirdDigitLabel.frame];
        self.thirdDigitPicker.delegate = self;
        self.thirdDigitPicker.dataSource = self;
        self.thirdDigitPicker.backgroundColor = [UIColor clearColor];
        self.thirdDigitPicker.tag = TRUDigitPickerThree;
        [self.thirdDigitPicker selectRow:9 inComponent:0 animated:NO];
        [pickerArray addObject:self.thirdDigitPicker];
        [self.priceView addSubview:self.thirdDigitPicker];
        
        self.fourthDigitLabel = [[UILabel alloc]initWithFrame:CGRectMake(self.priceView.frame.size.width - self.priceView.frame.size.width * 0.2, 0, self.priceView.frame.size.width * 0.2, self.priceView.frame.size.height)];
        self.fourthDigitLabel.font = [UIFont semiboldFontWithSize:PRICE_FONT_SIZE];
        self.fourthDigitLabel.textColor = [UIColor whiteColor];
        self.fourthDigitLabel.textAlignment = NSTextAlignmentCenter;
        self.fourthDigitLabel.backgroundColor = [UIColor clearColor];
        self.fourthDigitLabel.text = @"0";
        [self.priceView addSubview:self.fourthDigitLabel];
        
        self.fourthDigitPicker = [[UIPickerView alloc]initWithFrame:self.fourthDigitLabel.frame];
        self.fourthDigitPicker.delegate = self;
        self.fourthDigitPicker.dataSource = self;
        self.fourthDigitPicker.backgroundColor = [UIColor clearColor];
        self.fourthDigitPicker.tag = TRUDigitPickerFour;
        [self.fourthDigitPicker selectRow:9 inComponent:0 animated:NO];
        [pickerArray addObject:self.fourthDigitPicker];
        [self.priceView addSubview:self.fourthDigitPicker];
        
        //These gesture recognizers are going to detect the second our user scrolls the UIPickerView to hide the labels behind each one of them!
        for (UIPickerView *picker in pickerArray) {
            UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(hideLabel:)];
            pan.delegate = self;
            [picker addGestureRecognizer:pan];
        }
        
        self.periodView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.priceView.frame.size.width * 0.03, self.priceView.frame.size.width * 0.03)];
        self.periodView.center = CGPointMake(self.priceView.frame.size.width * 0.575, self.priceView.frame.size.height/1.45 - self.priceView.frame.size.width * 0.015); //Period is put in last in order to get spacing,sizes for digits done first. We leave a little space between the second and third digits in order to find the average space between them and center the dot there.
        self.periodView.layer.cornerRadius = self.priceView.frame.size.width * 0.015;
        self.periodView.backgroundColor = [UIColor whiteColor];
        [self.priceView addSubview:self.periodView];
        
        self.editModeActive = NO;
        
        //Always active for now...
        [self editPriceFrame];
        
    }
        return self;
}

- (void)editPriceFrame
{
    if (!self.editModeActive)
    {
        //Animate other digits over first one and center if first digit is 0!
        //NSString *tensDigit = [
        
        [self addGestureRecognizer:self.pinchGesture];
        [self addGestureRecognizer:self.rotateGesture];
        [self.priceView addGestureRecognizer:self.panGesture];

    }
    else
    {
        [self removeGestureRecognizer:self.pinchGesture];
        [self removeGestureRecognizer:self.rotateGesture];
        [self.priceView removeGestureRecognizer:self.panGesture];
    }
}

//Use our labels to get a price from each char(digit).
- (void)updateCurrentPrice
{
    NSMutableString *priceString = [NSMutableString string];
    
    //If first digit is zero, exclude it
    if (![self.firstDigitLabel.text isEqualToString:@"0"]) {
        [priceString appendString:self.firstDigitLabel.text];
    }
    
    [priceString appendString:self.secondDigitLabel.text];
    [priceString appendString:@"."];//This is NSNumber's problem :)
    [priceString appendString:self.thirdDigitLabel.text];
    [priceString appendString:self.fourthDigitLabel.text];
    
    self.currentPrice = @([priceString doubleValue]);
}

#pragma mark - UIGestureRecognizer helper methods & delegate methods

//We added the pinch to the entire view in order to always give the room as much room as they need to pinch!
- (void)scalePriceView:(UIPinchGestureRecognizer*)pinchGesture
{
    if([pinchGesture state] == UIGestureRecognizerStateBegan) {
        // Reset the last scale, necessary if there are multiple objects with different scales
        lastScale = [pinchGesture scale];
    }
    
    //Set a max/min for how much a user can scale
    if ([pinchGesture state] == UIGestureRecognizerStateBegan ||
        [pinchGesture state] == UIGestureRecognizerStateChanged) {
        
        CGFloat currentScale = [[self.layer valueForKeyPath:@"transform.scale"] floatValue];
        
        CGFloat newScale = 1 -  (lastScale - [pinchGesture scale]);
        newScale = MIN(newScale, kMaxScale / currentScale);
        newScale = MAX(newScale, kMinScale / currentScale);
        
        //We want to transform all the subviews instead of the gestureView itself in order to give the user an easier time using the gestures (e.g. If the view gets really small, it's gonna be harder to pinch)
        CGAffineTransform transform = CGAffineTransformScale([self.priceView transform], newScale, newScale);
        self.priceView.transform = transform;
        lastScale = [pinchGesture scale];  // Store the previous scale factor for the next pinch gesture call
    }
}


//Same applies to rotation like we did for pinch
- (void)rotatePriceView:(UIRotationGestureRecognizer*)rotateGesture
{
    CGFloat rotation = rotateGesture.rotation;
    self.priceView.transform = CGAffineTransformRotate(self.priceView.transform, rotation);
    rotateGesture.rotation = 0.0; //Reset so we start with a fresh measurement in whatever we just rotated to.
}

- (void)movePriceView:(UIPanGestureRecognizer*)panGesture
{
    CGPoint translation = [panGesture translationInView:self];
    self.priceView.center = CGPointMake(self.priceView.center.x  + translation.x, self.priceView.center.y + translation.y);
    [panGesture setTranslation:CGPointZero inView:self.priceView];
}

//Allow user to perform all three frame transforms at the same time AS WELL AS our custom UIPickerView/Label animation
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

#pragma mark UIPickerView delegate and datasource methods

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return self.pricePickerDigits.count;
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return self.pricePickerDigits[row];
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
    UILabel *pickerLabel = (UILabel*)view;
    
    if (!pickerLabel) {
        pickerLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, self.firstDigitLabel.frame.size.width, self.frame.size.height * 0.2)];
        pickerLabel.textColor = [UIColor whiteColor];
        pickerLabel.font = [UIFont semiboldFontWithSize:PRICE_FONT_SIZE];
        pickerLabel.textAlignment = NSTextAlignmentCenter;
    }
    
    [pickerLabel setText:self.pricePickerDigits[row]];
    
    return pickerLabel;
}

//BECAUSE UIPICKERVIEW'S DEFAULT IMPLEMENTATION ALWAYS MAKES LABELS TRANSPARENT AND UGLY AS SHIT, WE HAVE TO SHOW AN OPAQUE LABEL BEHIND IT
- (void)hideLabel:(UIPanGestureRecognizer *)panGesture
{
    TRUDigitPicker picker = panGesture.view.tag;
    [UIView animateWithDuration:0.01 animations:^{
        switch (picker)
        {
            case TRUDigitPickerOne:
                self.firstDigitLabel.alpha = 0.0;
                break;
            case TRUDigitPickerTwo:
                self.secondDigitLabel.alpha = 0.0;
                break;
            case TRUDigitPickerThree:
                self.thirdDigitLabel.alpha = 0.0;
                break;
            case TRUDigitPickerFour:
                self.fourthDigitLabel.alpha = 0.0;
                break;
            default:
                break;
        }
    }];
    
    if ([self.delegate respondsToSelector:@selector(didStartPickingPrice)]) {
        [self.delegate didStartPickingPrice];
    }
}

//When user had made a decision show the label.
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    [UIView animateWithDuration:0.01 animations:^{
        if (pickerView == self.firstDigitPicker)
        {
            self.firstDigitLabel.text = self.pricePickerDigits[row];
            self.firstDigitLabel.alpha = 1.0;
        }
        else if (pickerView == self.secondDigitPicker)
        {
            self.secondDigitLabel.text = self.pricePickerDigits[row];
            self.secondDigitLabel.alpha = 1.0;
        }
        else if (pickerView == self.thirdDigitPicker)
        {
            self.thirdDigitLabel.text = self.pricePickerDigits[row];
            self.thirdDigitLabel.alpha = 1.0;
        }
        else if (pickerView == self.fourthDigitPicker)
        {
            self.fourthDigitLabel.text = self.pricePickerDigits[row];
            self.fourthDigitLabel.alpha = 1.0;
        }
    }];
    
    [self updateCurrentPrice];
    
    if ([self.delegate respondsToSelector:@selector(didEndPickingPrice)]) {
        [self.delegate didEndPickingPrice];
    }
}

//We MUST make all pickers invisible when user is finished picking or renderInContext: will draw render them onto our final image...
- (void)prepareFilterForRender
{
    //If first digit is 0, animate it out just so the price looks cleaner
    if (self.currentPrice.doubleValue < 10.00) {
        [UIView animateWithDuration:0.25 animations:^{
            self.firstDigitLabel.alpha = 0.0;
            self.firstDigitPicker.alpha = 0.0;
            
            CGRect dollarSign = self.dollarSign.frame;
            dollarSign.origin.x = CGRectGetMidX(self.firstDigitLabel.frame) - self.dollarSign.frame.size.width;
            self.dollarSign.frame = dollarSign;
            
            //Push everything back the same length
            CGFloat delta = self.secondDigitLabel.frame.origin.x - CGRectGetMidX(self.firstDigitLabel.frame);
            
            self.secondDigitLabel.frame = CGRectMake(self.secondDigitLabel.frame.origin.x - delta, self.secondDigitLabel.frame.origin.y, self.secondDigitLabel.frame.size.width, self.secondDigitLabel.frame.size.height);
            self.periodView.frame = CGRectMake(self.periodView.frame.origin.x - delta, self.periodView.frame.origin.y, self.periodView.frame.size.width, self.periodView.frame.size.height);
            self.thirdDigitLabel.frame = CGRectMake(self.thirdDigitLabel.frame.origin.x - delta, self.thirdDigitLabel.frame.origin.y, self.thirdDigitLabel.frame.size.width, self.thirdDigitLabel.frame.size.height);
            self.fourthDigitLabel.frame = CGRectMake(self.fourthDigitLabel.frame.origin.x - delta, self.fourthDigitLabel.frame.origin.y, self.fourthDigitLabel.frame.size.width, self.fourthDigitLabel.frame.size.height);
        }];
    }
    
    self.firstDigitPicker.alpha = 0.0;
    self.secondDigitPicker.alpha = 0.0;
    self.thirdDigitPicker.alpha = 0.0;
    self.fourthDigitPicker.alpha = 0.0;
}

//Making the row longer to hide the default "clicky" animation when switching choices
-(CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component
{
    return self.frame.size.height * 0.36;
}

@end
