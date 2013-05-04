// ContainerViewController.m

// Created by James Wills on 3/16/13.
// Copyright (c) 2013 University of Maryland. All rights reserved.

#import "ContainerViewController.h"

#define BAR_HEIGHT 47
#define TOP_BAR_HEIGHT 44
#define STATUS_BAR_HEIGHT 20

#define LOWER_BUTTONS_LOW screenHeight - BAR_HEIGHT - 12 - 18
#define LOWER_BUTTONS_HIGH screenHeight - BAR_HEIGHT * 2 - 28

#define UPPER_BUTTONS_LOW TOP_BAR_HEIGHT + STATUS_BAR_HEIGHT * 2 + 12
#define UPPER_BUTTONS_HIGH TOP_BAR_HEIGHT + STATUS_BAR_HEIGHT - 8

#define isPhone568 ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone && [UIScreen mainScreen].bounds.size.height == 568)

@interface ContainerViewController ();
@end

@implementation ContainerViewController
@synthesize returnButton,slowTimer,playSlider,currentTime, timeLeft, sharedGlobal;

@synthesize playPauseButton, volumeButton, volumeSlider, topBlackBar, bottomBlackBar, menuBar, returnConstraint, showChaptersButton, showPathsButton, showDetailButton, showMeButton, containerView, oldVolume;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // this allows audio to play while the app is in the background (when the phone screen is locked)
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    
    NSError *setCategoryError = nil;
    BOOL success = [audioSession setCategory:AVAudioSessionCategoryPlayback error:&setCategoryError];
    
    NSError *activationError = nil;
    success = [audioSession setActive:YES error:&activationError];
    
    // this will extend the time the splsh image spends on screen (to cover up google maps' long loading time)
    UIImageView *imageView;
    if (isPhone568)
        imageView=[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"splash-screen-iPhone5.png"]];
    else
        imageView=[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"splash-screen.png"]];
    CGRect frame = self.view.frame;
    frame.origin.y = -STATUS_BAR_HEIGHT;
    frame.size.height = [[UIScreen mainScreen] bounds].size.height;;
    imageView.frame = frame;
    [self.view addSubview:imageView];
    [self.view bringSubviewToFront:imageView];
    
    // animate the splash image to fade out
    [UIView animateWithDuration:0.5
                          delay:1.0
                        options:UIViewAnimationOptionTransitionNone
                     animations:^{imageView.alpha=0.0f;}
                     completion:^(BOOL finished){[imageView removeFromSuperview];}];
    
    [menuBar setBackgroundImage:[UIImage imageNamed:@"BarBGLogo.png"] forBarMetrics:UIBarMetricsDefault];
    returnButton.hidden = YES;
    
    // allows access to the global variables
    sharedGlobal = [GlobalManager sharedManager];
    
    slowTimer = [NSTimer timerWithTimeInterval:TIMER_SPEED * 5 target:self selector:@selector(checkTwiceASecond:) userInfo:nil repeats:YES];
    
    [[NSRunLoop mainRunLoop] addTimer:slowTimer forMode:NSRunLoopCommonModes];
    
    [self changeVisiblityOfAudioPlayer:YES];
}

- (void)userSelectedAPath {
    
    menuBar.topItem.title = sharedGlobal.currentPath.pathTitle;
    
    // Get the file path to the song to play.
    NSString *filePath = [[NSBundle mainBundle] pathForResource:sharedGlobal.currentPath.audioTitle
                                                         ofType:sharedGlobal.currentPath.audioFormat];
    
    // Convert the file path to a URL. 
    NSURL *fileURL = [[NSURL alloc] initFileURLWithPath:filePath];
    
    // Initialize the AVAudioPlayer. 
    sharedGlobal.audioPlayer2 = [[AVAudioPlayer alloc]
                                 initWithContentsOfURL:fileURL error:nil];
    
    // Preloads the buffer and prepares the audio for playing. 
    [sharedGlobal.audioPlayer2 prepareToPlay];
    
    sharedGlobal.audioPlayer2.volume = .75;
    
    currentTime.text = @"0:00";
    playSlider.maximumValue = sharedGlobal.audioPlayer2.duration;
    playSlider.value = sharedGlobal.audioPlayer2.currentTime;
    timeLeft.text = [NSString stringWithFormat:@"%d:%02d",
                     (int)sharedGlobal.audioPlayer2.duration / 60,
                     (int)sharedGlobal.audioPlayer2.duration % 60, nil];
}

