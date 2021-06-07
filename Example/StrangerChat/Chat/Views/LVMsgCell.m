//
//  LVMsgCell.m
//  StrangerChat_Example
//
//  Created by Wing on 2021/6/2.
//  Copyright © 2021 wangyansnow. All rights reserved.
//

#import "LVMsgCell.h"
#import "StrangerChat.h"
#import "LVHelper.h"
#import <Masonry/Masonry.h>

@interface LVMsgCell ()

@property (nonatomic, weak) UILabel *contentLabel;

@end

@implementation LVMsgCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self setupUI];
    }
    
    return self;
}

- (void)setupUI {
    self.backgroundColor = [UIColor clearColor];
    UIView *bgView = [UIView new];
    bgView.backgroundColor = [UIColor colorWithRed:32/255.0 green:31/255.0 blue:20/255.0 alpha:0.7];
    bgView.layer.cornerRadius = 4;
    bgView.clipsToBounds = YES;
    
    UILabel *contentLabel = [UILabel new];
    self.contentLabel = contentLabel;
    contentLabel.numberOfLines = 3;
    
    [self.contentView addSubview:bgView];
    [bgView addSubview:contentLabel];
    
    [bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.top.equalTo(self.contentView);
        make.bottom.equalTo(self.contentView).offset(-10);
    }];
    
    [contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.top.equalTo(bgView).offset(10);
        make.trailing.bottom.equalTo(bgView).offset(-10);
    }];
}

- (void)setMsg:(LVIMMessage *)msg {
    _msg = msg;
    
    if (!msg.mContent) return;
    
    LVUserModel *sender = [[LVHelper shared] userFormUid:msg.mFromID];
    NSString *nickName =[NSString stringWithFormat:@"%@ ", sender.nickName];
    NSString *content = [[NSString alloc] initWithData:msg.mContent encoding:NSUTF8StringEncoding];
    
    NSMutableAttributedString *attrM = [[NSMutableAttributedString alloc] initWithString:nickName attributes:@{NSForegroundColorAttributeName: [UIColor colorWithRed:144/225.0 green:217/255.0 blue:218/255.0 alpha:1]}];
    NSAttributedString *contentAttr = [[NSAttributedString alloc] initWithString:content attributes:@{NSForegroundColorAttributeName: [UIColor whiteColor]}];
    [attrM appendAttributedString:contentAttr];
    
    self.contentLabel.attributedText = attrM;
}

@end
