//
//  RBNBeaconManager.h
//  Pods
//
//  Created by Eli Perkins on 10/17/14.
//
//

#import <Foundation/Foundation.h>
@import CoreLocation;

@class RACSignal;
@class RACScheduler;

/**
 @class
 RBNBeaconManager Manager for beacons and beacon regions
 
 @abstract
 Manages beacon ranging and monitoring

 **/

@interface RBNBeaconManager : NSObject <CLLocationManagerDelegate>

/// RBNBeaconRegion objects to be monitored or ranged for
///
/// @note This property is derived from the `initWithRegions:` initializers
@property (readonly, nonatomic, strong) NSSet *regions;

/// Exposed location manager.
//
/// @note Do not use this location manager for any shenanigans, let RBNBeaconManager do the work
@property (readonly, nonatomic, strong) CLLocationManager *locationManager;

/// Subscribing to this signal will begin monitoring for regions, unsubscibing will stop
/// Sends tuples of (`RBNBeaconRegion`, `BOOL`) for enter and exit events for `regions`
@property (readonly, nonatomic, strong) RACSignal *presenceEvents;

/// Subscribing to this signal will begin ranging for beacons in regions, unsubscribing will stop
/// Sends any beacons which are ranged for in `regions`
@property (readonly, nonatomic, strong) RACSignal *rangedBeacons;

/// Scheduler to execute monitoring and ranging callbacks on
///
/// @note Keeps threading sane as delegate callbacks will be fast and furious
@property (readonly, nonatomic, strong) RACScheduler *scheduler;

/// Initialize with a given set of `RBNBeaconRegions`. `locationManager` and `scheduler` will be supplied internally.
- (instancetype)initWithRegions:(NSSet *)regions;

/// Initialize with a given set of `RBNBeaconRegions` and `locationManager`. `scheduler` will be supplied internally.
- (instancetype)initWithRegions:(NSSet *)regions locationManager:(CLLocationManager *)locationManager;

/// Initialize with a given set of `RBNBeaconRegions`, `locationManager` and `scheduler`.
- (instancetype)initWithRegions:(NSSet *)regions locationManager:(CLLocationManager *)locationManager scheduler:(RACScheduler *)scheduler NS_DESIGNATED_INITIALIZER;

@end
