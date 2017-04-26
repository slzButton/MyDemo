//
//  NISound.h
//  NewIdeasAPI_Base
//
//  Created by 　罗若文 on 16/5/31.
//  Copyright © 2016年 罗若文. All rights reserved.
//  参考:http://blog.sina.com.cn/s/blog_a843a8850101k0d5.html

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

///声音类定义代理
@protocol NISoundDelegate <NSObject>
@optional
///播放结束时执行的动作
- (void)playerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag;

///解码错误执行的动作
- (void)playerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError *)error;

///处理中断的代码
- (void)playerBeginInterruption:(AVAudioPlayer *)player;

///当程序被应用外部打断之后，重新回到应用程序的时候触发。在这里当回到此应用程序的时候，继续播放音乐。
- (void)playerEndInterruption:(AVAudioPlayer *)player;
@end


///声音类
@interface NISound : NSObject

@property AVAudioPlayer * player;
@property (weak, nonatomic) id<NISoundDelegate> delegate;

///初始化声音:声音文件名
- (instancetype)initWithSoundName:(NSString *)soundName;
///播放
-(void)play;
///停止
-(void)stop;

@end

/*
 1、音量
 
 player.volume =0.8;//0.0-1.0之间
 
 2、循环次数
 
 player.numberOfLoops =3;//默认只播放一次
 
 3、播放位置
 
 player.currentTime =15.0;//可以指定从任意位置开始播放
 
 4、声道数
 
 NSUInteger channels = player.numberOfChannels;//只读属性
 
 5、持续时间
 
 NSTimeInterval duration = player.duration;//获取持续时间
 
 6、仪表计数
 
 
 player.meteringEnabled =YES;//开启仪表计数功能
 [playerupdateMeters];//更新仪表计数
 */