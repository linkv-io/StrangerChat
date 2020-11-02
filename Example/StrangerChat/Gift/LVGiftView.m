//
//  LVGiftView.m
//  GiftDemo
//
//  Created by Wing on 2020/10/26.
//

#import "LVGiftView.h"
#import <Masonry/Masonry.h>
#import "LVHelper.h"

static NSInteger panelH = 299;

@interface LVGiftView ()<UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic, weak) UIView *panelView;
@property (nonatomic, strong) NSArray<LVGiftModel *> *gifts;
@property (nonatomic, strong) LVGiftCell *selectedCell;
@property (nonatomic, copy) void(^sendBlock)(LVGiftModel *gift);
@property (nonatomic, weak) UILabel *balanceLabel;

@end

@implementation LVGiftView

+ (instancetype)showInView:(UIView *)view gifts:(NSArray<LVGiftModel *>*)gifts sendBlock:(void(^)(LVGiftModel *gift))complete {
    LVGiftView *giftView = [self new];
    
    [view addSubview:giftView];
    [giftView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(view);
    }];
    
    giftView.gifts = gifts;
    giftView.sendBlock = complete;
    
    [giftView setupUI];
    [giftView show];
    [giftView addNotification];
    return giftView;
}

- (void)addNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(balanceChanged:) name:@"lv_balance_changed" object:nil];
}

- (void)balanceChanged:(NSNotification *)n {
    self.balanceLabel.text = [NSString stringWithFormat:@"%@", n.object];
}

- (void)setupUI {
    
    UIControl *topControl = [UIControl new];
    [topControl addTarget:self action:@selector(topControlClick) forControlEvents:UIControlEventTouchUpInside];
    
    
    UIView *panelView = [UIView new];
    panelView.backgroundColor = [UIColor colorWithRed:4/255.0 green:20/255.0 blue:30/255.0 alpha:1];
    self.panelView = panelView;
    
    UIImageView *titleIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Gifts/panel_gift"]];
    
    UILabel *titleLabel = [UILabel new];
    titleLabel.text = @"礼物";
    titleLabel.font = [UIFont systemFontOfSize:14];
    titleLabel.textColor = [UIColor colorWithRed:230/255.0 green:230/255.0 blue:230/255.0 alpha:1];
    
    UICollectionViewFlowLayout *layout = [UICollectionViewFlowLayout new];
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    CGFloat screenW = [UIScreen mainScreen].bounds.size.width;
    layout.itemSize = CGSizeMake(screenW / 4, (panelH - 54 - 38) * 0.5);
    layout.minimumLineSpacing = 0;
    layout.minimumInteritemSpacing = 0;
    
    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    collectionView.dataSource = self;
    collectionView.delegate = self;
    collectionView.pagingEnabled = YES;
    collectionView.backgroundColor = [UIColor clearColor];
    collectionView.bounces = NO;
    [collectionView registerClass:[LVGiftCell class] forCellWithReuseIdentifier:@"LVGiftCell"];
    
    UIView *bottomView = [UIView new];
    
    UIImageView *coinView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Gifts/coin"]];
    UILabel *balanceLabel = [UILabel new];
    balanceLabel.font = [UIFont systemFontOfSize:12];
    balanceLabel.textColor = [UIColor whiteColor];
    balanceLabel.text = [NSString stringWithFormat:@"%ld", [self getBalance]];
    self.balanceLabel = balanceLabel;
    
    UIButton *sendBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [sendBtn setTitle:@"赠送" forState:UIControlStateNormal];
    [sendBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    sendBtn.layer.cornerRadius = 16;
    sendBtn.clipsToBounds = YES;
    [sendBtn addTarget:self action:@selector(sendBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [sendBtn setBackgroundColor:[UIColor colorWithRed:21/255.0 green:216/255.0 blue:192/255.0 alpha:1]];
    
    [bottomView addSubview:coinView];
    [bottomView addSubview:balanceLabel];
    [bottomView addSubview:sendBtn];
    
    [coinView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(bottomView).offset(16);
        make.centerY.equalTo(bottomView);
        make.width.height.mas_equalTo(16);
    }];
    [balanceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(coinView.mas_trailing).offset(1);
        make.centerY.equalTo(coinView);
    }];
    [sendBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(bottomView).offset(-16);
        make.centerY.equalTo(coinView);
        make.height.mas_equalTo(32);
        make.width.mas_equalTo(60);
    }];
    
    [self addSubview:topControl];
    [self addSubview:panelView];
    [panelView addSubview:titleIcon];
    [panelView addSubview:titleLabel];
    [panelView addSubview:collectionView];
    [panelView addSubview:bottomView];
    
    [topControl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.top.trailing.equalTo(self);
        make.bottom.equalTo(panelView.mas_top);
    }];
    
    [panelView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_bottom);
        make.leading.trailing.equalTo(self);
        make.height.mas_equalTo(panelH);
    }];
    
    [titleIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(titleLabel);
        make.leading.equalTo(panelView).offset(16);
    }];
    
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(titleIcon.mas_trailing).offset(2);
        make.top.equalTo(panelView).offset(12);
    }];
    
    [collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.equalTo(panelView);
        make.top.equalTo(panelView).offset(38);
        make.height.mas_equalTo(panelH - 54 - 38);
    }];
    
    [bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.equalTo(panelView);
        make.bottom.equalTo(panelView);
        make.height.mas_equalTo(54);
    }];
            
    [self layoutIfNeeded];
}

