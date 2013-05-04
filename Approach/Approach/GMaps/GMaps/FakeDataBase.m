//
//  FakeDataBase.m
//
//  Created by James Wills on 4/4/13.
//  Copyright (c) 2013 University of Maryland. All rights reserved.
//
//  This class just stores most of the optional/ changable information for the app.
//  Ideally this would all be replaced with some kind of system that asks a database
//  for the information

#import "FakeDataBase.h"

@implementation FakeDataBase
@synthesize audioFormats,audioTitles,pathColors,pathTitles,numberOfPaths,encodedPaths, pathDescriptions, apiKey;

-(id)init {
    if(self = [super init]) {
        apiKey = @"Your-Key-Here";
        
        numberOfPaths = 4;
        
        encodedPaths = [NSArray arrayWithObjects:
                        @"in}lFtxqtM~A~ANfCHdIPxJqB{BmB~BB`CdGBtBCl@?HqCj@_Ap@uA",
                        @"s_}lFhqrtMIOKDGHBJFFF?BABG@E",
                        @"_i}lFlnstMAWRB?_BfBANBFJJFBLiCjF{@t@sAVcAIsAe@c@c@",
                        @"c{|lFhdstMn@c@FA|@AAgBs@ACKCEEAC?GEAAAGEECAKEOKIMQ?I?WGOAo@?k@BUSOAo@[E@e@UUMGEwA?K?@jAABK@A@AB?B?B@^@dA]??IiB}@kB}@??c@QE^gA@?eD?gCHAn@g@r@?", nil];
        
        audioTitles = [NSArray arrayWithObjects:@"audio1", @"audio2", @"audio3", @"audio4", nil];
        audioFormats = [NSArray arrayWithObjects:@"mp3", @"mp3", @"mp3", @"mp3", nil];
        pathTitles = [NSArray arrayWithObjects:@"Path 1", @"Path 2",@"Path 3", @"Path 4" ,nil];
        
        UIColor *pCol = [UIColor colorWithRed:255.0 /255.0 green:110.0 / 255.0 blue:40 /255.0 alpha:1.0f];
        pathColors = [NSArray arrayWithObjects: pCol, pCol,pCol,pCol,nil];
        pathDescriptions = [NSArray arrayWithObjects:@"path description 1",@"path description 2", @"path description 3", @"path description 4", nil];
    }
    return self;
}
@end
