//
//  StrangerChat.m
//  Pods
//
//  Created by Wing on 2020/9/28.
//

#import "StrangerChat.h"

static NSString *linkv_video_call = @"linkv_video_call";
static NSString *linkv_anwser_call = @"linkv_anwser_call";
static NSString *linkv_hangup_call = @"linkv_hangup_call";
static NSString *linkv_gift = @"linkv_gift";
static NSString *linkv_apply_for_beam = @"linkv_apply_for_beam";
static NSString *linkv_anwser_apply_for_beam = @"linkv_anwser_apply_for_beam";
static NSString *linkv_kick_beam_off = @"linkv_kick_beam_off";
static NSString *linkv_end_room = @"linkv_end_room";
static NSString *linkv_enter_room = @"linkv_enter_room";
static NSString *linkv_leave_room = @"linkv_leave_room";
static NSString *linkv_enable_mic = @"linkv_enable_mic";     // 开启或关闭麦克风
static NSString *linkv_enable_video = @"linkv_enable_video"; // 开启或关闭摄像头


@interface StrangerChat ()<LVIMReceiveMessageDelegate, RoomCallbackProtocl>

@property (nonatomic, weak) id<StrangerChatDelegate, LVIMReceiveMessageDelegate> chatDelegate;
@property (nonatomic, weak) id<LVRoomDelegate> roomDelegate;
@property (nonatomic, copy) NSString *roomId;

@end

@implementation StrangerChat

+ (instancetype)createEngine:(NSString *)appId
                      appKey:(NSString *)appKey
                  completion:(LVCodeCompletion)completion
                    delegate:(id<LVRoomDelegate, StrangerChatDelegate, LVIMReceiveMessageDelegate>)delegate; {

    StrangerChat *chat = [self createEngineWithAppId:appId appKey:appKey completion:completion];
    
    [[LVIMSDK sharedInstance] setGlobalReceiveMessageDelegate:chat];
    chat.chatDelegate = delegate;
    chat.roomDelegate = delegate;
    
    [chat setRoomMsgDelegate:chat];
    
    return chat;
}

/// 呼叫指定用户
- (int)call:(NSString *)uid
    isAudio:(BOOL)isAudio
      extra:(NSString *)extra
   callback:(LVIM_SEND_MESSAGE_CALLBACK)callback {
    
    if (!uid) return -1;
    NSMutableDictionary *dictM = [NSMutableDictionary dictionary];
    dictM[@"isAudio"] = @(isAudio);
    dictM[@"extra"] = extra;
    NSString *content = [self dictToStr:dictM];
    LVIMMessage *message = [LVIMMessage new];
    int result = [message buildEventRequest:self.uid tid:uid type:linkv_video_call content:content pushTitle:nil pushContent:nil targetAppID:nil targetAppUID:nil];
    if (result != 0) return result;
    [[LVIMSDK sharedInstance] sendMessage:message context:nil callback:callback];
    
    return result;
}

/// 同意或拒绝某个用户的呼叫
- (int)anwserCall:(NSString *)uid
           accept:(BOOL)accept
          isAudio:(BOOL)isAudio
            extra:(NSString *)extra
         callback:(LVIM_SEND_MESSAGE_CALLBACK)callback {
    
    if (!uid) return -1;
    NSMutableDictionary *dictM = [NSMutableDictionary dictionary];
    dictM[@"accept"] = @(accept);
    dictM[@"isAudio"] = @(isAudio);
    dictM[@"extra"] = extra;
    NSString *content = [self dictToStr:dictM];
    LVIMMessage *message = [LVIMMessage new];
    int result = [message buildEventRequest:self.uid tid:uid type:linkv_anwser_call content:content pushTitle:nil pushContent:nil targetAppID:nil targetAppUID:nil];
    if (result != 0) return result;
    [[LVIMSDK sharedInstance] sendMessage:message context:nil callback:callback];
    
    return result;
}

