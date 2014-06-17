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

@property (nonatomic, strong) CLLocationManager *locationManager;

@end

@implementation RBNLocationManager

- (instancetype)init {
    self = [super init];
    if (self) {
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.delegate = self;
    }
    return self;
}

- (RACSignal *)beaconSignalForUUID:(NSUUID *)UUID {
    @weakify(self);
    return [[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        // Create region from UUID
        CLBeaconRegion *region = [[CLBeaconRegion alloc] initWithProximityUUID:UUID identifier:@"com.robinpowered.identity"];
        region.notifyEntryStateOnDisplay = YES;
        region.notifyOnEntry = YES;

        // Start looking for said region
        @strongify(self);
        [self.locationManager startMonitoringForRegion:region];

        // When the region is entered...
        [[[[self rac_signalForSelector:@selector(locationManager:didEnterRegion:)
                        fromProtocol:@protocol(CLLocationManagerDelegate)]
         reduceEach:^(CLLocationManager *manager, CLRegion *region){
             return region;
        }]
          take:1]
         concat:<#(RACSignal *)#>];
        
        // ...look for specific iBeacons in the region...
        [self.locationManager startRangingBeaconsInRegion:region];
        
        // ...which will come back here.
        [[self rac_signalForSelector:@selector(locationManager:didRangeBeacons:inRegion:)
                        fromProtocol:@protocol(CLLocationManagerDelegate)]
         reduceEach:^(CLLocationManager *manager, NSArray *beacons, CLBeaconRegion *region){
             return beacons.rac_sequence.signal;
         }];
        
        
        // When you exit the region, maybe do something? Like stop ranging...
        [self rac_signalForSelector:@selector(locationManager:didExitRegion:) fromProtocol:@protocol(CLLocationManagerDelegate)];

         
        RACDisposable *disposable = [[[self rac_signalForSelector:@selector(locationManager:didRangeBeacons:inRegion:)
                                                     fromProtocol:@protocol(CLLocationManagerDelegate)]
                                        reduceEach:^(CLLocationManager *managers, NSArray *beacons, CLRegion *region) {
                                            return beacons;
                                        }]
                                        subscribe:subscriber];

        
        
        return [RACDisposable disposableWithBlock:^{
            [disposable dispose];
            @strongify(self);
            [self.locationManager stopMonitoringForRegion:region];
        }];
    }] setNameWithFormat:@"<%@:%p> -beaconSignalForUUID: %@", self.class, self, UUID];
}

@end

//44F77920-EBF9-11E3-AC10-0800200C9A66