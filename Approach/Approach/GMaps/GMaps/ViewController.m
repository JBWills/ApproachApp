//
//  ViewController.m
//
//  Created by James Wills.
//  Copyright (c) 2013 University of Maryland. All rights reserved.
//
//  This class runs the map view. It places the paths and moves the "current position"
//  along the path with the song. It only has access to the global variables from the
//  GlobalManager class.

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController {
    GlobalManager *sharedGlobal;
}

@synthesize smallMap, pathTimer, overlay, playCircle, camera, pathAlreadyShown, allPaths;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // allow access to the global variables
    sharedGlobal = [GlobalManager sharedManager];
    
    // Create the timer that wil be used to move the marker along the path. 
    pathTimer = [NSTimer timerWithTimeInterval:TIMER_SPEED target:self selector:@selector(updateProgressBar:) userInfo:nil repeats:YES];
    
    [[NSRunLoop mainRunLoop] addTimer:pathTimer forMode:NSRunLoopCommonModes];
    
    allPaths = [[NSMutableArray alloc] initWithCapacity:sharedGlobal.numberOfPaths];
    
    
    for (AudioPath *i in sharedGlobal.pathArr) {
        GMSPolylineOptions *pathOptions = [GMSPolylineOptions options];
        
        pathOptions.path = i.mutablePath;
        pathOptions.color = [ViewController getRandomOrange];
        pathOptions.width = 6.f;
        [allPaths addObject:pathOptions];
    }
}

// Sets up the basic google map. 
- (void)loadView {
    
    sharedGlobal = [GlobalManager sharedManager];
    
    // creates a camera centered on Queen Anne's hall in UMD. The zoom level was set to 17
    // because that is the farthest zoom level that renders 3d buildings.
     
    camera = [GMSCameraPosition cameraWithLatitude:sharedGlobal.currentLocation.latitude
                                         longitude:sharedGlobal.currentLocation.longitude
                                              zoom:17];
    
    // create the map itself 
    smallMap = [GMSMapView mapWithFrame: CGRectZero camera: camera];
    smallMap.clipsToBounds = YES;
    smallMap.myLocationEnabled = YES;
    smallMap.settings.tiltGestures = sharedGlobal.allowTilt;
    smallMap.settings.zoomGestures = sharedGlobal.allowZoom;
    smallMap.settings.rotateGestures = sharedGlobal.allowRotate;
    smallMap.delegate = (id)self;
    
    self.view = smallMap;
    
    [self resetToStart];
}

// This method adds a path to the map using an encoded string from here:
// https://developers.google.com/maps/documentation/utilities/polylineutility
 
-(void)addPath: (AudioPath *) sentPath {
    
    // the options that will determine the specifics of the circle that moves along the path 
    GMSGroundOverlayOptions *overlayOptions = [GMSGroundOverlayOptions options];
    
    [smallMap addPolylineWithOptions:sentPath.pathOptions];
    
    
    // add white circle to mark the beginning of the path 
    overlayOptions.icon = [UIImage imageNamed:@"begin.png"];
    overlayOptions.position = sentPath.startPoint.coordinate;
    overlayOptions.bearing = 0.f;
    overlayOptions.zoomLevel = 17;
    
    // The overlay will now use overlayOptions' attributes 
    overlay = [smallMap addGroundOverlayWithOptions:overlayOptions];
}

