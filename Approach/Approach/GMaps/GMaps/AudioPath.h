//
//  AudioPath.h
//
//  Created by James Wills on 3/26/13.
//  Copyright (c) 2013 University of Maryland. All rights reserved.
//
//  An AudioPath object is made up of an encoded path (string that is converted to
//  an array of coordinates), a title, an audio file, and a description.
//
//  Much of the decodePolyline function code is from Andrew of iCodeApps:
//  http://icodeapps.blogspot.com/2011/04/google-map-directions-api-objective-c.html
//  that unravels this algorithm
//  https://developers.google.com/maps/documentation/utilities/polylinealgorithm
//  and returns an array of CLLocations cooresponding to each of the vertexes

#import <Foundation/Foundation.h>
#import <AVFoundation/AVAudioPlayer.h>
#import <GoogleMaps/GoogleMaps.h>

@interface AudioPath : NSObject {
    NSString *audioTitle;
    NSString *audioFormat;
    NSString *encodedPath;
    NSString *pathTitle;
    NSString *pathDescription;
    
    NSInteger length;
    NSInteger pathID;
    
    CLLocation *startPoint;
    
    NSMutableArray *coordinateArray;
    
    // the options that will determine the attributes of the path that will be displayed
    GMSPolylineOptions *pathOptions;
    
    // the path itself that will be added to the map 
    GMSMutablePath *mutablePath;
}

@property (nonatomic) NSString *audioTitle;
@property (nonatomic) NSString *audioFormat;
@property (nonatomic) NSString *encodedPath;
@property (nonatomic) NSString *pathTitle;
@property (nonatomic) NSString *pathDescription;

@property (nonatomic) NSInteger length;
@property (nonatomic) NSInteger pathID;

@property (nonatomic) CLLocation *startPoint;

@property (nonatomic) NSMutableArray *coordinateArray;

@property (nonatomic) GMSPolylineOptions *pathOptions;
@property (nonatomic) GMSMutablePath *mutablePath;

-(id) initWithID: (NSInteger) ID
            path: (NSString *)path
       pathTitle: (NSString *)pTitle
      audioTitle: (NSString *)audioT
     audioFormat: (NSString *)audioF
       pathColor: (UIColor *)col
 pathDescription: (NSString *)description;

-(CLLocation *) getPositionOnPolyline:(float) percent;

@end