// This method is fired when the user hits the context sensitive play/pause button. 
- (IBAction)playPause:(id)sender {
    
    // If: the track was playing, the button will be treated as a "pause" button.
    // It will then pause the audio and stop the timer that "runs" the progressbar.
     
     
    // Else: the track was not playing, the button will be treated as a "play" button.
    // The audio will begin to play and the timer is restarted
     
    if ([sharedGlobal.audioPlayer2 isPlaying]) {
        [sharedGlobal.audioPlayer2 pause];
        [_sliderTimer invalidate];
        _sliderTimer = nil;
        [self.playPauseButton setBackgroundImage:[UIImage imageNamed:@"Play-icon.png"] forState:UIControlStateNormal];
    }
    else {
        [sharedGlobal.audioPlayer2 play];
        [self.playPauseButton setBackgroundImage:
         [UIImage imageNamed:@"Pause-icon.png"] forState:UIControlStateNormal];
        
        _sliderTimer = [NSTimer timerWithTimeInterval:TIMER_SPEED
                                               target:self
                                             selector:@selector(updateProgressBar:)
                                             userInfo:nil
                                              repeats:YES];
        
        [[NSRunLoop mainRunLoop] addTimer:_sliderTimer forMode:NSRunLoopCommonModes];
    }
}

// changes the volume of the sound based on the volume slider at the bottom. 
- (IBAction)volumeControls:(id)sender {
    sharedGlobal.audioPlayer2.volume = volumeSlider.value;
}

// This function continuously changes the progress bar as the interview plays. 
- (void)updateProgressBar:(NSTimer *)timer {
    // the counter is just used for debugging purposes. 
    _counter++;
    
    // if the song is not playing make sure that the icon is changes to "Play-icon"
    // and the timer is stopped.
     
    if (!sharedGlobal.audioPlayer2.isPlaying){
        [self.playPauseButton setBackgroundImage:
         [UIImage imageNamed:@"Play-icon.png"] forState:UIControlStateNormal];
        [timer invalidate];
    }
    
    // if the song is playing, continuously update the labels to the left of the playbar 
    if (sharedGlobal.audioPlayer2.currentTime != sharedGlobal.audioPlayer2.duration) {
        currentTime.text = [NSString stringWithFormat:@"%d:%02d",
                            (int)sharedGlobal.audioPlayer2.currentTime / 60,
                            (int)sharedGlobal.audioPlayer2.currentTime % 60, nil];
        
        // When playback reaches the end, pause the song and keep the slider at the end. 
        if (sharedGlobal.audioPlayer2.currentTime + TIMER_SPEED >= sharedGlobal.audioPlayer2.duration) {
            playSlider.value = playSlider.maximumValue;
            [sharedGlobal.audioPlayer2 pause];
            sharedGlobal.audioPlayer2.currentTime = sharedGlobal.audioPlayer2.duration;
            [self.playPauseButton setBackgroundImage:
             [UIImage imageNamed:@"Play-icon.png"] forState:UIControlStateNormal];
            [timer invalidate];
        }
        
        playSlider.value = sharedGlobal.audioPlayer2.currentTime;
    }
}

-(void)changeVisiblityOfAudioPlayer: (BOOL) showAudioPlayer {
    
    playPauseButton.hidden = !showAudioPlayer;
    currentTime.hidden = !showAudioPlayer;
    timeLeft.hidden = !showAudioPlayer;
    playSlider.hidden = !showAudioPlayer;
    volumeSlider.hidden = !showAudioPlayer;
    volumeButton.hidden = !showAudioPlayer;
    topBlackBar.hidden = !showAudioPlayer;
    bottomBlackBar.hidden = !showAudioPlayer;
    _exitButton.hidden = !showAudioPlayer;
    showPathsButton.hidden = showAudioPlayer;
}

// This method is fired when the user begins changing the current time by dragging
// along the slider at the top.
- (IBAction)playSliderChanged:(id)sender {
    sharedGlobal.isBeingScrubbed = YES;
    sharedGlobal.audioPlayer2.currentTime = playSlider.value;
    sharedGlobal.audioPlayer2.currentTime = sharedGlobal.audioPlayer2.currentTime;
    currentTime.text = [NSString stringWithFormat:@"%d:%02d",
                        (int)sharedGlobal.audioPlayer2.currentTime / 60,
                        (int)sharedGlobal.audioPlayer2.currentTime % 60, nil];
}

// Turns off the audio player and tells the ViewController to stop
// displaying the path.
- (IBAction)exitPressed:(id)sender {
    [self changeVisiblityOfAudioPlayer:NO];
    menuBar.topItem.title = @"Choose a path";
    [sharedGlobal.audioPlayer2 stop];
    sharedGlobal.audioPlayer2.currentTime = 0;
    sharedGlobal.shouldShowPlayer = NO;
}

