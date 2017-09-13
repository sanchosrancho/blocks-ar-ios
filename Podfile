platform :ios, '11.0'
use_frameworks!

target 'Modify' do
  pod 'Realm', :git => 'https://github.com/realm/realm-cocoa.git', :branch => 'master', submodules: true
  pod 'RealmSwift', :git => 'https://github.com/realm/realm-cocoa.git', :branch => 'master', submodules: true
  post_install do |installer|
      installer.pods_project.targets.each do |target|
          target.build_configurations.each do |config|
              config.build_settings['SWIFT_VERSION'] = '4.0'
          end
      end
  end
  pod 'Moya', :git => 'https://github.com/Moya/Moya.git', :branch => '10.0.0-dev'
  pod 'PromiseKit', '~> 4.4'
  pod 'Locksmith'
end
