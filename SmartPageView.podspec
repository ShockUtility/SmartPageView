#
# Be sure to run `pod lib lint SmartPageView.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'SmartPageView'
  s.version          = '0.1.0'
  s.summary          = 'A short description of SmartPageView.'
  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/ShockUtility/SmartPageView'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'ShockUtility' => 'shock@docs.kr' }
  s.source           = { :git => 'https://github.com/ShockUtility/SmartPageView.git', :tag => s.version.to_s }

  s.ios.deployment_target = '9.0'

  s.source_files = 'SmartPageView/Classes/**/*'
end
