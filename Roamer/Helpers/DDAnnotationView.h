//
//  DDAnnotationView.h
//  Roamer
//
//  Created by Rajesh Mehta on 9/19/14.
//
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface DDAnnotationView : MKAnnotationView {
@private
    BOOL _isMoving;
    CGPoint _startLocation;
    CGPoint _originalCenter;
}

@property (nonatomic, assign) MKMapView* mapView;


@end
