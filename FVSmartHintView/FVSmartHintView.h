//
//  FVSmartHintView.h
//  FVSmartHintView
//
//  Created by lixuelin on 2017/8/24.
//  Copyright © 2017年 Huixiang. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FVSmartHintView;

@protocol FVSmartHintViewDelegate <NSObject>

@required
/** data source */
- (NSArray*)smartHintView:(FVSmartHintView *)smartHintView suggestionsFor:(NSString*) string;
/** click cell action */
- (void)smartHintView:(FVSmartHintView *)smartHintView didSelectSmartHintSuggestionWithIndex:(NSInteger)index;
/** action of textview value changed eg. update height of textview and so on .. */
- (void)textViewValueDidChanged:(UITextView *)textView;

@end

@interface FVSmartHintView : UITableView

@property (nonatomic, weak) id<FVSmartHintViewDelegate>smartHintDelegate;
/** ignore case or not */
@property (nonatomic, assign) BOOL smartHintCaseSensitive;
/** setting result font, Default is textView font */
@property (nonatomic, strong) UIFont *smartHintTextFont;
/** setting key world high color */
@property (nonatomic, strong) UIColor *keyHighlightColor;

/** initialize method */
- (UITableView *)initWithTextView:(UITextView *)textView inViewController:(UIViewController *)parentViewController;

@end


@interface FVSmartHintViewCell : UITableViewCell

@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UIView *seperatorLine;

+ (CGFloat)cellHeight;

@end
