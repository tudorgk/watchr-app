//
//  UIScrollView+InfiniteScroll.m
//
//  UIScrollView infinite scroll category
//
//  Created by Andrej Mihajlov on 9/4/13.
//  Copyright (c) 2013 Andrej Mihajlov. All rights reserved.
//

#import "UIScrollView+InfiniteScroll.h"
#import <objc/runtime.h>

#define TRACE_ENABLED 0

#if TRACE_ENABLED
#	define TRACE(_format, ...) NSLog(_format, ##__VA_ARGS__)
#else
#	define TRACE(_format, ...)
#endif

static void PBSwizzleMethod(Class c, SEL original, SEL alternate) {
	Method origMethod = class_getInstanceMethod(c, original);
	Method newMethod = class_getInstanceMethod(c, alternate);
	
	if(class_addMethod(c, original, method_getImplementation(newMethod), method_getTypeEncoding(newMethod))) {
		class_replaceMethod(c, alternate, method_getImplementation(origMethod), method_getTypeEncoding(origMethod));
	} else {
		method_exchangeImplementations(origMethod, newMethod);
	}
}

const CGFloat kPBInfiniteScrollIndicatorViewHeight = 44.0f;

static const void* kPBInfiniteScrollHandlerKey = &kPBInfiniteScrollHandlerKey;
static const void* kPBInfiniteScrollIndicatorViewKey = &kPBInfiniteScrollIndicatorViewKey;
static const void* kPBInfiniteScrollStateKey = &kPBInfiniteScrollStateKey;
static const void* kPBInfiniteScrollInitKey = &kPBInfiniteScrollInitKey;
static const void* kPBInfiniteScrollOriginalInsetsKey = &kPBInfiniteScrollOriginalInsetsKey;

typedef NS_ENUM(NSInteger, PBInfiniteScrollState) {
	PBInfiniteScrollStateNone,
	PBInfiniteScrollStateLoading
};

@implementation UIScrollView (PBInfiniteScroll)

#pragma mark - Public methods

- (void)addInfiniteScrollWithHandler:(void(^)(UIScrollView* scrollView))handler {
	NSAssert([self pb_isInfiniteScrollInitialized] == NO, @"InfiniteScroll is already initialized for this view. You must call -(void)removeInfiniteScroll before setting the new one.");
	
	[self pb_setInfiniteScrollHandler:handler];
	[self pb_setInfiniteScrollOriginalInsets:self.contentInset];
	
	[self.panGestureRecognizer addTarget:self action:@selector(pb_handlePanGesture:)];
	
	[self pb_setInfiniteScrollInitialized:YES];
}

- (void)removeInfiniteScroll {
	// ignore multiple calls to remove infinite scroll
	if(![self pb_isInfiniteScrollInitialized]) {
		return;
	}
	
	[self.panGestureRecognizer removeTarget:self action:@selector(pb_handlePanGesture:)];
	
	[self pb_removeActivityIndicator];
	[self pb_setInfiniteScrollInitialized:NO];
}

- (void)finishInfiniteScroll {
	[self finishInfiniteScrollWithCompletion:nil];
}

- (void)finishInfiniteScrollWithCompletion:(void(^)(UIScrollView* scrollView))handler {
	if([self pb_infiniteScrollState] == PBInfiniteScrollStateLoading) {
		[self pb_stopAnimatingInfiniteScrollWithCompletion:handler];
	}
}

#pragma mark - Private methods

+ (void)load {
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		PBSwizzleMethod(self, @selector(setContentOffset:), @selector(pb_setContentOffset:));
		PBSwizzleMethod(self, @selector(setContentSize:), @selector(pb_setContentSize:));
	});
}

-(void)pb_handlePanGesture:(UITapGestureRecognizer*)gestureRecognizer {
	if(gestureRecognizer.state == UIGestureRecognizerStateEnded) {
		[self pb_scrollToInfiniteIndicatorIfNeeded];
	}
}

- (void)pb_setContentOffset:(CGPoint)contentOffset {
	[self pb_setContentOffset:contentOffset];
	
	if([self pb_isInfiniteScrollInitialized]) {
		[self pb_scrollViewDidScroll:contentOffset];
	}
}

- (void)pb_setContentSize:(CGSize)contentSize {
	[self pb_setContentSize:contentSize];
	
	if([self pb_isInfiniteScrollInitialized]) {
		[self pb_positionInfiniteScrollIndicatorWithContentSize:contentSize];
	}
}

