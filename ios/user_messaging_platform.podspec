Pod::Spec.new do |s|
  s.name             = 'user_messaging_platform'
  s.version          = '0.0.1'
  s.summary          = 'iOS implementation of the user_messaging_platform plugin.'
  s.homepage         = 'https://github.com/blaugold/user_messaging_platform'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Gabriel Terwesten' => 'gabriel@terwesten.net' }
  s.source           = { :path => '.' }
  s.platform         = :ios, '8.0'
  s.swift_version    = '5.0'
  s.source_files     = 'Classes/**/*'
  s.static_framework = true
  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }

  s.dependency 'Flutter'
  s.dependency 'GoogleUserMessagingPlatform', '~> 2.1'
end