-(void) mapView:(GMSMapView *)mapView
didTapInfoWindowOfMarker:(id<GMSMarker>)marker {
    
    // figure out which path was selected and set that paths as "currentPath" 
    NSString *temp;
    for (AudioPath *path in sharedGlobal.pathArr) {
        temp = [[marker.title stringByReplacingOccurrencesOfString:@"Click here to play " withString:@""] stringByReplacingOccurrencesOfString:@"'" withString:@""];
        
        if ([temp isEqualToString:[path.pathTitle stringByReplacingOccurrencesOfString:@"'" withString:@""]]) {
            sharedGlobal.currentPath = path;
            break;
        }
    }
    
    
    // if the user is more than 30 meters away from the start position they cannot listen to the path
    // unless they are really far away, then they can listen.
     
    if (([smallMap.myLocation distanceFromLocation:sharedGlobal.currentPath.startPoint] > 30 &&
         [smallMap.myLocation distanceFromLocation:sharedGlobal.currentPath.startPoint] < 2000)) {
        if (sharedGlobal.onlyCloseUsersCanListen) {
            [[[UIAlertView alloc] initWithTitle:@"You are too far from the starting point!"
                                        message:@"Please move closer to the start of the path so you can walk with it."
                                       delegate:nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil] show];
        }
        else {
            [[[UIAlertView alloc] initWithTitle:@"You are too far from the starting point!"
                                        message:@"Please move closer to the start of the path so you can walk with it. If you really want you can listen to the path anyways."
                                       delegate:self
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:@"Listen", nil] show];
        }
    }
    else
        [self startPath];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex)
        [self startPath];
}

-(void) startPath {
    if (sharedGlobal.showPathsPressed == PATHS_SHOULD_BE_SHOWN)
        sharedGlobal.showPathsPressed = SHOW_PATHS;
    sharedGlobal.userSelectedAPath = YES;
    sharedGlobal.shouldShowPlayer = YES;
    [smallMap clear];
    
    // [self createMarkerForPath:sharedGlobal.currentPath];
    
    if (!pathAlreadyShown) {
        pathAlreadyShown = YES;
        // adds the path to the map by decoding google's encoded string 
        [self addPath: sharedGlobal.currentPath];
    }
}

-(void)hidePaths {
    [smallMap clear];
    [self resetToStart];
}

// When the user drags the map update the current position, also check to see if the
// user is out of bounds.
- (void)mapView:(GMSMapView *)mapView
didChangeCameraPosition:(GMSCameraPosition *)position {
    CLLocation *a = [[CLLocation alloc] initWithLatitude:smallMap.camera.target.latitude longitude:smallMap.camera.target.longitude];
    if((sharedGlobal.isShowingPlayer && [a distanceFromLocation:sharedGlobal.currentPath.startPoint] > 400)
       || (smallMap.camera.zoom < 16 || smallMap.camera.zoom > 19)) {
        sharedGlobal.isOutOfBounds = YES; 
    }
    else if (!sharedGlobal.isShowingPlayer && [a distanceFromLocation:[[CLLocation alloc] initWithLatitude:38.984265536371886 longitude:-76.94458365440369]] > 500)
        sharedGlobal.isOutOfBounds = YES;
    else
        sharedGlobal.isOutOfBounds = NO;
    
    sharedGlobal.currentLocation = smallMap.camera.target;
    
    sharedGlobal.userWantsToCenterSelf = NO;
}

