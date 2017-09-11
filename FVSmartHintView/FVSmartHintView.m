//
//  FVSmartHintView.m
//  FVSmartHintView
//
//  Created by lixuelin on 2017/8/24.
//  Copyright © 2017年 Huixiang. All rights reserved.
//

#import "FVSmartHintView.h"
#import "Masonry.h"

static NSString * const kCellID = @"kCellID";

@interface FVSmartHintView ()<UITableViewDelegate,UITableViewDataSource,UITextViewDelegate>

@property (nonatomic, strong) NSArray *suggestOptions;
@property (nonatomic, strong) UITextView *textView;
@property (nonatomic, strong) NSArray *sourceItems;
@property (nonatomic, strong) UIView *bottomLine;

@end

@implementation FVSmartHintView

- (UITableView *)initWithTextView:(UITextView *)textView inViewController:(UIViewController *)parentViewController
{
    self.textView = textView;
    self.textView.delegate = self;
    CGRect frame = CGRectMake(self.textView.frame.origin.x, textView.frame.origin.y+textView.frame.size.height, 100, [FVSmartHintViewCell cellHeight] * 3);
    self = [super initWithFrame:frame style:UITableViewStylePlain];
    [self setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self registerClass:[FVSmartHintViewCell class] forCellReuseIdentifier:kCellID];
    self.delegate = self;
    self.dataSource = self;
    self.scrollEnabled = YES;
    
    textView.autocorrectionType = UITextAutocorrectionTypeNo;
    UIView *v = [[UIView alloc] initWithFrame:CGRectMake(0, 0, textView.frame.size.width, 1)];
    v.backgroundColor = [UIColor clearColor];
    [self setTableFooterView:v];
    self.hidden = YES;
    [parentViewController.view addSubview:self];
    self.clipsToBounds = YES;
    self.layer.borderWidth = 1.f / [UIScreen mainScreen].scale;
    self.layer.borderColor = [UIColor lightGrayColor].CGColor;
    return self;
}

- (void)setSmartHintDelegate:(id<FVSmartHintViewDelegate>)smartHintDelegate
{
    _smartHintDelegate = smartHintDelegate;
}

- (void)layoutSubviews
{
    [super layoutSubviews];

    CGRect frame = self.frame;
    CGFloat y = self.textView.frame.origin.y + self.textView.frame.size.height;
    frame.origin.y = y;
    self.frame = frame;
}

#pragma mark - <UITableViewDelegate,UITableViewDataSource>

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.suggestOptions.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    FVSmartHintViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellID forIndexPath:indexPath];
    cell.nameLabel.text = [self.suggestOptions objectAtIndex:indexPath.row];
    cell.nameLabel.font = self.smartHintTextFont ? : self.textView.font;
    cell.seperatorLine.hidden = (indexPath.row == self.suggestOptions.count - 1) ? YES : NO;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [FVSmartHintViewCell cellHeight];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.textView setText:[self.suggestOptions objectAtIndex:indexPath.row]];
    if (_smartHintDelegate && [_smartHintDelegate respondsToSelector:@selector(smartHintView:didSelectSmartHintSuggestionWithIndex:)])
    {
        [_smartHintDelegate smartHintView:self didSelectSmartHintSuggestionWithIndex:indexPath.row];
    }
    [self hideOptionsView];
}

#pragma mark - <UITableViewDelegate>

- (void)textViewDidChange:(UITextView *)textView
{
    self.textView = textView;
    NSString *curString = textView.text;
    if (![curString length])
    {
        [self hideOptionsView];
        return;
    }
    else if ([self substringIsInSourceItems:curString])
    {
        [self showOptionsView];
        [self reloadData];
    }
    else
    {
        [self hideOptionsView];
    }
    if (self.textView.selectedTextRange.isEmpty)
    {
        CGFloat maxX = [UIScreen mainScreen].bounds.size.width - 20 - 100;
        CGFloat minX = 20;
        CGFloat x = [self.textView caretRectForPosition:self.textView.selectedTextRange.start].origin.x;
        CGRect frame = self.frame;
        CGFloat calcuX = x + self.textView.frame.origin.x - 50;
        CGFloat factX = (calcuX < minX ? minX : calcuX) > maxX ? maxX : (calcuX < minX ? minX : calcuX);
        frame.origin.x = factX;
        self.frame = frame;
        [self layoutSubviews];
    }
    
    if (self.smartHintDelegate && [self.smartHintDelegate respondsToSelector:@selector(textViewValueDidChanged:)])
    {
        [self.smartHintDelegate textViewValueDidChanged:self.textView];
    }
}

#pragma mark - Logic staff

- (BOOL)substringIsInSourceItems:(NSString *)subString
{
    subString = [subString substringWithRange:NSMakeRange(subString.length - 1, 1)];
    NSMutableArray *tmpArray = [NSMutableArray array];
    NSRange range;
    
    if (_smartHintDelegate && [_smartHintDelegate respondsToSelector:@selector(smartHintView:suggestionsFor:)])
    {
        self.sourceItems = [_smartHintDelegate smartHintView:self suggestionsFor:subString];
    }
    for (NSString *tmpString in self.sourceItems)
    {
        range = self.smartHintCaseSensitive ? [tmpString rangeOfString:subString] :
                [tmpString rangeOfString:subString options:NSCaseInsensitiveSearch];
        if (range.location != NSNotFound) [tmpArray addObject:tmpString];
    }
    if ([tmpArray count]>0)
    {
        self.suggestOptions = tmpArray;
        return YES;
    }
    return NO;
}

#pragma mark - Options view control

- (void)showOptionsView
{
    self.hidden = NO;
}

- (void) hideOptionsView
{
    self.hidden = YES;
}

- (UIView *)bottomLine
{
    if (!_bottomLine)
    {
        _bottomLine = [[UIView alloc] init];
        _bottomLine.backgroundColor = [UIColor lightGrayColor];
    }
    return _bottomLine;
}

@end

@implementation FVSmartHintViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        [self setupChildView];
    }
    return self;
}

- (void)setupChildView
{
    [self.contentView addSubview:self.nameLabel];
    [self.contentView addSubview:self.seperatorLine];
    
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15.f);
        make.centerY.mas_equalTo(0.f);
    }];
    [self.seperatorLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.left.right.mas_equalTo(0.f);
        make.height.mas_equalTo(1.f/[UIScreen mainScreen].scale);
    }];
}

+ (CGFloat)cellHeight
{
    return 40.f;
}

#pragma mark - lazy load

- (UILabel *)nameLabel
{
    if (!_nameLabel)
    {
        _nameLabel = [[UILabel alloc] init];
    }
    return _nameLabel;
}

- (UIView *)seperatorLine
{
    if (!_seperatorLine)
    {
        _seperatorLine = [[UIView alloc] init];
        _seperatorLine.backgroundColor = [UIColor lightGrayColor];
    }
    return _seperatorLine;
}

@end
