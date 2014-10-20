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

@interface RBNBeaconManager : NSObject <CLLocationManagerDelegate>

@property (readonly, nonatomic, strong) NSSet *regions;

@property (nonatomic, strong, readonly) CLLocationManager *locationManager;

@property (readonly, nonatomic, strong) RACSignal *presenceEvents;

- (instancetype)initWithRegions:(NSSet *)regions;

- (instancetype)initWithRegions:(NSSet *)regions locationManager:(CLLocationManager *)locationManager;

- (RACSignal *)fetchPresenceForRegion:(CLBeaconRegion *)region;

@end
