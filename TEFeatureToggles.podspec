Pod::Spec.new do |s|
  s.name             = 'TEFeatureToggles'
  s.version          = '0.1.5'
  s.swift_versions   = '4.0'
  s.summary          = 'SDK for working with remote feature toggles.'
  s.description      = <<-DESC
TEFeatureToggles is an SDK for interacting with a microservice, allowing you to work with feature toggles of different projects in different environments.
                       DESC

  s.homepage         = 'https://github.com/True-Engineering/FeatureTogglesSDK_iOS'
  s.license          = { :type => 'Apache-2.0', :file => 'LICENSE' }
  s.authors          = { 'True Engineering' => 'cocoapods@trueengineering.ru' }
  s.source           = { :git => 'https://github.com/True-Engineering/FeatureTogglesSDK_iOS.git', :tag => s.version.to_s }

  s.ios.deployment_target = '13.0'

  s.source_files = 'FeatureToggles/**/*'
  s.dependency 'NetShears'
end
