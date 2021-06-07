//
//  LVMsgListView.m
//  StrangerChat_Example
//
//  Created by Wing on 2021/6/2.
//  Copyright © 2021 wangyansnow. All rights reserved.
//

#import "LVMsgListView.h"
#import "LVMsgCell.h"
#import <Masonry/Masonry.h>
#import "StrangerChat.h"
#import "LVHelper.h"

@interface LVMsgListView()<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, weak) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *datasource;

@end

@implementation LVMsgListView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setupUI];
        self.datasource = [NSMutableArray array];
    }
    
    return self;
}

- (void)setupUI {
    UITableView *tableView = [UITableView new];
    tableView.dataSource = self;
    tableView.delegate = self;
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    tableView.backgroundColor = [UIColor clearColor];
    tableView.showsVerticalScrollIndicator = NO;
    tableView.transform = CGAffineTransformMakeScale (1,-1);
    self.tableView = tableView;
    
    [tableView registerClass:[LVMsgCell class] forCellReuseIdentifier:NSStringFromClass([LVMsgCell class])];
    
    [self addSubview:tableView];
    
    [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
}

- (void)addMsg:(LVIMMessage *)msg {
    [self.datasource insertObject:msg atIndex:0];

    [self.tableView reloadData];
    [self scroolToBottom];
}

- (void)scroolToBottom {
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]  atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
}

#pragma mark - UITableViewDataSrouce
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.datasource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    LVMsgCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([LVMsgCell class])];
    cell.msg = self.datasource[indexPath.row];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.transform = CGAffineTransformMakeScale (1,-1);
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
   
    LVIMMessage *msg = self.datasource[indexPath.row];
    LVUserModel *sender = [[LVHelper shared] userFormUid:msg.mFromID];
    NSString *content = [[NSString alloc] initWithData:msg.mContent encoding:NSUTF8StringEncoding];
    
    content = [NSString stringWithFormat:@"%@ %@", sender.nickName, content];
    
    CGFloat w = [UIScreen mainScreen].bounds.size.width - 111 - 20;
    CGRect rect = [content boundingRectWithSize:CGSizeMake(w, 0) options:0 attributes:nil context:nil];
    
    return rect.size.height + 20 + 10;
    
}
@end
