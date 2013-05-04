//
//  AudioPath.m
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

#import "AudioPath.h"

@implementation AudioPath

@synthesize audioFormat, audioTitle, coordinateArray,encodedPath, startPoint, length, pathOptions, mutablePath, pathTitle, pathID, pathDescription;

-(id) initWithID: (NSInteger)ID
            path: (NSString *)path
       pathTitle: (NSString *)pTitle
      audioTitle: (NSString *)audioT
     audioFormat: (NSString *)audioF
       pathColor: (UIColor *)col
 pathDescription: (NSString *)description {
    
    if (self = [super init]) {
        pathID = ID;
        encodedPath = path;
        audioTitle = audioT;
        audioFormat = audioF;
        pathTitle = pTitle;
        
        pathDescription = description;
        
        coordinateArray = [self decodePolyLine:encodedPath];
        startPoint = [coordinateArray objectAtIndex:0];
        
        length = [self findLength:coordinateArray];
        
        pathOptions = [GMSPolylineOptions options];
        
        mutablePath = [GMSMutablePath path];
        
        for (CLLocation *i in coordinateArray) {
            [mutablePath addCoordinate:i.coordinate];
        }
        
        pathOptions.path = mutablePath;
        pathOptions.color = col;
        pathOptions.width = 6.f;
    }
    
    return self;
}

// This method decodes the polyline from the encoded string found using google's
// polyline encoder tool (link in the top comment). It returns an array of coordinate
// points that when connected in order, become a polyline.
-(NSMutableArray *)decodePolyLine:(NSString *)encodedStr {
    NSMutableString *encoded = [[NSMutableString alloc] initWithCapacity:[encodedStr length]];
    [encoded appendString:encodedStr];
    [encoded replaceOccurrencesOfString:@"\\\\" withString:@"\\"
                                options:NSLiteralSearch
                                  range:NSMakeRange(0, [encoded length])];
    NSInteger len = [encoded length];
    NSInteger index = 0;
    NSMutableArray *array = [[NSMutableArray alloc] init];
    NSInteger lat=0;
    NSInteger lng=0;
    while (index < len) {
        NSInteger b;
        NSInteger shift = 0;
        NSInteger result = 0;
        do {
            b = [encoded characterAtIndex:index++] - 63;
            result |= (b & 0x1f) << shift;
            shift += 5;
        } while (b >= 0x20);
        NSInteger dlat = ((result & 1) ? ~(result >> 1) : (result >> 1));
        lat += dlat;
        shift = 0;
        result = 0;
        do {
            b = [encoded characterAtIndex:index++] - 63;
            result |= (b & 0x1f) << shift;
            shift += 5;
        } while (b >= 0x20);
        NSInteger dlng = ((result & 1) ? ~(result >> 1) : (result >> 1));
        lng += dlng;
        NSNumber *latitude = [[NSNumber alloc] initWithFloat:lat * 1e-5];
        NSNumber *longitude = [[NSNumber alloc] initWithFloat:lng * 1e-5];
        CLLocation *loc = [[CLLocation alloc] initWithLatitude:[latitude floatValue] longitude:[longitude floatValue]];
        [array addObject:loc];
    }
    return array;
}

// This takes a line in the form of an array of coordinates and returns a number that
// cooresponds to the length of the path in meters.
-(NSInteger) findLength:(NSMutableArray *)array {
    CLLocation *prevLoc= [array objectAtIndex:0];
    NSInteger tempLength = 0;
    for (CLLocation *i in array) {
        tempLength += [i distanceFromLocation:prevLoc];
        prevLoc = i;
    }
    return tempLength;
}

// This method takes an NSMUtableArray of CLLocations (representing a polyline)
// and a number between 0 and 100 and finds the point that is that percent along the polyline.
-(CLLocation *) getPositionOnPolyline:(float) percent {
    
    // if an invalid percent is passed  
    if (percent <= 0 || percent > 100)
        return [self.coordinateArray objectAtIndex:0];
    
    // Because only a select number of values are sent to this method, it's unlikely that
    // exactly 100 will be sent, this will catch any number >99 and consider it = to 100
      
    if (percent >= 99)
        return [self.coordinateArray lastObject];
    
    // this finds the length in meters along the path that the user wants to stop  
    float whereToStop = percent * length / 100;
    
    float tempLength = 0;
    
    CLLocation *prevLoc= self.startPoint;
    CLLocation *nextLoc = [[CLLocation alloc] init];
    
    // This loop finds the segment along the polyline that the point is located in  
    for (CLLocation *i in self.coordinateArray) {
        tempLength += [i distanceFromLocation:prevLoc];
        if (tempLength > whereToStop) {
            nextLoc = i;
            whereToStop = whereToStop - tempLength + [i distanceFromLocation:prevLoc];
            break;
        }
        prevLoc = i;
    }
    
    float percentLen = whereToStop / [nextLoc distanceFromLocation:prevLoc];
    
    float nextLat = (nextLoc.coordinate.latitude - prevLoc.coordinate.latitude) * percentLen + prevLoc.coordinate.latitude;
    float nextLon = (nextLoc.coordinate.longitude - prevLoc.coordinate.longitude) * percentLen + prevLoc.coordinate.longitude;
    
    return [[CLLocation alloc] initWithLatitude:nextLat longitude:nextLon];
}


@end
