//
//  AboutController.m
//
//  Created by James Wills on 4/26/13.
//  Copyright (c) 2013 University of Maryland. All rights reserved.
//
//  Controls the text and layout for the about screen

#import "AboutController.h"

@interface AboutController ()

@end

@implementation AboutController
@synthesize textView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    textView.text = @"Approach allows users to listen to stories in the context of the space they relate to. This prototype is based solely around the University of Maryland, but it is meant to be expanded into a platform that can be used in any space.\n \nApproach Team:\n\nDr. Jason Farman\nDepartment of American Studies\nFaculty Advisor\n\nDaniel Greene\nDepartment of American Studies\nGraduate Student\n\nJarah Moesch\nDepartment of American Studies\nGraduate Student\n\nPaul Nezaum Saiedi\nDepartment of American Studies\nGraduate Student\n\nJessica Kenyatta Walker\nDepartment of American Studies\nGraduate Student\n\nJames Wills\nDepartment of Computer Engineering\nUndergraduate Student\n\nOutside Partner: WAMU\n\nWebsite: www.approachapp.org";
    
}

- (IBAction)back:(id)sender {
    [self dismissViewControllerAnimated:NO completion:Nil];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
