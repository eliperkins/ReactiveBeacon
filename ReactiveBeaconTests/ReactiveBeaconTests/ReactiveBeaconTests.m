//
//  ReactiveBeaconTests.m
//  ReactiveBeaconTests
//
//  Created by Eli Perkins on 6/11/14.
//  Copyright (c) 2014 Robin Powered. All rights reserved.
//

@import CoreLocation;
#import <ReactiveBeacon/ReactiveBeacon.h>

SpecBegin(InitialSpecs)

describe(@"RBNLocationManager", ^{
    NSUUID *UUID = [NSUUID UUID];
    
    __block CLBeacon *mockBeacon;
    __block CLBeaconRegion *region;
    __block RBNLocationManager *manager;
    
    beforeAll(^{
        manager = [[RBNLocationManager alloc] initWithUUID:UUID];
        
        mockBeacon = [OCMockObject niceMockForClass:CLBeacon.class];
        OCMStub([mockBeacon proximityUUID]).andReturn(UUID);
        OCMStub([mockBeacon major]).andReturn(10);
        OCMStub([mockBeacon minor]).andReturn(1);
        OCMStub([mockBeacon accuracy]).andReturn(3.1);
        OCMStub([mockBeacon rssi]).andReturn(-70);
        
        region = [[CLBeaconRegion alloc] initWithProximityUUID:UUID major:10 minor:1 identifier:@"mock.region"];
    });
    
    describe(@"beacon signals", ^{
        it(@"contains a signal of nearby beacons", ^{
            RACSignal *signal = manager.beaconsInRange;
            LLSignalTestRecorder *recorder = [LLSignalTestRecorder recordWithSignal:signal];

            [manager locationManager:manager.locationManager didRangeBeacons:@[mockBeacon] inRegion:region];
            
            expect(recorder).to.sendValues(@[ @[mockBeacon] ]);
        });
    });
    
    describe(@"region signals", ^{
        it(@"creates presence signals for specfied regions", ^{
            RACSignal *signal = [manager presenceForRegion:region];
            LLSignalTestRecorder *recorder = [LLSignalTestRecorder recordWithSignal:signal];

            [manager locationManager:manager.locationManager didEnterRegion:region];
            [manager locationManager:manager.locationManager didExitRegion:region];
            
            expect(recorder).to.sendValues(@[ @YES, @NO ]);
        });
        
        it(@"fetches presence for a specfied region", ^{
            RACSignal *signal = [manager fetchPresenceForRegion:region];
            LLSignalTestRecorder *recorder = [LLSignalTestRecorder recordWithSignal:signal];
            
            [manager locationManager:manager.locationManager didDetermineState:CLRegionStateInside forRegion:region];

            expect(recorder).to.sendValues(@[ @YES ]);
            expect(recorder).to.complete();
            
        });
        
        it(@"sends an error when monitoring fails", ^{
            RACSignal *signal = [manager presenceForRegion:region];
            LLSignalTestRecorder *recorder = [LLSignalTestRecorder recordWithSignal:signal];
            
            NSError *mockError = [NSError errorWithDomain:@"com.robinpowered.reactivebeacon" code:-1001 userInfo:@{}];

            [manager locationManager:manager.locationManager monitoringDidFailForRegion:region withError:mockError];
            
            expect(recorder).to.sendError(mockError);
        });
    });
});

SpecEnd
