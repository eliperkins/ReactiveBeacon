//
//  RBNBeaconManagerSpec.m
//  ReactiveBeacon
//
//  Created by Eli Perkins on 10/17/14.
//  Copyright 2014 Eli Perkins. All rights reserved.
//

#import "RBNBeaconManager.h"
#import "RBNBeaconRegion.h"

SpecBegin(RBNBeaconManager)

describe(@"RBNBeaconManager", ^{
    
    __block RBNBeaconManager *manager;

    __block RBNBeaconRegion *testRegionOne;
    __block RBNBeaconRegion *testRegionTwo;
    
    beforeAll(^{
        testRegionOne = [[RBNBeaconRegion alloc] initWithProximityUUID:[NSUUID UUID] identifier:@"testRegionOne"];
        testRegionTwo = [[RBNBeaconRegion alloc] initWithProximityUUID:[NSUUID UUID] identifier:@"testRegionTwo"];
        
        manager = [[RBNBeaconManager alloc] initWithRegions:[NSSet setWithArray:@[ testRegionOne, testRegionTwo ]]];
    });
    
    it(@"should assign regions `manager` property to self when init'ed", ^{
        expect(testRegionOne.manager).to.equal(manager);
        expect(testRegionTwo.manager).to.equal(manager);
    });
    
    it(@"should set presence for regions as enter and exit events happen", ^{
        RACSignal *signal = [RACObserve(testRegionOne, presence) skip:1]; // Skip the initial value for this test
        LLSignalTestRecorder *recorder = [LLSignalTestRecorder recordWithSignal:signal];
        
        [manager locationManager:manager.locationManager didEnterRegion:testRegionOne];
        expect(testRegionOne.presence).to.beTruthy();
        
        [manager locationManager:manager.locationManager didExitRegion:testRegionOne];
        expect(testRegionOne.presence).to.beFalsy();
        
        expect(recorder).to.sendValues(@[ @YES, @NO ]);
    });
    
    it(@"should send collective presence events for all regions", ^{
        RACSignal *signal = manager.presenceEvents;
        LLSignalTestRecorder *recorder = [LLSignalTestRecorder recordWithSignal:signal];
        
        [manager locationManager:manager.locationManager didEnterRegion:testRegionOne];
        [manager locationManager:manager.locationManager didExitRegion:testRegionOne];
        [manager locationManager:manager.locationManager didEnterRegion:testRegionTwo];
        [manager locationManager:manager.locationManager didEnterRegion:testRegionOne];

        expect(recorder).to.sendValues(@[ RACTuplePack(testRegionOne, @YES),
                                          RACTuplePack(testRegionOne, @NO),
                                          RACTuplePack(testRegionTwo, @YES),
                                          RACTuplePack(testRegionOne, @YES) ]);
    });
    
    it(@"should range beacons for a specified region", ^{
        RACSignal *signal = testRegionOne.rangedBeacons;
        LLSignalTestRecorder *recorder = [LLSignalTestRecorder recordWithSignal:signal];

        id mockBeacon = OCMClassMock(CLBeacon.class);
        OCMStub([mockBeacon proximityUUID]).andReturn(testRegionOne.proximityUUID);
        OCMStub([mockBeacon major]).andReturn(10);
        OCMStub([mockBeacon minor]).andReturn(1);
        OCMStub([mockBeacon accuracy]).andReturn(3.1);
        OCMStub([mockBeacon rssi]).andReturn(-70);

        NSArray *beacons = @[ mockBeacon ];
        [manager locationManager:manager.locationManager didRangeBeacons:beacons inRegion:testRegionOne];
        
        expect(recorder).to.sendValues(@[ beacons ]);
    });
    
    it(@"should not send ranged beacons for another region", ^{
        RACSignal *signal = testRegionOne.rangedBeacons;
        LLSignalTestRecorder *recorder = [LLSignalTestRecorder recordWithSignal:signal];
        
        id mockBeacon = OCMClassMock(CLBeacon.class);
        OCMStub([mockBeacon proximityUUID]).andReturn(testRegionTwo.proximityUUID);
        OCMStub([mockBeacon major]).andReturn(10);
        OCMStub([mockBeacon minor]).andReturn(1);
        OCMStub([mockBeacon accuracy]).andReturn(3.1);
        OCMStub([mockBeacon rssi]).andReturn(-70);
        
        NSArray *beacons = @[ mockBeacon ];
        [manager locationManager:manager.locationManager didRangeBeacons:beacons inRegion:testRegionTwo];
        
        expect(recorder).to.sendValues(@[ ]);
    });

    it(@"should start ranging beacons on subscription", ^{
        
    });
});

SpecEnd
