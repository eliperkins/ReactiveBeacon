//
//  RBNBeaconRegion.m
//  Pods
//
//  Created by Eli Perkins on 10/16/14.
//
//

#import "RBNBeaconRegion.h"
#import "RBNBeaconManager.h"
#import <ReactiveCocoa/ReactiveCocoa.h>
#import <ReactiveCocoa/RACEXTScope.h>

@interface RBNBeaconRegion ()

@end

@implementation RBNBeaconRegion

- (instancetype)initWithProximityUUID:(NSUUID *)proximityUUID identifier:(NSString *)identifier {
    self = [super initWithProximityUUID:proximityUUID identifier:identifier];
    if (self) {
        self.notifyOnExit = YES;
        self.notifyOnEntry = YES;
        self.notifyEntryStateOnDisplay = YES;
        
        _presence = NO;
        _ranging = NO;
        
        @weakify(self);
        RAC(self, presence) = [[RACObserve(self, manager) ignore:nil]
            flattenMap:^RACStream *(RBNBeaconManager *manager) {
                return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
                    RACSignal *entranceSignal = [[[[manager
                        rac_signalForSelector:@selector(locationManager:didEnterRegion:)
                        fromProtocol:@protocol(CLLocationManagerDelegate)]
                        reduceEach:^(CLLocationManager *manager, CLRegion *region){
                            return region;
                        }]
                        filter:^BOOL(CLRegion *enteredRegion) {
                            @strongify(self);
                            return [enteredRegion isEqual:self];
                        }]
                        mapReplace:@YES];

                    RACSignal *exitSignal = [[[[manager
                        rac_signalForSelector:@selector(locationManager:didExitRegion:)
                        fromProtocol:@protocol(CLLocationManagerDelegate)]
                        reduceEach:^(CLLocationManager *manager, CLRegion *region){
                            return region;
                        }]
                        filter:^BOOL(CLRegion *exitedRegion) {
                            @strongify(self);
                            return [exitedRegion isEqual:self];
                        }]
                        mapReplace:@NO];

                    // Currently, iOS will not send the initial state for a region
                    // immediately via didEnterRegion or didExitRegion
                    // But, explicitly requesting it will get the initial state
                    @strongify(self);
                    RACSignal *currentSignal = [manager fetchPresenceForRegion:self];

                    RACDisposable *disposable = [[RACSignal
                        merge:@[ currentSignal, entranceSignal, exitSignal ]]
                        subscribe:subscriber];

                    // Lift errors out of the delegate callback
                    RACDisposable *failedDisposable = [[[manager
                        rac_signalForSelector:@selector(locationManager:monitoringDidFailForRegion:withError:)
                        fromProtocol:@protocol(CLLocationManagerDelegate)]
                        filter:^BOOL(RACTuple *tuple) {
                            @strongify(self);
                            return [tuple.second isEqual:self];
                        }]
                        subscribeNext:^(RACTuple *tuple) {
                            [subscriber sendError:tuple.third];
                        }];

                    [manager.locationManager startMonitoringForRegion:self];

                    @weakify(manager);
                    return [RACDisposable disposableWithBlock:^{
                        [disposable dispose];
                        [failedDisposable dispose];
                        @strongify(self);
                        @strongify(manager);
                        [manager.locationManager stopMonitoringForRegion:self];
                    }];
                }];
            }];
        
        RAC(self, rangedBeacons) = [[RACObserve(self, manager) ignore:nil]
            map:^RACStream *(RBNBeaconManager *manager) {
                return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
                    @strongify(self);
                    RACSignal *beaconSignal = [[[manager
                        rac_signalForSelector:@selector(locationManager:didRangeBeacons:inRegion:)
                        fromProtocol:@protocol(CLLocationManagerDelegate)]
                        filter:^BOOL(RACTuple *tuple) {
                            @strongify(self);
                            return [tuple.third isEqual:self];
                        }]
                        reduceEach:^(CLLocationManager *manager, NSArray *beacons, CLBeaconRegion *region) {
                            return beacons;
                        }];
                    
                    RACDisposable *disposable = [beaconSignal subscribe:subscriber];
                    
                    [manager.locationManager startRangingBeaconsInRegion:self];
                    
                    return [RACDisposable disposableWithBlock:^{
                        @strongify(self);
                        [manager.locationManager stopRangingBeaconsInRegion:self];
                        [disposable dispose];
                    }];
                }];
            }];
    }
    return self;
}

@end
