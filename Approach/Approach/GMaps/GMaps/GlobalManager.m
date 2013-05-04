//
//  GlobalManager.m
//
//  Created by James Wills on 3/18/13.
//  Copyright (c) 2013 University of Maryland. All rights reserved.
//
//  This is a support class that allows for an easier sharing of data between classes

#import "GlobalManager.h"

@implementation GlobalManager
@synthesize isBeingScrubbed, audioPlayer2, numberOfPaths, apiKey, startLocation, allowRotate, allowZoom,allowTilt, currentLocation, isOutOfBounds, userWantsToReturn, shouldShowPlayer, isShowingPlayer, pathArr, userSelectedAPath, currentPath, onlyCloseUsersCanListen, userWantsToCenterSelf, showPathsPressed;

+(id)sharedManager {
    static GlobalManager *sharedGlobalManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedGlobalManager = [[self alloc] init];
    });
    return sharedGlobalManager;
}

-(id)init {
    if(self = [super init]) {
        FakeDataBase *database = [[FakeDataBase alloc] init];
                
        apiKey = database.apiKey;
        numberOfPaths = database.numberOfPaths;
        
        currentLocation =  CLLocationCoordinate2DMake(38.98549782690282, -76.94636067188021);
        
        
        // default settings for how the map will behave 
        allowZoom = YES;
        allowRotate = NO;
        allowTilt = NO;
        onlyCloseUsersCanListen = NO;
        
        // Some global variables that will be modified by multiple classes 
        userWantsToReturn = NO;
        isOutOfBounds = NO;
        shouldShowPlayer = NO;
        isShowingPlayer = NO;
        userSelectedAPath = NO;
        userWantsToCenterSelf = NO;
        showPathsPressed = NEITHER;
        
        pathArr = [[NSMutableArray alloc] initWithCapacity:numberOfPaths];
        for (int i = 0; i < numberOfPaths; i++) {
            [pathArr addObject: [[AudioPath alloc] initWithID:i
                                                         path:[database.encodedPaths objectAtIndex:i]
                                                    pathTitle:[database.pathTitles objectAtIndex:i]
                                                   audioTitle:[database.audioTitles objectAtIndex:i]
                                                  audioFormat:[database.audioFormats objectAtIndex:i]
                                                    pathColor:[database.pathColors objectAtIndex:i]
                                              pathDescription:[database.pathDescriptions objectAtIndex:i]]];
        }
    }
    return self;
}

@end
