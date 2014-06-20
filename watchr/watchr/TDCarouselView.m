//
//  TDCarouselView.m
//  watchr
//
//  Created by Tudor Dragan on 22/5/14.
//  Copyright (c) 2014 Tudor Dragan. All rights reserved.
//

#import "TDCarouselView.h"


@interface TDCarouselView()<UIScrollViewDelegate>
@property (nonatomic, strong) UIScrollView * scrollView;
@property (nonatomic, strong) UIPageControl * pageControl;
@property (nonatomic, strong) NSMutableArray * imageViewArray;
@end

@implementation TDCarouselView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
		
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame andImageURLs:(NSArray*) imageURLArray{
	self = [super initWithFrame:frame];
	if(self){
		//set up the scroll view
		self.scrollView = [[UIScrollView alloc] initWithFrame:frame];
		[self.scrollView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
		
		//scrollView options
		[self.scrollView setDelegate:self];
		[self.scrollView setPagingEnabled:YES];
		[self.scrollView setDirectionalLockEnabled:YES];
		
		
		//add the images from the array to the scroll view
		self.imageViewArray = [[NSMutableArray alloc] init];
		for (NSURL * url in imageURLArray) {
			UIImageView * imageView = [[UIImageView alloc] initWithFrame:frame];
			[imageView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
			[imageView setContentMode:UIViewContentModeScaleAspectFill];
			[imageView setClipsToBounds:YES];
			[imageView setImageWithURL:url placeholderImage:[UIImage imageNamed:@"placeholder-image.png"]];
			
			[self.imageViewArray addObject:imageView];
			
			[imageView setFrame:CGRectMake(([self.imageViewArray count] - 1 ) *  frame.size.width, 0, frame.size.width, frame.size.height)];
			[self.scrollView addSubview:imageView];
		}
		
		[self.scrollView setContentSize:CGSizeMake([self.imageViewArray count] * frame.size.width, frame.size.height)];
		
		[self addSubview:self.scrollView];
		
		
		//add the pageControl
		self.pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, 36)];
		[self.pageControl setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin];
		[self.pageControl setNumberOfPages:[self.imageViewArray count]];
		[self.pageControl setCurrentPage:0];
		
		//set the frame to be in the center
		[self addSubview:self.pageControl];
		//TODO: Change the page control positioning
		[self.pageControl setCenter:CGPointMake(frame.size.width / 2 , frame.size.height - 20)];
		
		
	}
	return self;
}

-(void) scrollViewDidScroll:(UIScrollView *)scrollView{
	CGFloat pageWidth = self.scrollView.frame.size.width;
    int page = floor((self.scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    self.pageControl.currentPage = page;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