/// 主动挂断电话
- (int)hangupCall:(NSString *)uid
            extra:(NSString *)extra
         callback:(LVIM_SEND_MESSAGE_CALLBACK)callback {
    
    if (!uid) return -1;
    LVIMMessage *message = [LVIMMessage new];
    NSMutableDictionary *dictM = [NSMutableDictionary dictionary];
    dictM[@"extra"] = extra;
    NSString *content = [self dictToStr:dictM];
    int result = [message buildEventRequest:self.uid tid:uid type:linkv_hangup_call content:content pushTitle:nil pushContent:nil targetAppID:nil targetAppUID:nil];
    if (result != 0) return result;
    [[LVIMSDK sharedInstance] sendMessage:message context:nil callback:callback];
    
    return result;
}

- (void)setRoomDelegate:(id<LVRoomDelegate>)roomDelegate {
    _roomDelegate = roomDelegate;    
}

#pragma mark - 多人party房间
/// 发送礼物
- (int)sendGift:(NSString *)giftId
           count:(NSInteger)count
             uid:(NSArray<NSString *> *)uids
          roomId:(NSString *)roomId
           extra:(NSString *)extra
        callback:(LVIM_SEND_MESSAGE_CALLBACK)callback {
    
    if (!uids || !giftId) return -1;
    NSMutableDictionary *dictM = [NSMutableDictionary dictionary];
    dictM[@"extra"] = extra;
    dictM[@"uids"] = uids;
    dictM[@"giftId"] = giftId;
    NSString *content = [self dictToStr:dictM];
    LVIMMessage *message = [self sendRoomMessage:roomId content:content msgType:linkv_gift complete:callback];
    
    return message == nil ? -1 : 0;
}


/// 申请上麦
- (int)applyForBeam:(NSString *)roomId
             position:(NSInteger)position
               extra:(NSString *)extra
            callback:(LVIM_SEND_MESSAGE_CALLBACK)callback {
    
    if (!roomId) return -1;
    NSMutableDictionary *dictM = [NSMutableDictionary dictionary];
    dictM[@"position"] = @(position);
    dictM[@"extra"] = extra;
    NSString *content = [self dictToStr:dictM];
    LVIMMessage *message = [self sendRoomMessage:roomId content:content msgType:linkv_apply_for_beam complete:callback];
    return message == nil ? -1 : 0;
}

/// 同意或拒绝某个用户的上麦
- (int)anwserApplyForBeam:(NSString *)uid
                    accept:(BOOL)accept
                    roomId:(NSString *)roomId
                   position:(NSInteger)position
                     extra:(NSString *)extra
                  callback:(LVIM_SEND_MESSAGE_CALLBACK)callback {
    
    if (!roomId || !uid) return -1;
    NSMutableDictionary *dictM = [NSMutableDictionary dictionary];
    dictM[@"accept"] = @(accept);
    dictM[@"position"] = @(position);
    dictM[@"extra"] = extra;
    dictM[@"uid"] = uid;
    NSString *content = [self dictToStr:dictM];
    LVIMMessage *message = [self sendRoomMessage:roomId content:content msgType:linkv_anwser_apply_for_beam complete:callback];
    return message == nil ? -1 : 0;
}

/// 让某个用户下麦
- (int)kickBeamOff:(NSString *)uid
             roomId:(NSString *)roomId
           position:(NSInteger)position
              extra:(NSString *)extra
           callback:(LVIM_SEND_MESSAGE_CALLBACK)callback {
    
    if (!roomId || !uid) return -1;
    NSMutableDictionary *dictM = [NSMutableDictionary dictionary];
    dictM[@"uid"] = uid;
    dictM[@"position"] = @(position);
    dictM[@"extra"] = extra;
    NSString *content = [self dictToStr:dictM];
    LVIMMessage *message = [self sendRoomMessage:roomId content:content msgType:linkv_kick_beam_off complete:callback];
    return message == nil ? -1 : 0;
}