// Tells ViewController that the user wants to center the camera on the path
- (IBAction)returnPressed:(id)sender {
    sharedGlobal.userWantsToReturn = YES;
    returnButton.hidden = YES;
}

// Tells ViewController that the user wants to 
- (IBAction)showUserPressed:(id)sender {
    sharedGlobal.userWantsToCenterSelf = YES;
}

- (IBAction)showPathsPressed:(id)sender {
    if (showPathsButton.selected) {
        showPathsButton.selected = NO;
        [showPathsButton setBackgroundImage: [UIImage imageNamed:@"pathsBW"] forState: UIControlStateNormal];
        sharedGlobal.showPathsPressed = DONT_SHOW_PATHS;
    }
    else {
        showPathsButton.selected = YES;
        [showPathsButton setBackgroundImage: [UIImage imageNamed:@"paths"] forState: UIControlStateNormal];
        sharedGlobal.showPathsPressed = SHOW_PATHS;
    }
}

- (IBAction)infoPressed:(id)sender {
    [self performSegueWithIdentifier:@"About" sender:self];
}

- (IBAction)volumeButtonPressed:(id)sender {
    if (volumeSlider.value) {
        oldVolume = volumeSlider.value;
        volumeSlider.value = 0;
    }
    else {
        volumeSlider.value = oldVolume;
        oldVolume = 0;
    }
    sharedGlobal.audioPlayer2.volume = volumeSlider.value;
}

- (IBAction)showChaptersPressed:(id)sender {
    
}


// This method is fired when the user stops touching the slider. Updates the global
// variable so that the ViewController (map) class can know if the slider is being
// scrubbed or not
 
- (IBAction)scrubbingEnded:(id)sender {
    sharedGlobal.isBeingScrubbed = NO;
}

- (void)checkTwiceASecond:(NSTimer *)timer {
    if (sharedGlobal.isOutOfBounds)
        returnButton.hidden = NO;
    else
        returnButton.hidden = YES;
    
    if (sharedGlobal.userSelectedAPath) {
        sharedGlobal.userSelectedAPath = NO;
        [self userSelectedAPath];
    }
    
    // if the audio player should be shown but is not shown 
    if (sharedGlobal.shouldShowPlayer == _exitButton.hidden) {
        [self changeVisiblityOfAudioPlayer:sharedGlobal.shouldShowPlayer];
    }
    
    CGRect frame;
    NSInteger screenHeight =[[UIScreen mainScreen] bounds].size.height;
    if (_exitButton.hidden && showPathsButton.frame.origin.y != LOWER_BUTTONS_LOW) {
        frame = showMeButton.frame;
        frame.origin.y = LOWER_BUTTONS_LOW;
        showMeButton.frame = frame;
        
        frame = showDetailButton.frame;
        frame.origin.y = LOWER_BUTTONS_LOW;
        showDetailButton.frame = frame;
        
        frame = showPathsButton.frame;
        frame.origin.y = LOWER_BUTTONS_LOW;
        showPathsButton.frame = frame;
        
        frame = showChaptersButton.frame;
        frame.origin.y = LOWER_BUTTONS_LOW;
        showChaptersButton.frame = frame;
        
        frame = returnButton.frame;
        frame.origin.y = UPPER_BUTTONS_HIGH;
        returnButton.frame = frame;
    }
    else if (!_exitButton.hidden && showPathsButton.frame.origin.y != LOWER_BUTTONS_HIGH) {
        frame = showMeButton.frame;
        frame.origin.y = LOWER_BUTTONS_HIGH;
        showMeButton.frame = frame;
        
        frame = showDetailButton.frame;
        frame.origin.y = LOWER_BUTTONS_HIGH;
        showDetailButton.frame = frame;
        
        frame = showPathsButton.frame;
        frame.origin.y = LOWER_BUTTONS_HIGH;
        showPathsButton.frame = frame;
        
        frame = showChaptersButton.frame;
        frame.origin.y = LOWER_BUTTONS_HIGH;
        showChaptersButton.frame = frame;
        
        frame = returnButton.frame;
        frame.origin.y = UPPER_BUTTONS_LOW;
        returnButton.frame = frame;
    }
}

-(void)viewDidAppear:(BOOL)animated {
    [self changeVisiblityOfAudioPlayer:!sharedGlobal.shouldShowPlayer];
    [self checkTwiceASecond:Nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[UIApplication sharedApplication] endReceivingRemoteControlEvents];
    [self resignFirstResponder];
}

//Make sure we can recieve remote control events
- (BOOL)canBecomeFirstResponder {
    return YES;
}

@end
