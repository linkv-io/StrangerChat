//
//  LVGiftCell.m
//  GiftDemo
//
//  Created by Wing on 2020/10/26.
//

#import "LVGiftCell.h"
#import <Masonry/Masonry.h>
#import "CALayer+FXAnimationEngine.h"

@implementation LVGiftModel
@end

@interface LVGiftCell ()

@property (nonatomic, strong) UIImageView *iconView;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *priceLabel;
@property (nonatomic, strong) UIView *borderView;
@property (nonatomic, strong) UIView *animationView;

@end

@implementation LVGiftCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setupUI];
    }
    
    return self;
}

- (void)setupUI {
    UIView *containerView = [UIView new];
    
    UIView *borderView = [UIView new];
    borderView.layer.borderWidth = 1;
    borderView.layer.borderColor = [UIColor colorWithRed:21/255.0 green:216/255.0 blue:192/255.0 alpha:1].CGColor;
    borderView.hidden = YES;
    borderView.layer.cornerRadius = 4;
    borderView.clipsToBounds = YES;
    self.borderView = borderView;
    
    self.iconView = [UIImageView new];
    self.iconView.contentMode = UIViewContentModeScaleAspectFit;
    
    self.animationView = [UIView new];
    self.animationView.contentMode = UIViewContentModeScaleAspectFit;
    
    self.nameLabel = [UILabel new];
    self.nameLabel.font = [UIFont systemFontOfSize:10];
    self.nameLabel.textColor = [UIColor colorWithRed:230/255.0 green:230/255.0 blue:230/255.0 alpha:1];
    
    UIView *priceView = [UIView new];
    
    UIImageView *priceIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Gifts/Task Chest_Coins"]];

    self.priceLabel = [UILabel new];
    self.priceLabel.font = [UIFont systemFontOfSize:10];
    self.priceLabel.textColor = [UIColor colorWithRed:156/255.0 green:156/255.0 blue:156/255.0 alpha:1];
        
    [priceView addSubview:priceIcon];
    [priceView addSubview:_priceLabel];

    [priceIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(priceView);
        make.centerY.equalTo(priceView);
    }];
    [self.priceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(priceIcon.mas_trailing).offset(4);
            make.centerY.equalTo(priceView);
            make.trailing.equalTo(priceView);
    }];
    
    [self.contentView addSubview:containerView];
    [containerView addSubview:borderView];
    [containerView addSubview:self.iconView];
    [containerView addSubview:self.animationView];
    [containerView addSubview:self.nameLabel];
    [containerView addSubview:priceView];
    
    [containerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.contentView);
    }];
    
    [borderView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(containerView);
    }];
    
    [self.iconView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(containerView).offset(6);
        make.width.height.mas_equalTo(60);
        make.centerX.equalTo(containerView);
    }];
    
    [self.animationView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.iconView);
    }];
    
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.iconView.mas_bottom).offset(2);
        make.centerX.equalTo(self.iconView);
    }];
    
    [priceView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.nameLabel.mas_bottom).offset(2);
        make.centerX.equalTo(self.nameLabel);
        make.height.mas_equalTo(13);
    }];
}

- (void)setModel:(LVGiftModel *)model {
    _model = model;
    
    NSString *imageName = model.isStaticGift ? [NSString stringWithFormat:@"Gifts/%@", model.imageName] : [NSString stringWithFormat:@"Gifts/%@/list/0", model.folderName];
    
    self.iconView.image = [UIImage imageNamed:imageName];
    self.nameLabel.text = model.giftName;
    self.priceLabel.text = [NSString stringWithFormat:@"%d", model.giftPrice];
}

- (void)setSelected:(BOOL)selected {
    self.borderView.hidden = !selected;
    
    if (self.model.isStaticGift) return;
    
    if (selected) {
        [self startAnimation];
    } else {
        [self stopAnimation];
    }
}

- (void)startAnimation {
    if ([self.animationView.layer fx_isAnimating]) return;
    self.iconView.hidden = YES;
    NSMutableArray *arrM = [NSMutableArray arrayWithCapacity:129];
    for (int i = 0; i < self.model.listCount; i++) {
        NSString *imgName = [NSString stringWithFormat:@"Gifts/%@/list/%d", self.model.folderName, i];;
        UIImage *img = [UIImage imageNamed:imgName];
        if (img) {
            [arrM addObject:img];
        } else {
            NSLog(@"[Wing] i = %d", i);
        }
    }
    
    FXKeyframeAnimation *animation = [FXKeyframeAnimation animationWithIdentifier:@"xxx"];
    animation.frames = arrM;
    animation.duration = 2;
    animation.repeats = NSIntegerMax;

    // decode image asynchronously
    [self.animationView.layer fx_playAnimationAsyncDecodeImage:animation];
}

- (void)stopAnimation {
    [self.animationView.layer fx_stopAnimation];
    self.iconView.hidden = NO;
}

@end
