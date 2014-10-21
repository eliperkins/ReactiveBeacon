//
//  RBNBeaconManager.m
//  Pods
//
//  Created by Eli Perkins on 10/17/14.
//
//

#import "RBNBeaconManager.h"
#import "RBNBeaconRegion.h"
#import <ReactiveCocoa/ReactiveCocoa.h>

@interface RBNBeaconManager ()

@end

@implementation RBNBeaconManager

- (instancetype)initWithRegions:(NSSet *)regions {
    return [self initWithRegions:regions locationManager:nil];
}

- (instancetype)initWithRegions:(NSSet *)regions locationManager:(CLLocationManager *)locationManager {
    return [self initWithRegions:regions locationManager:locationManager scheduler:nil];
}

- (instancetype)initWithRegions:(NSSet *)regions locationManager:(CLLocationManager *)locationManager scheduler:(RACScheduler *)scheduler {
    self = [super init];
    if (self) {
        if (!locationManager) {
            locationManager = [[CLLocationManager alloc] init];
        }
        
        if (!scheduler) {
            dispatch_queue_t queue = dispatch_queue_create("com.eliperkins.RBNBeaconRegion.CoreBluetoothQueue", DISPATCH_QUEUE_SERIAL);
            scheduler = [[RACTargetQueueScheduler alloc] initWithName:@"com.eliperkins.RBNBeaconRegion.CoreBluetoothScheduler" targetQueue:queue];
        }
        
        _locationManager = locationManager;
        self.locationManager.delegate = self;
        
        _scheduler = scheduler;
        
        RACSubject *subject = [RACSubject subject];
        for (RBNBeaconRegion *region in regions) {
            region.manager = self;
            [[region.presence map:^(NSNumber *presence) {
                return RACTuplePack(region, presence);
            }] subscribe:subject];
        }
        _presenceEvents = [subject deliverOn:self.scheduler];
    }
    return self;
}

#pragma mark CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region {}
- (void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region {}
- (void)locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(CLBeaconRegion *)region {}
- (void)locationManager:(CLLocationManager *)manager didDetermineState:(CLRegionState)state forRegion:(CLRegion *)region {}

#pragma mark Errors

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    NSLog(@"Bad things: %@", error);
}

- (void)locationManager:(CLLocationManager *)manager monitoringDidFailForRegion:(CLRegion *)region withError:(NSError *)error {
    NSLog(@"Worse things: %@", error);
}

@end