/// 关闭房间
- (int)endRoom:(NSString *)roomId
          extra:(NSString *)extra
       callback:(LVIM_SEND_MESSAGE_CALLBACK)callback {
    
    if (!roomId) return -1;
    NSMutableDictionary *dictM = [NSMutableDictionary dictionary];
    dictM[@"extra"] = extra;
    NSString *content = [self dictToStr:dictM];
    LVIMMessage *message = [self sendRoomMessage:roomId content:content msgType:linkv_end_room complete:callback];
    return message == nil ? -1 : 0;
}

#pragma mark - LVIMReceiveMessageDelegate
- (BOOL)onIMReceiveMessageFilter:(int32_t)diytype fromid:(const char *)fromid toid:(const char *)toid msgtype:(const char *)msgtype content:(const char *)content waitings:(int)waitings packetSize:(int)packetSize waitLength:(int)waitLength bufferSize:(int)bufferSize {
    return NO;
}

- (int)onIMReceiveMessageHandler:(NSString *)owner immsg:(LVIMMessage *)immsg waitings:(int)waitings packetSize:(int)packetSize waitLength:(int)waitLength bufferSize:(int)bufferSize {

    if (!immsg.mContent) return 0;
    NSString *type = [[NSString alloc] initWithData:immsg.mExtend1 encoding:NSUTF8StringEncoding];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        int result = 0;
        if ([immsg isChatroomMessage]) {
            if ([type isEqualToString:linkv_gift]) {
                if ([self.roomDelegate respondsToSelector:@selector(onGiftReceived:count:sendUid:uid:roomId:extra:)]) {
                    NSDictionary *dict = [self dataToDict:immsg.mContent];
                    result = [self.roomDelegate onGiftReceived:dict[@"giftId"] count:[dict[@"count"] integerValue] sendUid:immsg.mFromID uid:dict[@"uids"] roomId:immsg.mToID extra:dict[@"extra"]];
                }
            } else if ([type isEqualToString:linkv_apply_for_beam]) {
                if ([self.roomDelegate respondsToSelector:@selector(onApplyForBeamRecevied:roomId:position:extra:)]) {
                    NSDictionary *dict = [self dataToDict:immsg.mContent];
                    result = [self.roomDelegate onApplyForBeamRecevied:immsg.mFromID roomId:immsg.mToID position:[dict[@"position"] integerValue] extra:dict[@"extra"]];
                }
            } else if ([type isEqualToString:linkv_anwser_apply_for_beam]) {
                if ([self.roomDelegate respondsToSelector:@selector(onAnwserApplyForBeam:accept:roomId:position:extra:)]) {
                    NSDictionary *dict = [self dataToDict:immsg.mContent];
                    result = [self.roomDelegate onAnwserApplyForBeam:dict[@"uid"] accept:[dict[@"accept"] boolValue] roomId:immsg.mToID position:[dict[@"position"] integerValue] extra:dict[@"extra"]];
                }
            } else if ([type isEqualToString:linkv_kick_beam_off]) {
                if ([self.roomDelegate respondsToSelector:@selector(onKickBeamOffReceived:roomId:position:extra:)]) {
                    NSDictionary *dict = [self dataToDict:immsg.mContent];
                    result = [self.roomDelegate onKickBeamOffReceived:dict[@"uid"] roomId:immsg.mToID position:[dict[@"position"] integerValue] extra:dict[@"extra"]];
                }
            } else if ([type isEqualToString:linkv_end_room]) {
                if ([self.roomDelegate respondsToSelector:@selector(onEndRoomReceived:extra:)]) {
                    NSDictionary *dict = [self dataToDict:immsg.mContent];
                    result = [self.roomDelegate onEndRoomReceived:immsg.mToID extra:dict[@"extra"]];
                }
            } else if ([type isEqualToString:linkv_enter_room]) {
                if ([self.roomDelegate respondsToSelector:@selector(onUserEntered:roomId:)]) {
                    result = [self.roomDelegate onUserEntered:immsg.mFromID roomId:immsg.mToID];
                }
            } else if ([type isEqualToString:linkv_leave_room]) {
                if ([self.roomDelegate respondsToSelector:@selector(onUserLeaft:roomId:)]) {
                    result = [self.roomDelegate onUserLeaft:immsg.mFromID roomId:immsg.mToID];
                }
            } else if ([type isEqualToString:linkv_enable_mic]) {
                if ([self.roomDelegate respondsToSelector:@selector(onUserMicrophoneChanged:roomId:open:)]) {
                    NSString *str = [[NSString alloc] initWithData:immsg.mContent encoding:NSUTF8StringEncoding];
                    result = [self.roomDelegate onUserMicrophoneChanged:immsg.mFromID roomId:immsg.mToID open:[str boolValue]];
                }
            } else if ([type isEqualToString:linkv_enable_video]) {
                if ([self.roomDelegate respondsToSelector:@selector(onUserVideoCameraChanged:roomId:open:)]) {
                    NSString *str = [[NSString alloc] initWithData:immsg.mContent encoding:NSUTF8StringEncoding];
                    result = [self.roomDelegate onUserVideoCameraChanged:immsg.mFromID roomId:immsg.mToID open:[str boolValue]];
                }
            }
            else {
                if ([self.roomDelegate respondsToSelector:@selector(onRoomMessageReceive:)]) {
                    result = [self.roomDelegate onRoomMessageReceive:immsg];
                }
            }
        } else {

            if (immsg.mCmdType == 30) {
                if ([type isEqualToString:linkv_video_call]) {
                    if ([self.chatDelegate respondsToSelector:@selector(onCallReceived:isAudio:timestamp:extra:)]) {
                        NSDictionary *dict = [self dataToDict:immsg.mContent];
                        result = [self.chatDelegate onCallReceived:immsg.mFromID isAudio:[dict[@"isAudio"] boolValue] timestamp:immsg.mServerTimestamp extra:dict[@"extra"]];
                    }
                } else if ([type isEqualToString:linkv_anwser_call]) {
                    if ([self.chatDelegate respondsToSelector:@selector(onAnwserCallReceived:accept:isAudio:timestamp:extra:)]) {
                        NSDictionary *dict = [self dataToDict:immsg.mContent];
                        result = [self.chatDelegate onAnwserCallReceived:immsg.mFromID accept:[dict[@"accept"] boolValue] isAudio:[dict[@"isAudio"] boolValue] timestamp:immsg.mServerTimestamp extra:dict[@"extra"]];
                    }
                } else if ([type isEqualToString:linkv_hangup_call]) {
                    if ([self.chatDelegate respondsToSelector:@selector(onHangupCallReceived:extra:)]) {
                        NSDictionary *dict = [self dataToDict:immsg.mContent];
                        result = [self.chatDelegate onHangupCallReceived:immsg.mFromID extra:dict[@"extra"]];
                    }
                } else {
                    if ([self.chatDelegate respondsToSelector:@selector(onIMReceiveMessageHandler:immsg:waitings:packetSize:waitLength:bufferSize:)]) {
                        result = [self.chatDelegate onIMReceiveMessageHandler:owner immsg:immsg waitings:waitLength packetSize:packetSize waitLength:waitLength bufferSize:bufferSize];
                    }
                }
            } else {
                if ([self.chatDelegate respondsToSelector:@selector(onIMReceiveMessageHandler:immsg:waitings:packetSize:waitLength:bufferSize:)]) {
                    result = [self.chatDelegate onIMReceiveMessageHandler:owner immsg:immsg waitings:waitLength packetSize:packetSize waitLength:waitLength bufferSize:bufferSize];
                }
            }
        }
    });
    return 0;
}

