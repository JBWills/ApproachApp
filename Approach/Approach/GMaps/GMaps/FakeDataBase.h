//
//  FakeDataBase.h
//
//  Created by James Wills on 4/4/13.
//  Copyright (c) 2013 University of Maryland. All rights reserved.
//
//  This class just stores most of the optional/ changable information for the app.
//  Ideally this would all be replaced with some kind of system that asks a database
//  for the information

#import <Foundation/Foundation.h>

@interface FakeDataBase : NSObject

@property NSInteger numberOfPaths;

@property NSArray *encodedPaths;
@property NSArray *pathTitles;
@property NSArray *audioTitles;
@property NSArray *audioFormats;
@property NSArray *pathColors;
@property NSArray *pathDescriptions;

@property NSString *apiKey;

@end
