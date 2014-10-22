//
//  RBNBeaconRegion.h
//  Pods
//
//  Created by Eli Perkins on 10/16/14.
//
//

@import CoreLocation;

@class RACSignal;
@class RACScheduler;
@class RBNBeaconManager;

/**
 @class 
 RBNBeaconRegion Subclass of CLBeaconRegion, used to lift beacon events into the reactive world
 */

@interface RBNBeaconRegion : CLBeaconRegion

/// Subscribing to this signal will begin monitoring for the region, unsubscribing will stop
/// Sends nexts of `@YES` or `@NO` for enter and exit events
@property (readonly, nonatomic, strong) RACSignal *presence;

/// Subscribing to this signal will begin ranging for beacons in the region, unsubscribing will stop
/// Sends nexts of arrays of `CLBeacon` objects at intervals
@property (readonly, nonatomic, strong) RACSignal *rangedBeacons;

/// Delegated manager for region
@property (nonatomic, weak) RBNBeaconManager *manager;

@end
