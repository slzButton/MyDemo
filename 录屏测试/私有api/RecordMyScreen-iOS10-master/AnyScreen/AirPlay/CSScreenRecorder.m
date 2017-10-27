//
//  CSScreenRecorder.m
//  RecordMyScreen
//
//  Created by Aditya KD on 02/04/13.
//  Copyright (c) 2013 CoolStar Organization. All rights reserved.
//

#import "CSScreenRecorder.h"

#import <CoreVideo/CVPixelBuffer.h>
#import <QuartzCore/QuartzCore.h>

#include <sys/time.h>

#include "Utilities.h"
#include "mediaserver.h"
#include "mp4v2/mp4v2.h"
#include <pthread.h>
#import "IDFileManager.h"

static AVAudioRecorder    *_audioRecorder=nil ;

@interface CSScreenRecorder ()
//{
//@private
    
    
 

//}

- (void)_setupAudio;
- (void)_finishEncoding;


@end

@implementation CSScreenRecorder

static CSScreenRecorder * _sharedCSScreenRecorder;

+ (CSScreenRecorder *) sharedCSScreenRecorder
{
    
    if (_sharedCSScreenRecorder != nil) {
        return _sharedCSScreenRecorder;
    }
    _sharedCSScreenRecorder = [[CSScreenRecorder alloc] init];
    
   
    return _sharedCSScreenRecorder;
}

- (void)setDelegate:(id<CSScreenRecorderDelegate>)delegate{
    @synchronized(self)
    {
        _delegate = delegate;
    }
}


- (instancetype)init
{
    if ((self = [super init])) {
        
    }
    return self;
}

- (void)dealloc
{
    
    
    _audioRecorder = nil;
    
    
}


static NSString *_videoName = nil;

NSString *fileName;
NSString *exportFileName;
NSString* audioOutPath;

MP4FileHandle hMp4file = MP4_INVALID_FILE_HANDLE;
MP4TrackId    m_videoId = MP4_INVALID_TRACK_ID;
MP4TrackId    m_audioId = MP4_INVALID_TRACK_ID;
static int    mp4_init_flag = 0;
pthread_mutex_t write_mutex;

#define SAVE_264_ENABLE 0


#if SAVE_264_ENABLE
FILE  *m_handle = NULL;
#endif


