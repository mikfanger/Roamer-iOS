//
//  DDAnnotationView.m
//  Roamer
//
//  Created by Rajesh Mehta on 9/19/14.
//
//

#import "DDAnnotationView.h"
#import "DDAnnotation.h"
#import "LocationController.h"

@implementation DDAnnotationView
@synthesize mapView = _mapView;

- (id)initWithAnnotation:(id <MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier {
    
    if (self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier]) {
        self.enabled = YES;
        self.canShowCallout = YES;
        self.multipleTouchEnabled = NO;
        // self.animatesDrop = YES;
        self.image = [UIImage imageNamed:@"Pins.png"];
        
    }
    return self;
}

#pragma mark -
#pragma mark Handling events

// Reference: iPhone Application Programming Guide > Device Support > Displaying Maps and Annotations > Displaying Annotations > Handling Events in an Annotation View

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    // The view is configured for single touches only.
    UITouch* aTouch = [touches anyObject];
    _startLocation = [aTouch locationInView:[self superview]];
    _originalCenter = self.center;
    
    [super touchesBegan:touches withEvent:event];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    
    UITouch* aTouch = [touches anyObject];
    CGPoint newLocation = [aTouch locationInView:[self superview]];
    CGPoint newCenter;
    
    // If the user's finger moved more than 5 pixels, begin the drag.
    if ((abs(newLocation.x - _startLocation.x) > 5.0) || (abs(newLocation.y - _startLocation.y) > 5.0)) {
        _isMoving = YES;
    }
    
    // If dragging has begun, adjust the position of the view.
    if (_mapView && _isMoving) {
        newCenter.x = _originalCenter.x + (newLocation.x - _startLocation.x);
        newCenter.y = _originalCenter.y + (newLocation.y - _startLocation.y);
        self.center = newCenter;
    } else {
        // Let the parent class handle it.
        [super touchesMoved:touches withEvent:event];
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    
    if (_mapView && _isMoving) {
        // Update the map coordinate to reflect the new position.
        CGPoint newCenter = self.center;
        DDAnnotation* theAnnotation = (DDAnnotation *)self.annotation;
        CLLocationCoordinate2D newCoordinate = [_mapView convertPoint:newCenter toCoordinateFromView:self.superview];
        [[LocationController sharedLocationController] setTempPoint:newCoordinate];

        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        [prefs setObject:@"ChangedNewLoc" forKey:@"ChangedNewLoc"];
        [prefs synchronize];

        CLLocation* loc = [[CLLocation alloc] initWithLatitude:newCoordinate.latitude longitude:newCoordinate.longitude];
        [theAnnotation changeCoordinate:loc];
        
        // Clean up the state information.
        _startLocation = CGPointZero;
        _originalCenter = CGPointZero;
        _isMoving = NO;
    } else {
        [super touchesEnded:touches withEvent:event];
    }
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    
    if (_mapView && _isMoving) {
        // Move the view back to its starting point.
        self.center = _originalCenter;
        
        // Clean up the state information.
        _startLocation = CGPointZero;
        _originalCenter = CGPointZero;
        _isMoving = NO;
    } else {
        [super touchesCancelled:touches withEvent:event];		
    }
}

@end
