Pod::Spec.new do |s|
  s.name         = "ReactiveBeacon"
  s.version      = "0.0.1"
  s.summary      = "ReactiveCocoa bindings for iBeacon related activities"

  s.description  = <<-DESC
                   ReactiveCocoa bindings for iBeacon related activities
                   DESC

  s.homepage     = "http://github.com/eliperkins/ReactiveBeacon"

  s.author             = { "Eli Perkins" => "eli@onemightyroar.com" }
  s.social_media_url   = "http://twitter.com/Eli Perkins"

  s.ios.deployment_target = "6.0"
  s.osx.deployment_target = "10.8"

  s.source       = { :git => "http://github.com/eliperkins/ReactiveBeacon", :tag => "0.0.1" }

  s.source_files  = "Classes", "Classes/**/*.{h,m}"
  s.exclude_files = "Classes/Exclude"

  s.framework  = "CoreLocation"

  s.dependency "ReactiveCocoa", "~> 2.3.1"
end
