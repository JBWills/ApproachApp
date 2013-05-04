//
//  GlobalManager.h
//
//  Created by James Wills on 3/18/13.
//  Copyright (c) 2013 University of Maryland. All rights reserved.
//
//  This is a support class that allows for an easier sharing of data between classes

#import <Foundation/Foundation.h>
#import <AVFoundation/AVAudioPlayer.h>
#import <GoogleMaps/GoogleMaps.h>
#import "AudioPath.h"
#import "FakeDataBase.h"

// Declare some constants to make adding new paths/ editing certain values easier

#define TIMER_SPEED 0.025

#define DONT_SHOW_PATHS 0
#define SHOW_PATHS 1
#define NEITHER 2
#define PATHS_SHOULD_BE_SHOWN 3

// some code from Matt Galloway (documented in works cited)
@interface GlobalManager : NSObject {
    AVAudioPlayer *audioPlayer2;
    
    AudioPath *currentPath;
    
    BOOL isBeingScrubbed;
    BOOL shouldShowPlayer;
    BOOL isShowingPlayer;
    
    // These are the values that are likely to be changed, so they are all
    // consolodated to this class to make it easier to change them.
    
    NSInteger numberOfPaths;
    NSInteger showPathsPressed;
    
    NSMutableArray *pathArr;
    
    NSString *apiKey;
    
    CLLocationCoordinate2D startLocation;
    CLLocationCoordinate2D currentLocation;
    
    BOOL allowZoom;
    BOOL allowRotate;
    BOOL allowTilt;
    BOOL onlyCloseUsersCanListen;
    
    BOOL isOutOfBounds;
    BOOL userWantsToReturn;
    BOOL userWantsToCenterSelf;
}


@property (nonatomic, retain) AVAudioPlayer *audioPlayer2;

@property AudioPath *currentPath;

@property BOOL isBeingScrubbed;

@property NSInteger numberOfPaths;
@property (atomic) NSInteger showPathsPressed;

@property NSString *apiKey;

@property NSMutableArray *pathArr;

@property CLLocationCoordinate2D startLocation;
@property CLLocationCoordinate2D currentLocation;

@property BOOL allowZoom;
@property BOOL allowRotate;
@property BOOL allowTilt;
@property BOOL onlyCloseUsersCanListen;

@property (atomic) BOOL isOutOfBounds;
@property (atomic) BOOL userWantsToReturn;
@property (atomic) BOOL shouldShowPlayer;
@property (atomic) BOOL isShowingPlayer;
@property (atomic) BOOL userSelectedAPath;
@property (atomic) BOOL userWantsToCenterSelf;

+(id)sharedManager;

@end
