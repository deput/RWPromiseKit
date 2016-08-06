Pod::Spec.new do |s|
  s.name             = "RWPromiseKit"
  s.version          = "0.2.0"
  s.license          = { :type => 'MIT' }
  s.summary          = "A light-weighted Promise library for Objective-C"
  s.description      = "A light-weighted Promise library for Objective-C"
  s.homepage         = "https://github.com/deput/RWPromiseKit"

  s.author           = { "deput" => "canopus4u@outlook.com" }
  s.source           = { :git => "https://github.com/deput/RWPromiseKit.git", :branch => "master"}

  s.platform         = :ios, '7.0'
  s.ios.deployment_target = '7.0'
  s.requires_arc     = true

  s.frameworks = 'Foundation'
  s.source_files  = "RWPromise/Class/**/*.{h,m}"

end