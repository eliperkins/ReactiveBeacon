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

- (RACSignal *)beaconSignalForUUID:(NSUUID *)UUID;

@end
