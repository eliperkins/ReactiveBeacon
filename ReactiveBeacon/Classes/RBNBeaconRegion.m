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
        
        _presence = [[RACSignal
            defer:^{
                RACSignal *signal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
                    @weakify(self);
                    RACSignal *entranceSignal = [[[[self.manager
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

                    RACSignal *exitSignal = [[[[self.manager
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
                    RACSignal *currentSignal = [self.manager fetchPresenceForRegion:self];

                    RACDisposable *disposable = [[RACSignal
                        merge:@[ currentSignal, entranceSignal, exitSignal ]]
                        subscribe:subscriber];

                    // Lift errors out of the delegate callback
                    RACDisposable *failedDisposable = [[[self.manager
                        rac_signalForSelector:@selector(locationManager:monitoringDidFailForRegion:withError:)
                        fromProtocol:@protocol(CLLocationManagerDelegate)]
                        filter:^BOOL(RACTuple *tuple) {
                            @strongify(self);
                            return [tuple.second isEqual:self];
                        }]
                        subscribeNext:^(RACTuple *tuple) {
                            [subscriber sendError:tuple.third];
                        }];
                    
                    RACCompoundDisposable *compoundDisposable = [RACCompoundDisposable
                         compoundDisposableWithDisposables:@[disposable, failedDisposable]];

                    return [RACDisposable disposableWithBlock:^{
                        [compoundDisposable dispose];
                        [self.manager.scheduler schedule:^{
                            [self.manager.locationManager stopMonitoringForRegion:self];
                        }];
                    }];
                }];
                
                [self.manager.locationManager startMonitoringForRegion:self];
                
                return [[[signal
                    publish]
                    autoconnect]
                    deliverOn:self.manager.scheduler];
            }]
            setNameWithFormat:@"-presence proximityUUID: %@ identifier: %@", proximityUUID, identifier];
        
            _rangedBeacons = [[RACSignal defer:^RACSignal *{
                RACSignal *signal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
                    @weakify(self);
                    RACSignal *beaconSignal = [[[self.manager
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
                    
                    
                    return [RACDisposable disposableWithBlock:^{
                        [disposable dispose];

                        [self.manager.scheduler schedule:^{
                            [self.manager.locationManager stopRangingBeaconsInRegion:self];
                        }];
                    }];
                }];
                
                [self.manager.locationManager startRangingBeaconsInRegion:self];
                
                return [[[signal
                    publish]
                    autoconnect]
                    deliverOn:self.manager.scheduler];
            }]
            setNameWithFormat:@"-rangedBeacons proximityUUID: %@ identifier: %@", proximityUUID, identifier];
    }
    return self;
}

@end
