//
//  NoAnimationSegue.m
//
//  Created by James Wills
//  Copyright (c) 2013 University of Maryland. All rights reserved.
//
//  Creates a segue without any animation

#import "NoAnimationSegue.h"

@implementation NoAnimationSegue

- (void)perform {
    [[self sourceViewController] presentModalViewController:[self destinationViewController] animated:NO];
}
@end