// This function moves an overlay (the circle) along the path to signify roughly
// where the user should be along the path.
- (void)updateProgressBar:(NSTimer *)timer {
    
    // If: the overlay should be moving (the user is scrubbing along the timeline
    // or the audio file is playing), move the cursor along.
    //
    // Else: stop the timer
     
    if (sharedGlobal.audioPlayer2.isPlaying || sharedGlobal.isBeingScrubbed) {
        float percentLoc = sharedGlobal.audioPlayer2.currentTime/sharedGlobal.audioPlayer2.duration * 100;
        overlay.position = [sharedGlobal.currentPath getPositionOnPolyline: percentLoc].coordinate;
    }
    
    if (sharedGlobal.userWantsToReturn) {
        [smallMap setCamera:
         [GMSCameraPosition cameraWithLatitude:overlay.position.latitude
                                     longitude:overlay.position.longitude
                                          zoom:17]];
        sharedGlobal.userWantsToReturn = NO;
        sharedGlobal.userWantsToCenterSelf = NO;
    }
    
    if (sharedGlobal.shouldShowPlayer != sharedGlobal.isShowingPlayer) {
        if(!sharedGlobal.shouldShowPlayer) {
            sharedGlobal.isShowingPlayer = NO;
            [smallMap clear];
            pathAlreadyShown = NO;
            [self resetToStart];
        }
        else {
            sharedGlobal.isShowingPlayer = YES;
        }
    }
    
    if (sharedGlobal.userWantsToCenterSelf) {
        sharedGlobal.userWantsToCenterSelf = NO;
        [smallMap setCamera:
         [GMSCameraPosition cameraWithLatitude:[smallMap myLocation].coordinate.latitude
                                     longitude:[smallMap myLocation].coordinate.longitude
                                          zoom:17]];

    }
    
    if(sharedGlobal.showPathsPressed == SHOW_PATHS && !sharedGlobal.shouldShowPlayer) {
        sharedGlobal.showPathsPressed = PATHS_SHOULD_BE_SHOWN;
        
        // place all of the paths on the map 
        for (GMSPolylineOptions *i in allPaths) {
            i.color =  [ViewController getRandomOrange];
            [smallMap addPolylineWithOptions:i];
        }
    }
    else if (sharedGlobal.showPathsPressed == DONT_SHOW_PATHS) {
        sharedGlobal.showPathsPressed = NEITHER;
        [self hidePaths];
    }
}

// This method places markers and text labels for all of the paths on the map. 
-(void)resetToStart {
    for (AudioPath *path in sharedGlobal.pathArr)
        [self createLabeledMarkerForPath:path];
}

// This is a helper method that is used to create a marker and a text label 
-(void)createMarkerForPath: (AudioPath *) path {
    GMSMarkerOptions *options = [[GMSMarkerOptions alloc] init];
    options.position = path.startPoint.coordinate;
    options.title = [NSString stringWithFormat:@"%@ '%@'",@"Click here to play", path.pathTitle];;
    options.snippet = path.pathDescription;
    options.icon = [UIImage imageNamed:@"markerimage"];
    
    options.groundAnchor = CGPointMake(.5, .5);
    
    [smallMap addMarkerWithOptions:options];
}

// This is a helper method that is used to create a marker and a text label 
-(void)createLabeledMarkerForPath: (AudioPath *) path {
    
    [self createMarkerForPath:path];
    
    // these Next two blocks of code are from Daji-Djan on stack overflow 
    // setup label
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 50, 20)];
    label.text = path.pathTitle;
    [label sizeToFit];
    label.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.4];
    
    // grab it
    UIGraphicsBeginImageContextWithOptions(label.bounds.size, NO, [[UIScreen mainScreen] scale]);
    [label.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage * textLabel = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    
    GMSGroundOverlayOptions *overlayOptions = [GMSGroundOverlayOptions options];
    
    // this places the label slightly below the start position so it is unobscured by the marker image 
    overlayOptions.position = CLLocationCoordinate2DMake(path.startPoint.coordinate.latitude - .00025, path.startPoint.coordinate.longitude);
    overlayOptions.icon = textLabel;
    overlayOptions.zoomLevel = 17;
    overlay = [smallMap addGroundOverlayWithOptions:overlayOptions];
}

// This method is called every time the view is shown on the screen. All it does right now
// is change the current location to be the same as on the last screen.
-(void)viewDidAppear:(BOOL)animated {
    camera = [GMSCameraPosition cameraWithLatitude:sharedGlobal.currentLocation.latitude
                                         longitude:sharedGlobal.currentLocation.longitude
                                              zoom:17];
    [smallMap setCamera:camera];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

+ (UIColor *)getRandomOrange {
    float rand = arc4random() % 90;
    return [UIColor colorWithRed:255/255.0 green:abs(110.0-rand)/ 255.0 blue:abs(40 - rand)/255.0 alpha:.5f];
}

@end