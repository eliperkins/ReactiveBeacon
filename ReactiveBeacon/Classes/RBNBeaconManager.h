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

@interface RBNBeaconManager : NSObject <CLLocationManagerDelegate>

@property (readonly, nonatomic, strong) NSSet *regions;

@property (nonatomic, strong, readonly) CLLocationManager *locationManager;

@property (readonly, nonatomic, strong) RACSignal *presenceEvents;

@property (readonly, nonatomic, strong) RACSignal *rangedBeacons;

@property (readonly, nonatomic, strong) RACScheduler *scheduler;

- (instancetype)initWithRegions:(NSSet *)regions;

- (instancetype)initWithRegions:(NSSet *)regions locationManager:(CLLocationManager *)locationManager;

- (instancetype)initWithRegions:(NSSet *)regions locationManager:(CLLocationManager *)locationManager scheduler:(RACScheduler *)scheduler;

@end