void video_open(void *cls,int width,int height,const void *buffer, int buflen, int payloadtype, double timestamp)
{
    
    
    unsigned    char *data;
    
    int spscnt;
    int spsnalsize;
    unsigned char *sps;
    int ppscnt;
    int ppsnalsize;
    unsigned char *pps;
    
    //rLen = 0;
    data = (unsigned char *)buffer ;
    
    spscnt = data[5] & 0x1f;
    spsnalsize = ((uint32_t)data[6] << 8) | ((uint32_t)data[7]);
    ppscnt = data[8 + spsnalsize];
    ppsnalsize = ((uint32_t)data[9 + spsnalsize] << 8) | ((uint32_t)data[10 + spsnalsize]);
    
    sps = (unsigned char *)malloc(spsnalsize );
    pps = (unsigned char *)malloc(ppsnalsize);
    
    
    memcpy(sps, data + 8, spsnalsize);
    
    
    
    memcpy(pps, data + 11 + spsnalsize, ppsnalsize);
    
    
    
    
    
    
    
    //int i;
    
 //   _videoName = [NSString stringWithFormat:@"XinDawnRec-%04d.mp4",rand()];
    _videoName = [CSScreenRecorder sharedCSScreenRecorder].videoOutPath;
    
    fileName = [NSString stringWithFormat:@"%@tmp-1.mp4", NSTemporaryDirectory()];
    
    
    hMp4file = MP4Create([fileName cStringUsingEncoding: NSUTF8StringEncoding],0);
    
    
    
    MP4SetTimeScale(hMp4file, 90000);
    
    
    
    m_videoId = MP4AddH264VideoTrack
    (hMp4file,
     90000,
     90000 / 60,
     width, // width
     height,// height
     sps[1], // sps[1] AVCProfileIndication
     sps[2], // sps[2] profile_compat
     sps[3], // sps[3] AVCLevelIndication
     3);           // 4 bytes length before each NAL unit
    if (m_videoId == MP4_INVALID_TRACK_ID)
    {
        printf("add video track failed.\n");
        //return false;
    }
    MP4SetVideoProfileLevel(hMp4file, 0x7f); //  Simple Profile @ Level 3
    
    // write sps
    MP4AddH264SequenceParameterSet(hMp4file, m_videoId, sps, spsnalsize);
    
    
    
    // write pps
    MP4AddH264PictureParameterSet(hMp4file, m_videoId, pps, ppsnalsize);
    
    
    
    free(sps);
    free(pps);
    
    
    
    unsigned char eld_conf[2] = { 0x12, 0x10 };
    
    m_audioId = MP4AddAudioTrack(hMp4file, 44100, 1024, MP4_MPEG4_AUDIO_TYPE);  //sampleDuration.
    if (m_audioId == MP4_INVALID_TRACK_ID)
    {
        printf("add video track failed.\n");
        //return false;
    }
    
    
    MP4SetAudioProfileLevel(hMp4file, 0x0F);
    MP4SetTrackESConfiguration(hMp4file, m_audioId, &eld_conf[0], 2);
    
    
    
#if SAVE_264_ENABLE
    {
        NSString *fileName264 = [Utilities documentsPath:[NSString stringWithFormat:@"XinDawnRec-%04d.264",rand()]];
        
        m_handle = fopen([fileName264 cStringUsingEncoding: NSUTF8StringEncoding], "wb");
        
        
        
        int spscnt;
        int spsnalsize;
        int ppscnt;
        int ppsnalsize;
        
        unsigned    char *head = (unsigned  char *)buffer;
        
        
        
        
        spscnt = head[5] & 0x1f;
        spsnalsize = ((uint32_t)head[6] << 8) | ((uint32_t)head[7]);
        ppscnt = head[8 + spsnalsize];
        ppsnalsize = ((uint32_t)head[9 + spsnalsize] << 8) | ((uint32_t)head[10 + spsnalsize]);
        
        
        unsigned char *data = (unsigned char *)malloc(4 + spsnalsize + 4 + ppsnalsize);
        
        
        data[0] = 0;
        data[1] = 0;
        data[2] = 0;
        data[3] = 1;
        
        memcpy(data + 4, head + 8, spsnalsize);
        
        data[4 + spsnalsize] = 0;
        data[5 + spsnalsize] = 0;
        data[6 + spsnalsize] = 0;
        data[7 + spsnalsize] = 1;
        
        memcpy(data + 8 + spsnalsize, head + 11 + spsnalsize, ppsnalsize);
        
        
        fwrite(data,1,4 + spsnalsize + 4 + ppsnalsize,m_handle);
        
        
        free(data);
        
        
    }
    
#endif
    
    
    
    pthread_mutex_init(&write_mutex, NULL);
    
    mp4_init_flag = 1;
    
//kdd
    [[CSScreenRecorder sharedCSScreenRecorder].delegate screenRecorderDidStartRecording:[CSScreenRecorder sharedCSScreenRecorder]];
    
    
    

    [[AVAudioSession sharedInstance]  setCategory:AVAudioSessionCategoryPlayAndRecord withOptions:AVAudioSessionCategoryOptionMixWithOthers error:nil];
    [[AVAudioSession sharedInstance]  setMode:AVAudioSessionModeVoiceChat error:nil];
    [[AVAudioSession sharedInstance]  overrideOutputAudioPort:AVAudioSessionPortOverrideSpeaker error:nil];
    
    

    
    //[_audioRecorder setDelegate:self];
     [_audioRecorder prepareToRecord];
    
    // Start recording :P
      [_audioRecorder record];
    
}


void video_process(void *cls,const void *buffer, int buflen, int payloadtype, double timestamp)
{
    
    NSLog(@"%d",timestamp);
    
    while (!mp4_init_flag)
    {
        usleep(1000);
    }
    
    
    
    
    
    if (payloadtype == 0)
    {
        
        
        pthread_mutex_lock(&write_mutex);
        if(hMp4file)
        {
            MP4WriteSample(hMp4file, m_videoId, buffer, buflen, MP4_INVALID_DURATION, 0, 0);
        }
        pthread_mutex_unlock(&write_mutex);
        
        
#if SAVE_264_ENABLE
        {
            
            
            int		    rLen;
            unsigned    char *head;
            
            
            
            unsigned char *data = (unsigned char *)malloc(buflen);
            memcpy(data, buffer, buflen);
            
            
            
            rLen = 0;
            head = (unsigned char *)data + rLen;
            while (rLen < buflen)
            {
                rLen += 4;
                rLen += (((uint32_t)head[0] << 24) | ((uint32_t)head[1] << 16) | ((uint32_t)head[2] << 8) | (uint32_t)head[3]);
                
                head[0] = 0;
                head[1] = 0;
                head[2] = 0;
                head[3] = 1;
                
                head = (unsigned char *)data + rLen;
            }
            
            
            
            fwrite(data,1,buflen,m_handle);
            
            free(data);
            
            
        }
#endif
        //kdd
    [[CSScreenRecorder sharedCSScreenRecorder].delegate screenRecorder:[CSScreenRecorder sharedCSScreenRecorder] recordingTimeChanged:timestamp];
        
    }
    // printf("=====video====%f====\n",timestamp);

    
}

