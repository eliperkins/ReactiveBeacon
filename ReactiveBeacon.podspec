Pod::Spec.new do |s|
  s.name         = "ReactiveBeacon"
  s.version      = "0.0.1"
  s.summary      = "ReactiveCocoa bindings for iBeacon related activities"

  s.description  = <<-DESC
                   ReactiveCocoa bindings for iBeacon related activities, mainly for finding iBeacons nearby as a signal.
                   DESC

  s.homepage     = "http://github.com/eliperkins/ReactiveBeacon"

  s.author             = { "Eli Perkins" => "eli.j.perkins@gmail.com" }
  s.social_media_url   = "http://twitter.com/_eliperkins"

  s.ios.deployment_target = "6.0"

  s.requires_arc = true

  s.source        = { :git => "https://github.com/eliperkins/ReactiveBeacon.git", :tag => "0.0.1" }

  s.license       = 'MIT'

  s.source_files  = "Classes", "Classes/**/*.{h,m}"
  s.exclude_files = "Classes/Exclude"

  s.framework     = "CoreLocation"

  s.dependency "ReactiveCocoa", "~> 2.3.1"
end
