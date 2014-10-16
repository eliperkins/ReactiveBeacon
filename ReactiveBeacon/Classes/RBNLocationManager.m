//
//  RBNLocationManager.m
//  ReactiveBeacon
//
//  Created by Eli Perkins on 6/11/14.
//  Copyright (c) 2014 Robin Powered. All rights reserved.
//

#import "RBNLocationManager.h"
#import <ReactiveCocoa/RACEXTScope.h>

@import CoreLocation;

@interface RBNLocationManager ()

@end

@implementation RBNLocationManager

- (instancetype)initWithUUID:(NSUUID *)UUID {
    self = [super init];
    if (self) {
        _locationManager = [[CLLocationManager alloc] init];

        _locationManager.delegate = self;
        _region = [[CLBeaconRegion alloc] initWithProximityUUID:UUID identifier:@"com.robinpowered.rbnlocationmanager"];

        self.region.notifyOnEntry = YES;
        self.region.notifyOnExit = YES;
        self.region.notifyEntryStateOnDisplay = YES;

        _beaconsInRange = [[[self
            rac_signalForSelector:@selector(locationManager:didRangeBeacons:inRegion:)
            fromProtocol:@protocol(CLLocationManagerDelegate)]
            reduceEach:^(CLLocationManager *manager, NSArray *beacons, CLBeaconRegion *region) {
                return beacons;
            }]
            setNameWithFormat:@"-beaconsInRange"];
    }
    return self;
}

- (RACSignal *)presenceForRegion:(CLBeaconRegion *)region {
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        RACSignal *entranceSignal = [[[[self
            rac_signalForSelector:@selector(locationManager:didEnterRegion:)
            fromProtocol:@protocol(CLLocationManagerDelegate)]
            reduceEach:^(CLLocationManager *manager, CLRegion *region){
                return region;
            }]
            filter:^BOOL(CLRegion *enteredRegion) {
                return [enteredRegion isEqual:region];
            }]
            mapReplace:@YES];

        RACSignal *exitSignal = [[[[self
            rac_signalForSelector:@selector(locationManager:didExitRegion:)
            fromProtocol:@protocol(CLLocationManagerDelegate)]
            reduceEach:^(CLLocationManager *manager, CLRegion *region){
                return region;
            }]
            filter:^BOOL(CLRegion *exitedRegion) {
                return [exitedRegion isEqual:region];
            }]
            mapReplace:@NO];

        // Currently, iOS will not send the initial state for a region
        // immediately via didEnterRegion or didExitRegion
        // But, explicitly requesting it will get the initial state
        RACSignal *currentSignal = [self fetchPresenceForRegion:region];

        RACDisposable *disposable = [[RACSignal
            merge:@[ currentSignal, entranceSignal, exitSignal ]]
            subscribe:subscriber];

        // Lift errors out of the delegate callback
        RACDisposable *failedDisposable = [[[self
            rac_signalForSelector:@selector(locationManager:monitoringDidFailForRegion:withError:)
            fromProtocol:@protocol(CLLocationManagerDelegate)]
            filter:^BOOL(RACTuple *tuple) {
                return [tuple.second isEqual:region];
            }]
            subscribeNext:^(RACTuple *tuple) {
                [subscriber sendError:tuple.third];
            }];

        [self.locationManager startMonitoringForRegion:region];

        return [RACDisposable disposableWithBlock:^{
            [disposable dispose];
            [failedDisposable dispose];
            [self.locationManager stopMonitoringForRegion:region];
        }];
    }];
}

- (RACSignal *)fetchPresenceForRegion:(CLBeaconRegion *)region {
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        RACDisposable *disposable = [[[[[self
            rac_signalForSelector:@selector(locationManager:didDetermineState:forRegion:)
            fromProtocol:@protocol(CLLocationManagerDelegate)]
            filter:^BOOL(RACTuple *tuple) {
                return [tuple.third isEqual:region];
            }]
            reduceEach:^(CLLocationManager *manager, NSNumber *state, CLRegion *region) {
                return @(state.integerValue == CLRegionStateInside);
            }]
            take:1]
            subscribe:subscriber];

        [self.locationManager requestStateForRegion:region];

        return [RACDisposable disposableWithBlock:^{
            [disposable dispose];
        }];

    }];
}

- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region {}
- (void)locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(CLBeaconRegion *)region {}
- (void)locationManager:(CLLocationManager *)manager didDetermineState:(CLRegionState)state forRegion:(CLRegion *)region {}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    NSLog(@"Bad things: %@", error);
}

- (void)locationManager:(CLLocationManager *)manager monitoringDidFailForRegion:(CLRegion *)region withError:(NSError *)error {
    NSLog(@"Worse things: %@", error);
}

@end