#pragma mark - private
- (NSString *)dictToStr:(NSDictionary *)dict {
    if (!dict || ![dict isKindOfClass:[NSDictionary class]]) return nil;
    
    NSError *error;
    NSData *data = [NSJSONSerialization dataWithJSONObject:dict options:0 error:&error];
    if (error || !data) return nil;
    
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}

- (NSDictionary *)dataToDict:(NSData *)data {
    if (!data) return nil;
    
    NSError *error;
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
    if (error || !dict || ![dict isKindOfClass:[NSDictionary class]]) return nil;
    
    return dict;
}

#pragma mark - 重载函数
- (void)loginRoom:(NSString *)uid roomId:(NSString *)roomId isHost:(BOOL)isHost delegate:(id<RoomCallbackProtocl>)delegate {
    [super loginRoom:uid roomId:roomId isHost:isHost delegate:delegate];
    self.roomId = roomId;
}

- (void)logoutRoom {
    [self sendRoomMessage:self.roomId content:@"leave room" msgType:linkv_leave_room complete:nil];
    [super logoutRoom];
}

- (void)startCapture {
    [super startCapture];
    
    [self sendRoomMessage:self.roomId content:@"1" msgType:linkv_enable_video complete:nil];
}

- (void)stopCapture {
    [super stopCapture];
    
    [self sendRoomMessage:self.roomId content:@"0" msgType:linkv_enable_video complete:nil];
}

