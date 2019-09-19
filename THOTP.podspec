Pod::Spec.new do |spec|
  spec.name = 'THOTP'
  spec.version = '1.0.0'
  spec.summary = "Pure Swift implementation of time-based and HMAC-based one-time password generators. Heavily inspired by the OneTimePassword library from @mattrubin."

  spec.homepage = 'https://github.com/ericlewis/THOTP'
  spec.license = { :type => 'MIT', :file => 'LICENSE.md' }

  spec.author = { 'Eric Lewis' => 'ericlewis777@gmail.com' }
  spec.social_media_url = 'https://twitter.com/ericlewis'

  spec.static_framework = true
  
  spec.ios.deployment_target = '13.0'
  spec.tvos.deployment_target = '13.0'
  spec.watchos.deployment_target = '6.0'
  spec.macos.deployment_target = '10.15'

  spec.swift_version = '5.1'

  spec.source = { :git => "https://github.com/ericlewis/THOTP.git", :tag => "#{spec.version}" }
  spec.source_files = 'Sources/**/*'

  spec.frameworks = 'CryptoKit'
end
