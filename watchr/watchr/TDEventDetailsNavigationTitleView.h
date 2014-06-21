//
//  TDEventDetailsNavigationTitleView.h
//  watchr
//
//  Created by Tudor Dragan on 20/6/14.
//  Copyright (c) 2014 Tudor Dragan. All rights reserved.
//

#import <UIKit/UIKit.h>
@class TDEventDetailsNavigationTitleView;
@protocol TDEventDetailsNavigationTitleViewDelegate <NSObject>

-(void) titleViewTapped:(TDEventDetailsNavigationTitleView*) titleView;

@end

@interface TDEventDetailsNavigationTitleView : UIView{

}

@property (nonatomic,strong) UILabel *titleLabel;
@property (nonatomic,strong) UILabel *subtitleLabel;
@property (nonatomic,assign) id<TDEventDetailsNavigationTitleViewDelegate> delegate;
+(TDEventDetailsNavigationTitleView*) titleViewWithTitle:(NSString *) title andSubtitle:(NSString *) subtitle;
- (id)initWithFrame:(CGRect)frame;
@end
