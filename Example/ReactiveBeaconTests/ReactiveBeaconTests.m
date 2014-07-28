
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

describe(@"mock some shit", ^{
    NSUUID *UUID = [NSUUID UUID];
    CLBeacon *mockBeacon = [OCMockObject niceMockForClass:CLBeacon.class];
    OCMStub([mockBeacon proximityUUID]).andReturn(UUID);
    RBNLocationManager *manager = [[RBNLocationManager alloc] initWithUUID:UUID];
    
    id someDelegateMock = [OCMockObject mockForProtocol:@protocol(CLLocationManagerDelegate)];
    
    it(@"", ^{

    });
    
});

SpecEnd
