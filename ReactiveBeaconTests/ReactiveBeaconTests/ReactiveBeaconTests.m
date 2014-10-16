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
            __block CLBeacon *beacon;
            [manager.beaconsInRange subscribeNext:^(NSArray *beacons) {
                expect(beacons).to.containInstancesOfClass(CLBeacon.class);
                
                beacon = beacons.firstObject;
            }];
            
            [manager locationManager:manager.locationManager didRangeBeacons:@[mockBeacon] inRegion:region];
            
            expect(beacon).to.equal(mockBeacon);
        });
    });
    
    describe(@"region signals", ^{
        it(@"creates presence signals for specfied regions", ^{
            RACSignal *signal = [manager presenceForRegion:region];
            
            __block BOOL presence = NO;
            
            [signal subscribeNext:^(NSNumber *present) {
                expect(present).to.beKindOf(NSNumber.class);
                
                presence = present.boolValue;
            }];
            expect(presence).to.beFalsy();
            
            [manager locationManager:manager.locationManager didEnterRegion:region];
            expect(presence).to.beTruthy();
            
            [manager locationManager:manager.locationManager didExitRegion:region];
            expect(presence).to.beFalsy();
        });
        
        it(@"fetches presence for a specfied region", ^{
            RACSignal *signal = [manager fetchPresenceForRegion:region];
            
            __block BOOL presence = NO;
            [signal subscribeNext:^(NSNumber *present) {
                expect(present).to.beKindOf(NSNumber.class);
                
                presence = present.boolValue;
            }];
            expect(presence).to.beFalsy();
            
            [manager locationManager:manager.locationManager didDetermineState:CLRegionStateInside forRegion:region];
            
            expect(presence).to.beTruthy();
            
            BOOL success = [signal asynchronouslyWaitUntilCompleted:NULL];
            expect(success).to.beTruthy();
        });
        
        it(@"sends an error when monitoring fails", ^{
            RACSignal *signal = [manager presenceForRegion:region];
            
            __block NSError *error;
            
            [signal subscribeError:^(NSError *e) {
                error = e;
            }];
            expect(error).to.beNil();
            
            NSError *mockError = [NSError errorWithDomain:@"com.robinpowered.reactivebeacon" code:-1001 userInfo:@{}];
            [manager locationManager:manager.locationManager monitoringDidFailForRegion:region withError:mockError];
            
            expect(error).will.equal(mockError);
        });
    });
});


SpecEnd