void video_stop(void *cls)
{
    pthread_mutex_lock(&write_mutex);
    if (hMp4file)
    {
        MP4Close(hMp4file,0);
        hMp4file = NULL;
    }
    pthread_mutex_unlock(&write_mutex);
    
    pthread_mutex_destroy(&write_mutex);
    mp4_init_flag = 0;
    
    
#if SAVE_264_ENABLE
    fclose(m_handle);
#endif
    
    printf("=====video_stop========\n");
    
    //kdd
    [[CSScreenRecorder sharedCSScreenRecorder].delegate screenRecorderDidStopRecording:[CSScreenRecorder sharedCSScreenRecorder]];
    
}

void audio_open(void *cls, int bits, int channels, int samplerate, int isaudio)
{
    
    
}


void audio_setvolume(void *cls,int volume)
{
    printf("=====audio====%d====\n",volume);
}


void audio_process(void *cls,const void *buffer, int buflen, double timestamp, uint32_t seqnum)
{
    while (!mp4_init_flag)
    {
        usleep(1000);
    }
    
    pthread_mutex_lock(&write_mutex);
    if (hMp4file)
    {
        MP4WriteSample(hMp4file, m_audioId, buffer, buflen, MP4_INVALID_DURATION, 0, 1);
    }
    pthread_mutex_unlock(&write_mutex);
    //printf("=====audio====%f====\n",timestamp);
}


void audio_stop(void *cls)
{
    
    printf("=====audio_stop========\n");
}






- (void)startRecordingScreen
{
    
    [self _setupAudio];
    
    
    
    airplay_callbacks_t ao;
    memset(&ao,0,sizeof(airplay_callbacks_t));
    ao.cls                          = (__bridge void *)self;
    
    
    
    ao.AirPlayMirroring_Play     = video_open;
    ao.AirPlayMirroring_Process  = video_process;
    ao.AirPlayMirroring_Stop     = video_stop;
    
    ao.AirPlayAudio_Init         = audio_open;
    ao.AirPlayAudio_SetVolume    = audio_setvolume;
    ao.AirPlayAudio_Process      = audio_process;
    ao.AirPlayAudio_destroy      = audio_stop;
    
    
    
    
    int ret = XinDawn_StartMediaServer("XBMC-GAMEBOX(XinDawn)",1920, 1080, 60, 47000,7100,"000000000", &ao);
    
    
    printf("=====ret=%d========\n",ret);
    
    
}

- (void)stopRecordingScreen
{
    
    [self _finishEncoding];
    
    
    XinDawn_StopMediaServer();
    
    
    [self mergeAudio];
   
    

}






- (void)_setupAudio
{
    // Setup to be able to record global sounds (preexisting app sounds)
   
    NSError *sessionError = nil;

    
    [[AVAudioSession sharedInstance] setActive:YES error:&sessionError];
    
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord withOptions:AVAudioSessionCategoryOptionMixWithOthers error:&sessionError];
    
    
    [[AVAudioSession sharedInstance] setMode:AVAudioSessionModeDefault error:nil];
    
    
     [[AVAudioSession sharedInstance] overrideOutputAudioPort:AVAudioSessionPortOverrideSpeaker error:nil];
    
    
    self.audioSampleRate  = @44100;
    self.numberOfAudioChannels = @2;
    
    // Set the number of audio channels, using defaults if necessary.
    NSNumber *audioChannels = (self.numberOfAudioChannels ? self.numberOfAudioChannels : @2);
    NSNumber *sampleRate    = (self.audioSampleRate       ? self.audioSampleRate       : @44100.f);
    
    NSDictionary *audioSettings = @{
                                    AVNumberOfChannelsKey : (audioChannels ? audioChannels : @2),
                                    AVSampleRateKey       : (sampleRate    ? sampleRate    : @44100.0f)
                                    };
    
    
    // Initialize the audio recorder
    // Set output path of the audio file
    NSError *error = nil;

    audioOutPath = [NSString stringWithFormat:@"%@audio.caf",  NSTemporaryDirectory()];
     _audioRecorder = [[AVAudioRecorder alloc] initWithURL:[NSURL fileURLWithPath:audioOutPath] settings:audioSettings error:&error];
    if (error && [self.delegate respondsToSelector:@selector(screenRecorder:audioRecorderSetupFailedWithError:)]) {
        // Let the delegate know that shit has happened.
        [self.delegate screenRecorder:self audioRecorderSetupFailedWithError:error];
        
            //kdd      [_audioRecorder release];
        _audioRecorder = nil;
        
        return;
    }
    
   // [_audioRecorder setDelegate:self];
   // [_audioRecorder prepareToRecord];
    
    // Start recording :P
  //  [_audioRecorder record];
}




