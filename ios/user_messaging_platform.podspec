Pod::Spec.new do |s|
  s.name             = 'user_messaging_platform'
  s.version          = '0.0.1'
  s.summary          = 'iOS implementation of the user_messaging_platform plugin.'
  s.homepage         = 'https://github.com/blaugold/user_messaging_platform'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Gabriel Terwesten' => 'gabriel@terwesten.net' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.platform = :ios, '8.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'

  s.dependency 'Google-Mobile-Ads-SDK'
end
