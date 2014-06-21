//
//  TDHelperClass.m
//  watchr
//
//  Created by Tudor Dragan on 9/6/14.
//  Copyright (c) 2014 Tudor Dragan. All rights reserved.
//

#import "TDHelperClass.h"

@implementation TDHelperClass


-(id) init{
	self = [super init];
	if (self) {
		
	}
	return self;
}


#pragma mark -
#pragma mark Singleton
static TDHelperClass * sharedHelper = nil;

+(TDHelperClass *) sharedHelper {
    @synchronized(self) {
        if(sharedHelper == nil)
            sharedHelper = [[self alloc] init];
    }
    return sharedHelper;
}


+(void)performBlock:(void(^)())block afterDelay:(NSTimeInterval)delay {
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), block);
}

- (CGFloat)measureHeightOfUITextView:(UITextView *)textView
{
    if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1)
    {
        // This is the code for iOS 7. contentSize no longer returns the correct value, so
        // we have to calculate it.
        //
        // This is partly borrowed from HPGrowingTextView, but I've replaced the
        // magic fudge factors with the calculated values (having worked out where
        // they came from)
		
        CGRect frame = textView.bounds;
		
        // Take account of the padding added around the text.
		
        UIEdgeInsets textContainerInsets = textView.textContainerInset;
        UIEdgeInsets contentInsets = textView.contentInset;
		
        CGFloat leftRightPadding = textContainerInsets.left + textContainerInsets.right + textView.textContainer.lineFragmentPadding * 2 + contentInsets.left + contentInsets.right;
        CGFloat topBottomPadding = textContainerInsets.top + textContainerInsets.bottom + contentInsets.top + contentInsets.bottom;
		
        frame.size.width -= leftRightPadding;
        frame.size.height -= topBottomPadding;
		
        NSString *textToMeasure = textView.text;
        if ([textToMeasure hasSuffix:@"\n"])
        {
            textToMeasure = [NSString stringWithFormat:@"%@-", textView.text];
        }
		
        // NSString class method: boundingRectWithSize:options:attributes:context is
        // available only on ios7.0 sdk.
		
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        [paragraphStyle setLineBreakMode:NSLineBreakByWordWrapping];
		
        NSDictionary *attributes = @{ NSFontAttributeName: textView.font, NSParagraphStyleAttributeName : paragraphStyle };
		
        CGRect size = [textToMeasure boundingRectWithSize:CGSizeMake(CGRectGetWidth(frame), MAXFLOAT)
                                                  options:NSStringDrawingUsesLineFragmentOrigin
                                               attributes:attributes
                                                  context:nil];
		
        CGFloat measuredHeight = ceilf(CGRectGetHeight(size) + topBottomPadding);
        return measuredHeight;
    }
    else
    {
        return textView.contentSize.height;
    }
}


-(NSString*) getStringRepresentationForstartDate:(NSDate*) startDate andEndDate:(NSDate*) endDate{
	
	
	if (!startDate || !endDate) {
		return @"no date";
	}
	
	NSCalendar *gregorian = [[NSCalendar alloc]
							 initWithCalendarIdentifier:NSGregorianCalendar];
	
	NSUInteger unitFlags =NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit;
	

	NSDateComponents * startdateComponents = [gregorian components:unitFlags fromDate:startDate];
	
	NSDateComponents *differencecomponents = [gregorian components:unitFlags
												fromDate:startDate
												  toDate:endDate options:0];
	NSInteger diffYears = [differencecomponents year];
	NSInteger diffMonths = [differencecomponents month];
	NSInteger diffDays = [differencecomponents day];
	NSInteger diffHours = [differencecomponents hour];
	NSInteger diffMinutes = [differencecomponents minute];
	NSInteger diffSeconds = [differencecomponents second];
	
	if (diffMonths || diffYears) {
		return [NSString stringWithFormat:@"%d/%d/%d", [startdateComponents day], [startdateComponents month], [startdateComponents year]];
	}else if (diffDays){
		return [NSString stringWithFormat:@"%dd ago", diffDays];
	}else if(diffHours){
		return [NSString stringWithFormat:@"%dh ago",diffHours];
	}else if(diffMinutes){
		return [NSString stringWithFormat:@"%dm ago",diffMinutes];
	}else{
		return @"now";
	}
	
	
}

@end
