platform :ios, '7.0'

# ignore all warnings from all pods
inhibit_all_warnings!

target 'Aquaz' do
  source 'https://github.com/CocoaPods/Specs.git'
  source 'https://github.com/appodeal/CocoaPods.git'
  pod 'Appodeal', '~> 0.4.2'
  pod 'MMWormhole', '~> 1.2.0'
  pod 'Fabric'
  pod 'Crashlytics'
end

target 'Widget' do
  platform :ios, '8.0'
  pod 'MMWormhole', '~> 1.2.0'
  pod 'Fabric'
  pod 'Crashlytics'
end

target 'AquazTests' do
  platform :ios, '7.0'
  pod 'MMWormhole', '~> 1.2.0'
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['ENABLE_BITCODE'] = 'NO'
    end
  end
end