- (void)enableMic:(BOOL)isMute {
    [super enableMic:isMute];
    
    [self sendRoomMessage:self.roomId content:isMute ? @"0" : @"1" msgType:linkv_enable_mic complete:nil];
}

#pragma mark - RoomCallbackProtocl
- (void)onAddRemoterUser:(NSString *)uid {
    if ([self.roomDelegate respondsToSelector:@selector(onAddRemoterUser:)]) {
        [self.roomDelegate onAddRemoterUser:uid];
    }
}

- (void)onRemoteLeave:(NSString *)uid {
    if ([self.roomDelegate respondsToSelector:@selector(onRemoteLeave:)]) {
        [self.roomDelegate onRemoteLeave:uid];
    }
}

- (void)onRoomDisconnect:(int)errorCode roomId:(NSString *)roomId {
    if ([self.roomDelegate respondsToSelector:@selector(onRoomDisconnect:roomId:)]) {
        [self.roomDelegate onRoomDisconnect:errorCode roomId:roomId];
    }
}

- (void)onRoomConnected:(NSString *)roomId {
    if ([self.roomDelegate respondsToSelector:@selector(onRoomConnected:)]) {
        [self.roomDelegate onRoomConnected:roomId];
    }
    
    [self sendRoomMessage:roomId content:@"enter room" msgType:linkv_enter_room complete:nil];
}
- (void)onVideoSizeChanged:(NSString *)uid width:(int)width height:(int)height {
    if ([self.roomDelegate respondsToSelector:@selector(onVideoSizeChanged:width:height:)]) {
        [self.roomDelegate onVideoSizeChanged:uid width:width height:height];
    }
}
- (void)onPublishStreamQualityUpdate:(NSString *)uid quality:(VideoQuality *)quality {
    if ([self.roomDelegate respondsToSelector:@selector(onPublishStreamQualityUpdate:quality:)]) {
        [self.roomDelegate onPublishStreamQualityUpdate:uid quality:quality];
    }
}
- (void)onRemoteQualityUpdate:(NSString *)uid quality:(VideoQuality *)quality {
    if ([self.roomDelegate respondsToSelector:@selector(onRemoteQualityUpdate:quality:)]) {
        [self.roomDelegate onRemoteQualityUpdate:uid quality:quality];
    }
}

- (void)onPlayStateUpdate:(int)code userId:(nonnull NSString *)userId {
    if ([self.roomDelegate respondsToSelector:@selector(onPlayStateUpdate:userId:)]) {
        [self.roomDelegate onPlayStateUpdate:code userId:userId];
    }
}
- (void)onPublishStateUpdate:(int)code {
    if ([self.roomDelegate respondsToSelector:@selector(onPublishStateUpdate:)]) {
        [self.roomDelegate onPublishStateUpdate:code];
    }
}

@end