- (void)pb_setInfiniteScrollOriginalInsets:(UIEdgeInsets)insets {
	objc_setAssociatedObject(self, kPBInfiniteScrollOriginalInsetsKey, [NSValue valueWithUIEdgeInsets:insets], OBJC_ASSOCIATION_RETAIN);
}

- (UIEdgeInsets)pb_infiniteScrollOriginalInsets {
	NSValue* insetsValue = objc_getAssociatedObject(self, kPBInfiniteScrollOriginalInsetsKey);
	
	if(insetsValue == nil) {
		return UIEdgeInsetsZero;
	}
	
	return [insetsValue UIEdgeInsetsValue];
}

- (BOOL)pb_isInfiniteScrollInitialized {
	NSNumber* number = objc_getAssociatedObject(self, kPBInfiniteScrollInitKey);
	if(number != nil) {
		return [number boolValue];
	}
	return NO;
}

- (void)pb_setInfiniteScrollInitialized:(BOOL)flag {
	objc_setAssociatedObject(self, kPBInfiniteScrollInitKey, @(flag), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)pb_triggerInfiniteScrollHandler {
	void(^handler)(UIScrollView* scrollView) = [self pb_infiniteScrollHandler];
	if(handler != nil) {
		handler(self);
	}
}

- (PBInfiniteScrollState)pb_infiniteScrollState {
	NSNumber* state = objc_getAssociatedObject(self, kPBInfiniteScrollStateKey);
	
	if(state != nil) {
		return state.integerValue;
	}
	
	return PBInfiniteScrollStateNone;
}

- (void)pb_setInfiniteScrollState:(PBInfiniteScrollState)state {
	objc_setAssociatedObject(self, kPBInfiniteScrollStateKey, @(state), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
	
	TRACE(@"pb_setInfiniteScrollState = %d", state);
}

- (UIActivityIndicatorView*)pb_getOrCreateActivityIndicatorView {
	UIActivityIndicatorView* activityIndicator = [self pb_activityIndicatorView];
	
	if(activityIndicator == nil) {
		activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
		
		[self addSubview:activityIndicator];
		[activityIndicator setHidden:YES];
		
		[self pb_setActivityIndicatorView:activityIndicator];
	}
	
	return activityIndicator;
}

- (void)pb_removeActivityIndicator {
	UIActivityIndicatorView* activityIndicator = [self pb_activityIndicatorView];
	if(activityIndicator != nil) {
		[activityIndicator removeFromSuperview];
		[self pb_setActivityIndicatorView:nil];
	}
}

- (UIActivityIndicatorView*)pb_activityIndicatorView {
	return objc_getAssociatedObject(self, kPBInfiniteScrollIndicatorViewKey);
}

- (void)pb_setActivityIndicatorView:(UIActivityIndicatorView*)view {
	objc_setAssociatedObject(self, kPBInfiniteScrollIndicatorViewKey, view, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)pb_setInfiniteScrollHandler:(void(^)(UIScrollView* scrollView))handler {
	objc_setAssociatedObject(self, kPBInfiniteScrollHandlerKey, handler, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (void(^)(UIScrollView* scrollView))pb_infiniteScrollHandler {
	return objc_getAssociatedObject(self, kPBInfiniteScrollHandlerKey);
}

- (void)pb_positionInfiniteScrollIndicatorWithContentSize:(CGSize)size {
	UIActivityIndicatorView* activityIndicator = [self pb_getOrCreateActivityIndicatorView];
	CGRect rect = activityIndicator.frame;
	rect.origin.x = size.width * .5f - rect.size.width * .5f;
	rect.origin.y = size.height + kPBInfiniteScrollIndicatorViewHeight * .5f - rect.size.height * .5f;
	
	if(!CGRectEqualToRect(rect, activityIndicator.frame)) {
		activityIndicator.frame = rect;
		TRACE(@"pb_positionInfiniteScrollIndicatorWithContentSize::setFrame");
	} else {
		TRACE(@"pb_positionInfiniteScrollIndicatorWithContentSize");
	}
}

- (void)pb_startAnimatingInfiniteScroll {
	UIActivityIndicatorView* activityIndicator = [self pb_getOrCreateActivityIndicatorView];
	
	[self pb_positionInfiniteScrollIndicatorWithContentSize:self.contentSize];
	
	[activityIndicator setHidden:NO];
	[activityIndicator startAnimating];
	
	UIEdgeInsets contentInset = self.contentInset;
	contentInset.bottom += kPBInfiniteScrollIndicatorViewHeight;
	
	[self pb_setInfiniteScrollState:PBInfiniteScrollStateLoading];
	[self pb_setScrollViewContentInset:contentInset animated:YES completion:^(BOOL finished) {
		if(finished) {
			[self pb_scrollToInfiniteIndicatorIfNeeded];
		}
	}];
	TRACE(@"pb_startAnimatingInfiniteScroll");
}

- (void)pb_stopAnimatingInfiniteScrollWithCompletion:(void(^)(UIScrollView* scrollView))handler {
	UIActivityIndicatorView* activityIndicator = [self pb_activityIndicatorView];
	UIEdgeInsets contentInset = self.contentInset;
	
	// activity indicator can be already destroyed at this point
	// so do not animate any contentInset changes to avoid table view crash
	BOOL animated = (activityIndicator != nil);
	
	contentInset.bottom -= kPBInfiniteScrollIndicatorViewHeight;
	
	[self pb_setScrollViewContentInset:contentInset animated:animated completion:^(BOOL finished) {
		if(activityIndicator != nil) {
			[activityIndicator stopAnimating];
			[activityIndicator setHidden:YES];
		}
		
		[self pb_setInfiniteScrollState:PBInfiniteScrollStateNone];
		
		// Initiate scroll to the bottom if due to user interaction contentOffset.y
		// stuck somewhere between last cell and activity indicator
		if(finished) {
			UIEdgeInsets originalInsets = [self pb_infiniteScrollOriginalInsets];
			CGFloat newY = self.contentSize.height - self.bounds.size.height + originalInsets.bottom;
			
			if(self.contentOffset.y > newY) {
				[self setContentOffset:CGPointMake(0, newY) animated:YES];
				TRACE(@"pb_stopAnimatingInfiniteScroll::scrollToBottom");
			}
		}
		
		// call completion handler
		if(handler != nil) {
			handler(self);
		}
	}];
	
	TRACE(@"pb_stopAnimatingInfiniteScroll");
}

- (void)pb_scrollViewDidScroll:(CGPoint)contentOffset {
	CGFloat heightDiff = self.contentSize.height - (self.bounds.size.height - self.contentInset.top);
	CGFloat minY = self.contentSize.height - self.bounds.size.height;
	
	if([self isDragging] && heightDiff > 0 && contentOffset.y > minY) {
		if([self pb_infiniteScrollState] == PBInfiniteScrollStateNone) {
			TRACE(@"pb_scrollViewDidScroll::initiateInfiniteScroll");
			
			[self pb_startAnimatingInfiniteScroll];
			[self pb_triggerInfiniteScrollHandler];
		}
	}
}

//
// Scrolls view down to activity indicator position
// if activity indicator is partially visible
//
- (void)pb_scrollToInfiniteIndicatorIfNeeded {
	if(![self isDragging] && [self pb_infiniteScrollState] == PBInfiniteScrollStateLoading) {
		CGFloat minY = self.contentSize.height - self.bounds.size.height;
		CGFloat maxY = minY + kPBInfiniteScrollIndicatorViewHeight;
		
		TRACE(@"minY = %.2f; maxY = %.2f; offsetY = %.2f", minY, maxY, self.contentOffset.y);
		
		if(self.contentOffset.y > minY && self.contentOffset.y < maxY) {
			TRACE(@"pb_scrollToInfiniteIndicatorIfNeeded");
			[self setContentOffset:CGPointMake(0, maxY) animated:YES];
		}
	}
}

- (void)pb_setScrollViewContentInset:(UIEdgeInsets)contentInset animated:(BOOL)animated completion:(void(^)(BOOL finished))completion {
	if(animated) {
		[UIView animateWithDuration:.35f delay:0 options:UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionBeginFromCurrentState
						 animations:^{
							 self.contentInset = contentInset;
						 } completion:^(BOOL finished) {
							 if(completion != nil) {
								 completion(finished);
							 }
						 }];
	} else {
		self.contentInset = contentInset;
		if(completion != nil) {
			completion(YES);
		}
	}
}

@end
