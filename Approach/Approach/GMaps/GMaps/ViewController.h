//
//  ViewController.h
//
//  Created by James Wills.
//  Copyright (c) 2013 University of Maryland. All rights reserved.
//
//  This class runs the map view. It places the paths and moves the "current position"
//  along the path with the song. It only has access to the global variables from the
//  GlobalManager class.

#import <UIKit/UIKit.h>
#import <GoogleMaps/GoogleMaps.h>
#import "ContainerViewController.h"
#import "GlobalManager.h"
#import "AudioPath.h"
#import <QuartzCore/QuartzCore.h>

@interface ViewController : UIViewController
@property (nonatomic) IBOutlet GMSMapView *smallMap;

@property id<GMSGroundOverlay> overlay;
@property GMSGroundOverlayOptions *playCircle;
@property GMSCameraPosition *camera;

@property NSTimer *pathTimer;

@property BOOL pathAlreadyShown;

@property NSMutableArray *allPaths;

@end