- (void)mergeAudio {
    NSString *videoPath = fileName;
    NSString *audioPath = audioOutPath;
    
    NSURL *videoURL = [NSURL fileURLWithPath:videoPath];
    NSURL *audioURL = [NSURL fileURLWithPath:audioPath];
    
    NSError *error = nil;
    NSDictionary *options = nil;
    
    AVURLAsset *videoAsset = [AVURLAsset URLAssetWithURL:videoURL options:options];
    AVURLAsset *audioAsset = [AVURLAsset URLAssetWithURL:audioURL options:options];
    
    AVAssetTrack *assetVideoTrack = nil;
    AVAssetTrack *assetAudioTrack = nil;
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:videoPath]) {
        NSArray *assetArray = [videoAsset tracksWithMediaType:AVMediaTypeVideo];
        if ([assetArray count] > 0) {
            assetVideoTrack = assetArray[0];
        }
    }
    
   if ([[NSFileManager defaultManager] fileExistsAtPath:audioPath])
    {
        NSArray *assetArray = [audioAsset tracksWithMediaType:AVMediaTypeAudio];
        if ([assetArray count] > 0) {
            assetAudioTrack = assetArray[0];
        }
    }
    
    AVMutableComposition *mixComposition = [AVMutableComposition composition];
    
    if (assetVideoTrack != nil) {
        AVMutableCompositionTrack *compositionVideoTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
        [compositionVideoTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, videoAsset.duration) ofTrack:assetVideoTrack atTime:kCMTimeZero error:&error];
        if (assetAudioTrack != nil) {
            [compositionVideoTrack scaleTimeRange:CMTimeRangeMake(kCMTimeZero, videoAsset.duration) toDuration:audioAsset.duration];
        }
    }
    
    if (assetAudioTrack != nil) {
        AVMutableCompositionTrack *compositionAudioTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
        [compositionAudioTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, audioAsset.duration) ofTrack:assetAudioTrack atTime:kCMTimeZero error:&error];
    }
    
  
    
    exportFileName = [NSString stringWithFormat:@"%@.mp4", _videoName];
    NSURL *exportURL = [NSURL fileURLWithPath:exportFileName];
    
    AVAssetExportSession *exportSession = [[AVAssetExportSession alloc] initWithAsset:mixComposition presetName:AVAssetExportPresetHighestQuality];
    [exportSession setOutputFileType:AVFileTypeMPEG4];
    [exportSession setOutputURL:exportURL];
    [exportSession setShouldOptimizeForNetworkUse:NO];
    
    [exportSession exportAsynchronouslyWithCompletionHandler:^(void){
        switch (exportSession.status) {
            case AVAssetExportSessionStatusCompleted:
                
#if 1//kdd
                //kdd
                [[NSNotificationCenter defaultCenter] postNotificationName:kFileAddedNotification object:nil];
                [self removeTemporaryFiles];
#endif
                
                break;
                
            case AVAssetExportSessionStatusFailed:
                NSLog(@"Failed: %@", exportSession.error);
                break;
                
            case AVAssetExportSessionStatusCancelled:
                NSLog(@"Canceled: %@", exportSession.error);
                break;
                
            default:
                break;
        }
    }];
}


#pragma mark - Encoding


- (void)_finishEncoding
{
    
    // Stop the audio recording
    [_audioRecorder stop];
    _audioRecorder = nil;
    
    [self addAudioTrackToRecording];
    
    //NSError *sessionError = nil;
    //[[AVAudioSession sharedInstance] setActive:NO error:&sessionError];
    

  
}

- (void)addAudioTrackToRecording {
    
    
    [self.delegate screenRecorderDidStopRecording:self];
}



- (void)removeTemporaryFiles {
    NSFileManager *defaultManager = [NSFileManager defaultManager];
    NSString *oldVideoPath = fileName;
    NSString *oldaudioPath = audioOutPath;
    
    if ([defaultManager fileExistsAtPath:oldaudioPath]) {
        NSError *error = nil;
        [defaultManager removeItemAtPath:oldaudioPath error:&error];
    }
    if ([defaultManager fileExistsAtPath:oldVideoPath]) {
        NSError *error = nil;
        [defaultManager removeItemAtPath:oldVideoPath error:&error];
    }
}



@end
