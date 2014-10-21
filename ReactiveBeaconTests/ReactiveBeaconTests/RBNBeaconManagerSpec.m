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

    __block NSUUID *testRegionOneUUID;
    __block NSUUID *testRegionTwoUUID;
    
    __block RBNBeaconRegion *testRegionOne;
    __block RBNBeaconRegion *testRegionTwo;
    
    __block id mockBeaconOne;
    __block id mockBeaconTwo;
    __block id mockLocationManager;
    
    __block LLSignalTestRecorder *recorder;
    
    __block RACTestScheduler *scheduler;
    
    beforeAll(^{
        testRegionOneUUID = [[NSUUID alloc] initWithUUIDString:@"C20F8CE5-30F0-461A-93FC-B9DF413E517D"];
        testRegionTwoUUID = [[NSUUID alloc] initWithUUIDString:@"B82E233A-7689-45A5-ADC8-E5D91BA5D1B4"];
        
        mockBeaconOne = OCMClassMock(CLBeacon.class);
        OCMStub([mockBeaconOne proximityUUID]).andReturn(testRegionOneUUID);
        OCMStub([mockBeaconOne major]).andReturn(1);
        OCMStub([mockBeaconOne minor]).andReturn(2);
        OCMStub([mockBeaconOne accuracy]).andReturn(3.0);
        OCMStub([mockBeaconOne rssi]).andReturn(-70);

        mockBeaconTwo = OCMClassMock(CLBeacon.class);
        OCMStub([mockBeaconTwo proximityUUID]).andReturn(testRegionTwoUUID);
        OCMStub([mockBeaconTwo major]).andReturn(1);
        OCMStub([mockBeaconTwo minor]).andReturn(2);
        OCMStub([mockBeaconTwo accuracy]).andReturn(5.0);
        OCMStub([mockBeaconTwo rssi]).andReturn(-70);
        
        mockLocationManager = OCMClassMock(CLLocationManager.class);
        
        testRegionOne = [[RBNBeaconRegion alloc] initWithProximityUUID:testRegionOneUUID identifier:@"testRegionOne"];
        testRegionTwo = [[RBNBeaconRegion alloc] initWithProximityUUID:testRegionTwoUUID identifier:@"testRegionTwo"];
        
        scheduler = [[RACTestScheduler alloc] init];
        
        manager = [[RBNBeaconManager alloc] initWithRegions:[NSSet setWithArray:@[ testRegionOne, testRegionTwo ]]
                                            locationManager:mockLocationManager
                                                  scheduler:scheduler];
    });
    
    afterEach(^{
        recorder = nil;
    });
    
    describe(@"manager", ^{
        it(@"should send collective presence events for all regions", ^{
            RACSignal *signal = manager.presenceEvents;
            recorder = signal.testRecorder;
            
            [manager locationManager:manager.locationManager didEnterRegion:testRegionOne];
            [manager locationManager:manager.locationManager didExitRegion:testRegionOne];
            [manager locationManager:manager.locationManager didEnterRegion:testRegionTwo];
            [manager locationManager:manager.locationManager didEnterRegion:testRegionOne];
            
            [scheduler stepAll];
            
            expect(recorder).to.sendValues(@[ RACTuplePack(testRegionOne, @YES),
                                              RACTuplePack(testRegionOne, @NO),
                                              RACTuplePack(testRegionTwo, @YES),
                                              RACTuplePack(testRegionOne, @YES) ]);
        });
        
        it(@"should send collective beacon ranging events for all regions", ^{
            RACSignal *signal = manager.rangedBeacons;
            recorder = signal.testRecorder;
            
            [manager locationManager:manager.locationManager didRangeBeacons:@[ mockBeaconOne ] inRegion:testRegionOne];
            [manager locationManager:manager.locationManager didRangeBeacons:@[ mockBeaconTwo ] inRegion:testRegionTwo];
            
            [scheduler stepAll];
            
            expect(recorder).to.sendValues(@[ @[], @[ mockBeaconOne ], @[ mockBeaconOne, mockBeaconTwo ] ]);
        });
    });
    
    describe(@"beacon regions", ^{
        it(@"should assign regions `manager` property to self when init'ed", ^{
            expect(testRegionOne.manager).to.equal(manager);
            expect(testRegionTwo.manager).to.equal(manager);
        });
        
        it(@"should set presence for regions as enter and exit events happen", ^{
            RACSignal *signal = testRegionOne.presence;
            recorder = signal.testRecorder;
            
            [manager locationManager:manager.locationManager didDetermineState:CLRegionStateOutside forRegion:testRegionOne];
            [manager locationManager:manager.locationManager didEnterRegion:testRegionOne];
            [manager locationManager:manager.locationManager didExitRegion:testRegionOne];
            
            [scheduler stepAll];
            
            expect(recorder).to.sendValues(@[ @NO, @YES, @NO ]);
        });
        
        it(@"should range beacons for a specified region", ^{
            RACSignal *signal = testRegionOne.rangedBeacons;
            recorder = signal.testRecorder;
            
            NSArray *beacons = @[ mockBeaconOne ];
            [manager locationManager:manager.locationManager didRangeBeacons:beacons inRegion:testRegionOne];
            
            [scheduler stepAll];
            
            expect(recorder).to.sendValues(@[ beacons ]);
        });
        
        it(@"should not send ranged beacons for another region", ^{
            RACSignal *signal = testRegionOne.rangedBeacons;
            recorder = signal.testRecorder;
            
            NSArray *beacons = @[ mockBeaconTwo ];
            [manager locationManager:manager.locationManager didRangeBeacons:beacons inRegion:testRegionTwo];
            
            [scheduler stepAll];
            
            expect(recorder).to.sendValues(@[ ]);
        });
        
        it(@"should start/stop ranging beacons on subscription/disposal", ^{
            RACSignal *signal = testRegionOne.rangedBeacons;
            
            RACDisposable *disposable = [signal subscribeNext:^(id x) {}];
            RACDisposable *disposableTwo = [signal subscribeNext:^(id x) {}];
            RACCompoundDisposable *compoundDisposable = [RACCompoundDisposable compoundDisposableWithDisposables:@[disposable, disposableTwo]];
            
            OCMVerify([mockLocationManager startRangingBeaconsInRegion:testRegionOne]);
            
            NSArray *beacons = @[ mockBeaconOne ];
            [manager locationManager:manager.locationManager didRangeBeacons:beacons inRegion:testRegionOne];
            
            [compoundDisposable dispose];
            
            [scheduler stepAll];
            
            OCMVerify([mockLocationManager stopRangingBeaconsInRegion:testRegionOne]);
        });
    });
});

SpecEnd
