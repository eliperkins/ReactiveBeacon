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

@property (nonatomic, strong) RACScheduler *CBScheduler;

@end

@implementation RBNBeaconRegion

- (instancetype)initWithProximityUUID:(NSUUID *)proximityUUID identifier:(NSString *)identifier {
    self = [super initWithProximityUUID:proximityUUID identifier:identifier];
    if (self) {
        dispatch_queue_t queue = dispatch_queue_create("com.eliperkins.RBNBeaconRegion.CoreBluetoothQueue", DISPATCH_QUEUE_SERIAL);
        _CBScheduler = [[RACTargetQueueScheduler alloc] initWithName:@"com.eliperkins.RBNBeaconRegion.CoreBluetoothScheduler" targetQueue:queue];

        self.notifyOnExit = YES;
        self.notifyOnEntry = YES;
        self.notifyEntryStateOnDisplay = YES;
        
        _presence = [[[[RACSignal
            defer:^{
                RACSignal *signal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
                    RACSignal *entranceSignal = [[[[self.manager
                        rac_signalForSelector:@selector(locationManager:didEnterRegion:)
                        fromProtocol:@protocol(CLLocationManagerDelegate)]
                        reduceEach:^(CLLocationManager *manager, CLRegion *region){
                            return region;
                        }]
                        filter:^BOOL(CLRegion *enteredRegion) {
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
                            return [tuple.second isEqual:self];
                        }]
                        subscribeNext:^(RACTuple *tuple) {
                            [subscriber sendError:tuple.third];
                        }];

                    return [RACDisposable disposableWithBlock:^{
                        [disposable dispose];
                        [failedDisposable dispose];
                        [self.CBScheduler schedule:^{
                            [self.manager.locationManager stopMonitoringForRegion:self];
                        }];
                    }];
                }];
                [self.manager.locationManager startMonitoringForRegion:self];
                return signal;
            }]
            replayLazily]
            subscribeOn:self.CBScheduler]
            setNameWithFormat:@"-presence proximityUUID: %@ identifier: %@", proximityUUID, identifier];
        
            _rangedBeacons = [[RACSignal defer:^RACSignal *{
                RACSignal *signal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
                    RACSignal *beaconSignal = [[[self.manager
                        rac_signalForSelector:@selector(locationManager:didRangeBeacons:inRegion:)
                        fromProtocol:@protocol(CLLocationManagerDelegate)]
                        filter:^BOOL(RACTuple *tuple) {
                            return [tuple.third isEqual:self];
                        }]
                        reduceEach:^(CLLocationManager *manager, NSArray *beacons, CLBeaconRegion *region) {
                            return beacons;
                        }];
                    
                    RACDisposable *disposable = [beaconSignal subscribe:subscriber];
                    
                    return [RACDisposable disposableWithBlock:^{
                        [self.manager.locationManager stopRangingBeaconsInRegion:self];
                        [disposable dispose];
                    }];
                }];
                
                [self.manager.locationManager startRangingBeaconsInRegion:self];
                
                return signal;
            }]
            // TODO: make this multicast/replay to all subscribers
//            replayLazily]
            // TODO: make this scheduler not make things (specifically tests) puke
//            subscribeOn:self.CBScheduler]
            setNameWithFormat:@"-rangedBeacons proximityUUID: %@ identifier: %@", proximityUUID, identifier];
    }
    return self;
}

@end
