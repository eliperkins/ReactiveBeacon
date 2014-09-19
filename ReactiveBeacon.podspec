Pod::Spec.new do |s|
  s.name         = "ReactiveBeacon"
  s.version      = "0.2.0"
  s.summary      = "ReactiveCocoa bindings for iBeacon related activities"
  s.description  = <<-DESC
                   ReactiveCocoa bindings for iBeacon related activities, mainly for finding iBeacons nearby as a signal.
                   DESC
  s.homepage     = "http://github.com/eliperkins/ReactiveBeacon"
  s.author             = { "Eli Perkins" => "eli.j.perkins@gmail.com" }
  s.social_media_url   = "http://twitter.com/_eliperkins"
  s.platform     = :ios, '7.0'
  s.requires_arc = true
  s.source        = { :git => "https://github.com/eliperkins/ReactiveBeacon.git", :tag => s.version.to_s }
  s.license       = 'MIT'
  s.source_files  = 'ReactiveBeacon/Classes'
  s.framework     = "CoreLocation"
  s.dependency "ReactiveCocoa", "~> 2.3.1"
end
