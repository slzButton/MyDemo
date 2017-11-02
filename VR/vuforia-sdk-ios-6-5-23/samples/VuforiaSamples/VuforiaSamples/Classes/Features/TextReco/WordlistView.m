/*===============================================================================
Copyright (c) 2012-2015 Qualcomm Connected Experiences, Inc. All Rights Reserved.
 
Confidential and Proprietary - Qualcomm Connected Experiences, Inc.
Vuforia is a trademark of PTC Inc., registered in the United States and other 
countries.
===============================================================================*/

#import "WordlistView.h"


@implementation DisplayWords

- (id)init
{
    self = [super init];
    
    if (nil != self) {
        words = [[NSMutableString alloc] init];
    }
    
    return self;
}


- (void)dealloc
{
    words = nil;
}

@end


@implementation WordlistView

//------------------------------------------------------------------------------
#pragma mark - Lifecycle

-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (nil != self) {
        BOOL isIPad = UIUserInterfaceIdiomPad == UI_USER_INTERFACE_IDIOM();
        
        // ----- View -----
        
        // Do not respond to user interaction
        [self setUserInteractionEnabled:NO];

        // View is not opaque
        [self setOpaque:NO];

        CGFloat screenHeight = frame.size.height;
        CGFloat screenWidth = frame.size.width;

        CGRect r;
        r.origin.x = 0.0f;
        r.origin.y = 0.0f;
        r.size.width = screenWidth;
        r.size.height  = screenHeight;

        [self setFrame:r];
        
        // width of margin is:
		// 5% of the width of the screen for a phone
		// 20% of the width of the screen for a tablet
        marginWidth = isIPad ? (screenWidth * 20) / 100 : (screenWidth * 5) / 100;
        
		// loupe height is:
		// 16% of the screen height for a phone
		// 10% of the screen height for a tablet
        loupeHeight = isIPad ? (screenHeight * 10) / 100 : (screenHeight * 16) / 100;
        
        // loupe width takes the width of the screen minus 2 margins
        loupeWidth = screenWidth - (2 * marginWidth);
        
        nonSearchableAreaHeight = screenHeight - (loupeHeight + marginWidth);
        
        // ----- Text view (subview) -----
        r.origin.x = marginWidth;
        r.origin.y = loupeHeight + marginWidth + ((nonSearchableAreaHeight * 7.5) / 100);
        r.size.width = screenWidth - (2 * marginWidth);
        r.size.height = (nonSearchableAreaHeight * 85) / 100;
        
        textView = [[UITextView alloc]initWithFrame:r];
        [textView setTextAlignment:NSTextAlignmentCenter];
        [textView setBackgroundColor:[UIColor clearColor]];
        [textView setTextColor:[UIColor whiteColor]];

        [self addSubview:textView];
        
        // Font size limits
        if (YES == isIPad) {
            minFontSize = 20;
            maxFontSize = 32;
        }
        else {
            minFontSize = 10;
            maxFontSize = 32;
        }
        
    }
    
    return self;
}


//------------------------------------------------------------------------------
#pragma mark - Public methods

- (void)setWordsToDisplay:(DisplayWords*)displayWords
{
    // Update the UITextView on the main thread
    [self performSelectorOnMainThread:@selector(setText:) withObject:displayWords waitUntilDone:NO];
}


//------------------------------------------------------------------------------
#pragma mark - Private methods

- (void)setText:(DisplayWords*)displayWords
{
    textView.text = displayWords->words;
    static NSUInteger previousCount = 0;
    
    if (0 < displayWords->count && displayWords->count != previousCount) {
        // If the number of words has changed, update the font size
        int requiredLineHeight = [textView bounds].size.height / displayWords->count;
        CGFloat fontSize = (CGFloat)requiredLineHeight;

        // Create the font to use when drawing the text
        UIFont* font = [UIFont fontWithName:@"Arial" size:fontSize];

        // Reduce the font size until the line height is suitable
      
        while ((fontSize > minFontSize) && ([font lineHeight] > requiredLineHeight)) {
            --fontSize;

            if ((maxFontSize < fontSize))
                fontSize = maxFontSize;
            else if (minFontSize > fontSize)
                fontSize = minFontSize;

            font = [UIFont fontWithName:@"Arial" size:fontSize];
        }
        font = [UIFont fontWithName:@"Arial" size:fontSize];
        [textView setFont:font];
        previousCount = displayWords->count;
    }
}


// Overridden so we can draw the view's background
- (void)drawRect:(CGRect)rect
{
    CGContextRef c = UIGraphicsGetCurrentContext();
    
    UIColor* colorBackground = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.75];
    CGContextSetFillColorWithColor(c, colorBackground.CGColor);
    
    // Draw top rectangle above ROI
    CGRect r;
    r.origin.x = 0.0;
    r.origin.y = 0.0;
    r.size.width = rect.size.width;
    r.size.height = marginWidth;
    CGContextFillRect(c, r);
    
    
    NSLog(@"top: x=%7.3f, y=%7.3f w=%7.3f h=%7.3f", r.origin.x , r.origin.y, r.size.width, r.size.height );
    
    // Draw left side rectangle
    r.origin.y = marginWidth;
    r.size.width = marginWidth;
    r.size.height = loupeHeight;
    CGContextFillRect(c, r);
    
    NSLog(@"left: x=%7.3f, y=%7.3f w=%7.3f h=%7.3f", r.origin.x , r.origin.y, r.size.width, r.size.height );

    
    // Draw right side rectangle
    r.origin.x = loupeWidth + marginWidth;
    CGContextFillRect(c, r);
    
    NSLog(@"right: x=%7.3f, y=%7.3f w=%7.3f h=%7.3f", r.origin.x , r.origin.y, r.size.width, r.size.height );
    

    
    // Draw lower rectangle
    r.origin.x = 0.0;
    r.origin.y = loupeHeight + marginWidth;
    r.size.width = rect.size.width;
    r.size.height = nonSearchableAreaHeight;
    CGContextFillRect(c, r);
    
    NSLog(@"lower: x=%7.3f, y=%7.3f w=%7.3f h=%7.3f", r.origin.x , r.origin.y, r.size.width, r.size.height );
    
}

@end
