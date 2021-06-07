//
//  StrangerChat.h
//  Pods
//
//  Created by Wing on 2020/9/28.
//

#import <LinkV-Communication/LVCEngine.h>

@protocol StrangerChatDelegate <NSObject>

/// 收到某个用户的呼叫
- (int)onCallReceived:(NSString *)uid
               isAudio:(BOOL)isAudio
            timestamp:(int64_t)timestamp
                 extra:(NSString *)extra;

/// 收到某个用户同意或拒绝的指令
- (int)onAnwserCallReceived:(NSString *)uid
                      accept:(BOOL)accept
                     isAudio:(BOOL)isAudio
                    timestamp:(int64_t)timestamp
                       extra:(NSString *)extra;

/// 收到某个用户挂断通话的回调
- (int)onHangupCallReceived:(NSString *)uid
                       extra:(NSString *)extra;

/// 通话时长变化，每秒更新一次，单位(秒)
- (void)onCallTimeChanged:(NSInteger)duration
                   roomId:(NSString *)roomId;

@end

@protocol LVRoomDelegate <RoomCallbackProtocl>

/// 收到某个用户发送给一批用户的礼物消息
- (int)onGiftReceived:(NSString *)giftId
                 count:(NSInteger)count
               sendUid:(NSString *)sendUid
                   uid:(NSArray<NSString *> *)uids
                roomId:(NSString *)roomId
                 extra:(NSString *)extra;

/// 收到某个用户的上麦申请
- (int)onApplyForBeamRecevied:(NSString *)uid
                        roomId:(NSString *)roomId
                       position:(NSInteger)position
                         extra:(NSString *)extra;

/// 收到上麦同意或拒绝的指令
- (int)onAnwserApplyForBeam:(NSString *)uid
                      accept:(BOOL)accept
                      roomId:(NSString *)roomId
                     position:(NSInteger)position
                       extra:(NSString *)extra;

/// 收到下麦指令
- (int)onKickBeamOffReceived:(NSString *)uid
                       roomId:(NSString *)roomId
                      position:(NSInteger)position
                        extra:(NSString *)extra;

/// 收到关闭房间消息
- (int)onEndRoomReceived:(NSString *)roomId
                    extra:(NSString *)extra;

/// 某个用户进入房间
- (int)onUserEntered:(NSString *)uid
               roomId:(NSString *)roomId;

/// 某个用户离开房间
- (int)onUserLeaft:(NSString *)uid
             roomId:(NSString *)roomId;

/// 某个用户的麦克风状态发生了变化
- (int)onUserMicrophoneChanged:(NSString *)uid
                        roomId:(NSString *)roomId
                          open:(BOOL)isOpen;

/// 某个用户的摄像头状态发生了变化
- (int)onUserVideoCameraChanged:(NSString *)uid
                        roomId:(NSString *)roomId
                          open:(BOOL)isOpen;

@end

@interface StrangerChat : LVCEngine

+ (instancetype)createEngine:(NSString *)appId
                      appKey:(NSString *)appKey
                  completion:(LVCodeCompletion)completion
                    delegate:(id<LVRoomDelegate, StrangerChatDelegate, LVIMReceiveMessageDelegate>)delegate;

/// 呼叫指定用户
- (int)call:(NSString *)uid
     isAudio:(BOOL)isAudio
       extra:(NSString *)extra
    callback:(LVIM_SEND_MESSAGE_CALLBACK)callback;

/// 同意或拒绝某个用户的呼叫
- (int)anwserCall:(NSString *)uid
            accept:(BOOL)accept
           isAudio:(BOOL)isAudio
             extra:(NSString *)extra
          callback:(LVIM_SEND_MESSAGE_CALLBACK)callback;

/// 主动挂断电话
- (int)hangupCall:(NSString *)uid
            extra:(NSString *)extra
         callback:(LVIM_SEND_MESSAGE_CALLBACK)callback;

- (void)setRoomDelegate:(id<LVRoomDelegate>)roomDelegate;

#pragma mark - 多人party房间
/// 发送礼物
- (int)sendGift:(NSString *)giftId
           count:(NSInteger)count
             uid:(NSArray<NSString *> *)uids
          roomId:(NSString *)roomId
           extra:(NSString *)extra
        callback:(LVIM_SEND_MESSAGE_CALLBACK)callback;

/// 申请上麦
- (int)applyForBeam:(NSString *)roomId
             position:(NSInteger)position
               extra:(NSString *)extra
            callback:(LVIM_SEND_MESSAGE_CALLBACK)callback;

/// 同意或拒绝某个用户的上麦
- (int)anwserApplyForBeam:(NSString *)uid
                    accept:(BOOL)accept
                    roomId:(NSString *)roomId
                   position:(NSInteger)position
                     extra:(NSString *)extra
                  callback:(LVIM_SEND_MESSAGE_CALLBACK)callback;

/// 让某个用户下麦
- (int)kickBeamOff:(NSString *)uid
             roomId:(NSString *)roomId
           position:(NSInteger)position
              extra:(NSString *)extra
           callback:(LVIM_SEND_MESSAGE_CALLBACK)callback;

/// 关闭房间
- (int)endRoom:(NSString *)roomId
          extra:(NSString *)extra
       callback:(LVIM_SEND_MESSAGE_CALLBACK)callback;


@end

