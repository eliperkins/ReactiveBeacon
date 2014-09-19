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

/**
 @class
 RBNLocationManager Main Class.

 @abstract
 Class used to lift beacons into the ReactiveCocoa world.
 **/

@interface RBNLocationManager : NSObject <CLLocationManagerDelegate>

/// Exposed location manager.
//
/// @note Do not use this location manager for any shenanigans, let RBNLocationManager do the work
@property (nonatomic, strong, readonly) CLLocationManager *locationManager;

/// Beacon region to be monitored by this class
///
/// @note This region is generated when calling `initWithUUID:` as a generic region
@property (nonatomic, strong, readonly) CLBeaconRegion *region;

/// Multicasted signal for ranging callbacks
///
/// @return A signal which sends nexts of arrays of CLBeacons
@property (nonatomic, strong, readonly) RACSignal *beaconsInRange;

/// Designated initializer
///
/// @param UUID The proximityUUID to look for beacons
- (instancetype)initWithUUID:(NSUUID *)UUID;

/// A signal which wraps entrance and exit delegate callbacks (entrance as YES, exit as NO)
///
/// @param region A CLBeaconRegion to monitor for
/// @return A signal which sends YES and NO for presence
- (RACSignal *)presenceForRegion:(CLBeaconRegion *)region;

/// Fetch the current presence for a region
/// Use this in-place of waiting for entrance or exit of a region
///
/// @param region A CLBeaconRegion to monitor for
/// @return A signal which sends the state (YES or NO) once and completes
- (RACSignal *)fetchPresenceForRegion:(CLBeaconRegion *)region;

@end

@interface RBNLocationManager (Deprecated)

- (RACSignal *)fetchState __attribute__((deprecated("Use -fetchPresenceForRegion: instead")));
- (RACSignal *)regionSignal __attribute__((deprecated("Use -presenceForRegion: instead")));
- (RACSignal *)beaconSignal __attribute__((deprecated("Use -beaconsInRange instead")));

@end