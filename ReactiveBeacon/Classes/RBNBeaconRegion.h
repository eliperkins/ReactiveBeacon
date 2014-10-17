//
//  RBNBeaconRegion.h
//  Pods
//
//  Created by Eli Perkins on 10/16/14.
//
//

@import CoreLocation;

@class RACSignal;
@class RBNBeaconManager;

@interface RBNBeaconRegion : CLBeaconRegion

@property (readonly, nonatomic, assign) BOOL presence;

@property (readonly, nonatomic, strong) RACSignal *rangedBeacons;

@property (nonatomic, weak) RBNBeaconManager *manager;

@end
