//
//  ViewController.m
//  LongRunningTaskRecordAudioExample
//
//  Most of the code for this example came from:  http://www.appcoda.com/ios-avfoundation-framework-tutorial
//
//  I modified the code to set the recording interval to 10 seconds.  If the app is recording and put in the
//  background within 10 seconds, then the delegate:
//
//     AVAudioRecorderDelegate -> audioRecorderDidFinishRecording:successfully:
//
//  is called in the background... the BackgroundTimeRemaining printed is Infinite.
//
//  Created by Bob Dugan on 11/5/15.
//  Copyright © 2015 Bob Dugan. All rights reserved.
//

#import "ViewController.h"

@interface ViewController () {
    AVAudioRecorder *recorder;
    AVAudioPlayer *player;
}

@end

@implementation ViewController
@synthesize stopButton, playButton, recordPauseButton;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Disable Stop/Play button when application launches
    [stopButton setEnabled:NO];
    [playButton setEnabled:NO];
    
    // Set the audio file to store recording and for playback
    NSArray *pathComponents = [NSArray arrayWithObjects:
                               [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject],
                               @"MyAudioMemo.m4a",
                               nil];
    NSURL *outputFileURL = [NSURL fileURLWithPathComponents:pathComponents];
    
    // Setup audio session
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    
    // Define the recorder settings
    NSMutableDictionary *recordSetting = [[NSMutableDictionary alloc] init];
    [recordSetting setValue:[NSNumber numberWithInt:kAudioFormatMPEG4AAC] forKey:AVFormatIDKey];
    [recordSetting setValue:[NSNumber numberWithFloat:44100.0] forKey:AVSampleRateKey];
    [recordSetting setValue:[NSNumber numberWithInt: 2] forKey:AVNumberOfChannelsKey];
    
    // Initialize and prepare the recorder
    recorder = [[AVAudioRecorder alloc] initWithURL:outputFileURL settings:recordSetting error:nil];
    recorder.delegate = self;
    recorder.meteringEnabled = YES;
    [recorder prepareToRecord];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (IBAction)recordPauseTapped:(id)sender {
    
    // Stop the audio player before recording
    if (player.playing) {
        [player stop];
    }
    
    // Start recording
    if (!recorder.recording)
    {
        AVAudioSession *session = [AVAudioSession sharedInstance];
        [session setActive:YES error:nil];
        
        [recorder recordForDuration:10];
        [recordPauseButton setTitle:@"Pause" forState:UIControlStateNormal];
        
    }
    // Pause recording
    else
    {
        [recorder pause];
        [recordPauseButton setTitle:@"Record" forState:UIControlStateNormal];
    }
    
    // Adjust buttons
    [stopButton setEnabled:YES];
    [playButton setEnabled:NO];
}

- (IBAction)stopTapped:(id)sender {
    
    // Stop recorder
    [recorder stop];
    
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setActive:NO error:nil];
}

- (IBAction)playTapped:(id)sender {
    
    // We can't play if the recorder is recording (this should never happen anyway)
    if (!recorder.recording){
        player = [[AVAudioPlayer alloc] initWithContentsOfURL:recorder.url error:nil];
        [player setDelegate:self];
        [player play];
    }
}

//
// AVAudioRecorderDelegate
//
- (void) audioRecorderDidFinishRecording:(AVAudioRecorder *)avrecorder successfully:(BOOL)flag{
    [recordPauseButton setTitle:@"Record" forState:UIControlStateNormal];
    [stopButton setEnabled:NO];
    [playButton setEnabled:YES];
    
    NSLog(@"%s", __PRETTY_FUNCTION__);
    [BackgroundTimeRemainingUtility NSLog];
}

//
// AVAudioPlayerDelegate
//
- (void) audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag{
     NSLog(@"%s", __PRETTY_FUNCTION__);
    [BackgroundTimeRemainingUtility NSLog];
}

@end
