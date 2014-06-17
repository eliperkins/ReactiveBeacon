//
//  RBNLocationManager.h
//  ReactiveBeacon
//
//  Created by Eli Perkins on 6/11/14.
//  Copyright (c) 2014 Robin Powered. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ReactiveCocoa/ReactiveCocoa.h>

@import CoreLocation;

@interface RBNLocationManager : NSObject

@property (nonatomic, strong) CLLocationManager *locationManager;

- (instancetype)initWithUUID:(NSUUID *)UUID;

- (RACSignal *)fetchState;
- (RACSignal *)regionSignal;
- (RACSignal *)beaconSignal;

@end
