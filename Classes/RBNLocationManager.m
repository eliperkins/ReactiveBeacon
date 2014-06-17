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

@interface RBNLocationManager () <CLLocationManagerDelegate>

@property (nonatomic, strong) CLBeaconRegion *region;

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
        [self.locationManager startMonitoringForRegion:self.region];
    }
    return self;
}

- (RACSignal *)fetchState {
    return [RACSignal defer:^{
        [self.locationManager requestStateForRegion:self.region];
        return [[[self rac_signalForSelector:@selector(locationManager:didDetermineState:forRegion:) fromProtocol:@protocol(CLLocationManagerDelegate)]
                reduceEach:^(CLLocationManager *manager, CLRegionState state, CLRegion *region){
                    return @(state);
                }]
                take:1];
    }];
}

- (RACSignal *)regionSignal {
    return [RACSignal defer:^{
        [self.locationManager startMonitoringForRegion:self.region];
        return [[self rac_signalForSelector:@selector(locationManager:didEnterRegion:) fromProtocol:@protocol(CLLocationManagerDelegate)]
                reduceEach:^(CLLocationManager *manager, CLRegion *region){
                    return region;
                }];
    }];
}

- (RACSignal *)beaconSignal {
    return [RACSignal defer:^{
        [self.locationManager startRangingBeaconsInRegion:self.region];
        return [[self rac_signalForSelector:@selector(locationManager:didRangeBeacons:inRegion:) fromProtocol:@protocol(CLLocationManagerDelegate)]
                reduceEach:^(CLLocationManager *manager, NSArray *beacons, CLBeaconRegion *region) {
                    return beacons;
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
