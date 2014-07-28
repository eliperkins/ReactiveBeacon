//
//  RBNLocationManager.h
//  ReactiveBeacon
//
//  Created by Eli Perkins on 6/11/14.
//  Copyright (c) 2014 Robin Powered. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ReactiveCocoa/ReactiveCocoa.h>

@import CoreLocation;

@interface RBNLocationManager : NSObject

@property (nonatomic, strong) CLLocationManager *locationManager;

- (instancetype)initWithUUID:(NSUUID *)UUID;

// Multicasted signal for ranging callbacks
//
// Returns a signal which sends nexts of arrays of CLBeacons
@property (nonatomic, strong, readonly) RACSignal *beaconsInRange;

// A signal which wraps entrance and exit delegate callbacks (entrance as YES, exit as NO)
//
// Returns a signal which sends YES and NO for presence
- (RACSignal *)presenceForRegion:(CLBeaconRegion *)region;

// Fetch the current presence for a region
// Use this in-place of waiting for entrance or exit of a region
//
// Returns a signal which sends the state (YES or NO) once and completes
- (RACSignal *)fetchPresenceForRegion:(CLBeaconRegion *)region;

@end

@interface RBNLocationManager (Deprecated)

- (RACSignal *)fetchState __attribute__((deprecated("Use -fetchPresenceForRegion: instead")));
- (RACSignal *)regionSignal __attribute__((deprecated("Use -presenceForRegion: instead")));
- (RACSignal *)beaconSignal __attribute__((deprecated("Use -beaconsInRange instead")));

@end