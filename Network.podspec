Pod::Spec.new do |s|
  s.name             = 'Network'
  s.version          = '0.1.0'
  s.summary          = 'Network with object mapping and request queue.'

  s.description      = <<-DESC
Network with object mapping and muti task queue.
                       DESC

  s.homepage         = 'https://github.com/WildDylan/Network'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Dylan' => 'dylan@china.com' }
  s.source           = { :git => 'https://github.com/WildDylan/Network.git', :tag => s.version.to_s }

  s.ios.deployment_target = '8.0'

  s.source_files = 'Network/**/*.swift'

  s.frameworks = 'UIKit', 'Foundation'
  s.dependency 'ObjectMapper', '~> 2.2.1'
  s.dependency 'Alamofire', '~> 4.1.0'
end
