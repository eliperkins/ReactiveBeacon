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
    
    __block id mockBeaconOne;
    __block id mockBeaconTwo;
    __block id mockLocationManager;
    
    beforeAll(^{
        testRegionOne = [[RBNBeaconRegion alloc] initWithProximityUUID:[NSUUID UUID] identifier:@"testRegionOne"];
        testRegionTwo = [[RBNBeaconRegion alloc] initWithProximityUUID:[NSUUID UUID] identifier:@"testRegionTwo"];
        
        mockLocationManager = OCMClassMock(CLLocationManager.class);

        manager = [[RBNBeaconManager alloc] initWithRegions:[NSSet setWithArray:@[ testRegionOne, testRegionTwo ]]
                                            locationManager:mockLocationManager];
        
        mockBeaconOne = OCMClassMock(CLBeacon.class);
        OCMStub([mockBeaconOne proximityUUID]).andReturn(testRegionOne.proximityUUID);
        OCMStub([mockBeaconOne major]).andReturn(1);
        OCMStub([mockBeaconOne minor]).andReturn(2);
        OCMStub([mockBeaconOne accuracy]).andReturn(5);
        OCMStub([mockBeaconOne rssi]).andReturn(-70);

        mockBeaconTwo = OCMClassMock(CLBeacon.class);
        OCMStub([mockBeaconTwo proximityUUID]).andReturn(testRegionTwo.proximityUUID);
        OCMStub([mockBeaconTwo major]).andReturn(1);
        OCMStub([mockBeaconTwo minor]).andReturn(2);
        OCMStub([mockBeaconTwo accuracy]).andReturn(5);
        OCMStub([mockBeaconTwo rssi]).andReturn(-70);
    });
    
    it(@"should assign regions `manager` property to self when init'ed", ^{
        expect(testRegionOne.manager).to.equal(manager);
        expect(testRegionTwo.manager).to.equal(manager);
    });
    
    it(@"should set presence for regions as enter and exit events happen", ^{
        RACSignal *signal = testRegionOne.presence;
        LLSignalTestRecorder *recorder = signal.testRecorder;
        
        [manager locationManager:manager.locationManager didEnterRegion:testRegionOne];
        [manager locationManager:manager.locationManager didExitRegion:testRegionOne];
        
        expect(recorder).to.sendValues(@[ @YES, @NO ]);
    });
    
    it(@"should send collective presence events for all regions", ^{
        RACSignal *signal = manager.presenceEvents;
        LLSignalTestRecorder *recorder = signal.testRecorder;
        
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
        LLSignalTestRecorder *recorder = signal.testRecorder;

        NSArray *beacons = @[ mockBeaconOne ];
        [manager locationManager:manager.locationManager didRangeBeacons:beacons inRegion:testRegionOne];
        
        expect(recorder).to.sendValues(@[ beacons ]);
    });
    
    it(@"should not send ranged beacons for another region", ^{
        RACSignal *signal = testRegionOne.rangedBeacons;
        LLSignalTestRecorder *recorder = signal.testRecorder;
        
        NSArray *beacons = @[ mockBeaconTwo ];
        [manager locationManager:manager.locationManager didRangeBeacons:beacons inRegion:testRegionTwo];
        
        expect(recorder).to.sendValues(@[ ]);
    });

    it(@"should start/stop ranging beacons on subscription/disposal", ^{
        RACSignal *signal = testRegionOne.rangedBeacons;
        
        [signal startCountingSubscriptions];
        
        RACDisposable *disposable = [signal subscribeNext:^(id x) {}];
        
        OCMVerify([mockLocationManager startRangingBeaconsInRegion:testRegionOne]);

        NSArray *beacons = @[ mockBeaconOne ];
        [manager locationManager:manager.locationManager didRangeBeacons:beacons inRegion:testRegionOne];
        
        [disposable dispose];
        
        [signal stopCountingSubscriptions];
        
        OCMVerify([mockLocationManager stopRangingBeaconsInRegion:testRegionOne]);
    });
});

SpecEnd
