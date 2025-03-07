//
//  PMMapViewController.m
//  Pingamate
//
//  Created by Ali Mahouk on 1/2/17.
//  Copyright © 2017 Ali Mahouk. All rights reserved.
//

#import "PMMapViewController.h"

#import "PMAppDelegate.h"
#import "PMChatViewController.h"

@implementation PMMapViewController

- (instancetype)init
{
        self = [super init];
        
        if ( self ) {
                self.tabBarItem.image         = [UIImage imageNamed:@"Map"];
                self.tabBarItem.selectedImage = [UIImage imageNamed:@"MapSelected"];
                self.title                    = @"Map";
                
                didAuthorizeLocation  = NO;
                didZoomToUserLocation = NO;
                
                locationManager                 = [CLLocationManager new];
                locationManager.delegate        = self;
                locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
                
                [[(PMAppDelegate *)UIApplication.sharedApplication.delegate director] addDelegate:self];
        }
        
        return self;
}

#pragma mark -

- (UIStatusBarStyle)preferredStatusBarStyle
{
        return UIStatusBarStyleDefault;
}

- (void)dealloc
{
        [[(PMAppDelegate *)UIApplication.sharedApplication.delegate director] removeDelegate:self];
}

- (void)didChangeControllerFocus:(BOOL)focused
{
        if ( !focused )
                didZoomToUserLocation = NO; // Reset this.
}

- (void)loadView
{
        [super loadView];
        
        self.view.backgroundColor = UIColor.whiteColor;
        
        map                       = [MKMapView new];
        map.delegate              = self;
        map.showsBuildings        = YES;
        map.showsCompass          = YES;
        map.showsPointsOfInterest = YES;
        map.showsScale            = YES;
        map.showsUserLocation     = YES;
        
        navigationBar = [UINavigationBar new];
        
        userPicker          = [[PMUserPicker alloc] initWithFrame:CGRectMake(0, 20, self.view.bounds.size.width, 89)];
        userPicker.delegate = self;
        userPicker.source   = [[(PMAppDelegate *)UIApplication.sharedApplication.delegate director] userContacts];
        
        navigationBar.frame = CGRectMake(0, 0, self.view.bounds.size.width, userPicker.frame.origin.y + userPicker.bounds.size.height + 5);
        map.frame           = CGRectMake(0, navigationBar.bounds.size.height, self.view.bounds.size.width, self.view.bounds.size.height - navigationBar.bounds.size.height);
        
        [self.view addSubview:map];
        [self.view addSubview:navigationBar];
        [self.view addSubview:userPicker];
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
        if ( status == kCLAuthorizationStatusAuthorizedWhenInUse ||
             status == kCLAuthorizationStatusNotDetermined ) {
                didAuthorizeLocation = YES;
        } else {
                didAuthorizeLocation = NO;
        }
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
        NSLog(@"%@", error);
}

- (void)mapView:(MKMapView *)mapView didFailToLocateUserWithError:(NSError *)error
{
        NSLog(@"%@", error);
}

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
        if ( !didZoomToUserLocation ) {
                MKCoordinateRegion region;
                MKCoordinateSpan span;
                
                span.latitudeDelta  = 0.01;
                span.longitudeDelta = 0.01;
                
                region.center = userLocation.coordinate;
                region.span   = span;
                
                [mapView setRegion:region animated:YES];
                [mapView regionThatFits:region];
                
                didZoomToUserLocation = YES;
        }
}

- (void)userPicker:(PMUserPicker *)picker didSelectUser:(PMUser *)user
{
        
}

- (void)userPicker:(PMUserPicker *)picker didLongPressUser:(PMUser *)user
{
        PMChatViewController *chatController;
        
        chatController                        = [[PMChatViewController alloc] initWithUser:user];
        chatController.modalPresentationStyle = UIModalPresentationOverCurrentContext;
        chatController.modalTransitionStyle   = UIModalTransitionStyleCrossDissolve;
        
        [UIApplication.sharedApplication.keyWindow.rootViewController presentViewController:chatController animated:YES completion:nil];
}

- (void)viewDidLoad
{
        [super viewDidLoad];
        [locationManager requestWhenInUseAuthorization];
        [userPicker reloadData];
}


@end
