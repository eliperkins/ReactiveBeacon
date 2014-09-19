# ReactiveBeacon
[![Build Status](http://img.shields.io/travis/eliperkins/ReactiveBeacon.svg?style=flat)](https://travis-ci.org/eliperkins/ReactiveBeacon)
[![Coverage](http://img.shields.io/coveralls/eliperkins/ReactiveBeacon.svg?style=flat)](https://coveralls.io/r/eliperkins/ReactiveBeacon?branch=master)
[![Version](http://img.shields.io/cocoapods/v/ReactiveBeacon.svg?style=flat)](http://cocoadocs.org/docsets/ReactiveBeacon)
[![Documentation](http://img.shields.io/cocoapods/p/ReactiveBeacon.svg?style=flat)](http://cocoadocs.org/docsets/ReactiveBeacon)

ReactiveCocoa bindings for iBeacon activities, mainly monitoring and ranging.

## Usage

* Add `pod 'ReactiveBeacon', '~> 0.2.0'` to your Podfile
* `pod install`
* `#import <ReactiveBeacon/ReactiveBeacon.h>`

### Monitoring

There are two main methods to monitoring beacon regions.

`-fetchPresenceForRegion:` will give you the current state of the device in a region. This method will send the `@YES` or `@NO` only once and complete. This can be useful for an immediate query on a region.

`-presenceForRegion:` will give you a signal that will return entrance and exits from a region. Entrances will be marked as `@YES`, exits as `@NO`.

### Ranging

To range for beacons, listen on the property `beaconsInRange`. This will return all `CLBeacons` that are currently in range for the device.

## License

ReactiveBeacon is published under the MIT License.

![analytics](https://ga-beacon.appspot.com/UA-47801301-3/ReactiveBeacon/README?pixel)
