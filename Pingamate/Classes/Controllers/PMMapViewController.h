//
//  PMMapViewController.h
//  Pingamate
//
//  Created by Ali Mahouk on 1/2/17.
//  Copyright © 2017 Ali Mahouk. All rights reserved.
//

@import MapKit;

#import "PMViewController.h"

#import "PMDirector.h"
#import "PMUserPicker.h"

@interface PMMapViewController : PMViewController <CLLocationManagerDelegate, MKMapViewDelegate, PMDirectorDelegate, PMUserPickerDelegate>
{
        CLLocationManager *locationManager;
        MKMapView *map;
        PMUserPicker *userPicker;
        UINavigationBar *navigationBar;
        UISegmentedControl *mapTypePicker;
        BOOL didAuthorizeLocation;
        BOOL didZoomToUserLocation;
}

@end