- (void)show {
    [self.panelView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self);
        make.leading.trailing.equalTo(self);
        make.height.mas_equalTo(panelH);
    }];
    
    [UIView animateWithDuration:0.25 animations:^{
        [self layoutIfNeeded];
    }];
}

- (void)dismiss {
    [self.panelView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_bottom);
        make.leading.trailing.equalTo(self);
        make.height.mas_equalTo(panelH);
    }];
    
    [UIView animateWithDuration:0.25 animations:^{
        [self layoutIfNeeded];
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

#pragma mark - BtnAction
- (void)sendBtnClick:(UIButton *)btn {
    if (!self.selectedCell.model.isStaticGift) {
        [self dismiss];
    }
    
    if (self.sendBlock) {
        self.sendBlock(self.selectedCell.model);
    }
    
    [self minus:self.selectedCell.model.giftPrice];
}

- (void)topControlClick {
    [self dismiss];
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.gifts.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    LVGiftCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"LVGiftCell" forIndexPath:indexPath];
    cell.model = self.gifts[indexPath.item];
    if (indexPath.item == 0) {
        self.selectedCell = cell;
    }
    
    return cell;
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    LVGiftCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"LVGiftCell" forIndexPath:indexPath];
    
    self.selectedCell = cell;
    self.selectedCell.model = self.gifts[indexPath.item];
}

- (void)setSelectedCell:(LVGiftCell *)selectedCell {
    _selectedCell.selected = NO;
    selectedCell.selected = YES;
    _selectedCell = selectedCell;
}

#pragma mark - private
- (NSInteger)getBalance {
    NSString *uid = [LVHelper shared].user.uid;
    if (!uid || uid.length == 0) return 0;
    
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSInteger balance = [ud integerForKey:uid];
    if (balance == 0) {
        balance = 20000000;
        [ud setInteger:balance forKey:uid];
    }
    
    return balance;
}

- (NSInteger)minus:(NSInteger)price {
    NSString *uid = [LVHelper shared].user.uid;
    if (!uid || uid.length == 0) return 0;
    
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSInteger balance = [ud integerForKey:uid] - price;
    [ud setInteger:balance forKey:uid];
    
    self.balanceLabel.text = [NSString stringWithFormat:@"%ld", balance];
    return balance;
}

- (void)dealloc {
    NSLog(@"[Wing] %@ dealloc🍀🍀🍀🍀", self);
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
