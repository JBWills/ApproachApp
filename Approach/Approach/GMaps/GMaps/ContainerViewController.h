//
// ContainerViewController.h
//
// Created by James Wills on 3/16/13.
// Copyright (c) 2013 University of Maryland. All rights reserved.
//
// This class controls the interface around the map in the main view of the application
//
// Specifically it controls playback of the audio file, the top playbar and the volume slider,
// and the play/pause button.
//
// lots of audio playback code borrowed from Brandon Cannaday, url here:
// http://tech.pro/tutorial/973/create-a-basic-iphone-audio-player-with-av-foundation-framework
//
// code for updateProgressBar method from User1452248 of Stack overflow
// http://stackoverflow.com/questions/14692792/uislider-progressbar-is-not-updating-currenttime

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "GlobalManager.h"
#import <AVFoundation/AVAudioPlayer.h>
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import "AudioPath.h"
#import "AboutController.h"

@class AVAudioPlayer;

@interface ContainerViewController : UIViewController

@property NSTimer *slowTimer;
@property NSTimer *sliderTimer;

@property NSInteger counter;

@property (weak, nonatomic) IBOutlet UIButton *returnButton;
@property (weak, nonatomic) IBOutlet UIButton *playPauseButton;
@property (weak, nonatomic) IBOutlet UIButton *exitButton;
@property (weak, nonatomic) IBOutlet UIButton *showChaptersButton;
@property (weak, nonatomic) IBOutlet UIButton *volumeButton;

@property (weak, nonatomic) IBOutlet UIButton *showPathsButton;
@property (weak, nonatomic) IBOutlet UIButton *showDetailButton;
@property (weak, nonatomic) IBOutlet UIButton *showMeButton;

@property (weak, nonatomic) IBOutlet UILabel *currentTime;
@property (weak, nonatomic) IBOutlet UILabel *timeLeft;

@property (weak, nonatomic) IBOutlet UISlider *playSlider;
@property (weak, nonatomic) IBOutlet UISlider *volumeSlider;

@property (weak, nonatomic) IBOutlet UIImageView *topBlackBar;

@property (weak, nonatomic) IBOutlet UIImageView *bottomBlackBar;
@property (weak, nonatomic) IBOutlet UINavigationBar *menuBar;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *returnConstraint;

@property (weak, nonatomic) IBOutlet UIView *containerView;

// this is used when the mute button is pressed
@property float oldVolume;

@property GlobalManager *sharedGlobal;

@end
