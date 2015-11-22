platform :ios, '7.1'

# ignore all warnings from all pods
inhibit_all_warnings!

source 'https://github.com/CocoaPods/Specs.git'
source 'https://github.com/appodeal/CocoaPods.git'

target 'Aquaz' do
  pod 'TOWebViewController'
  pod 'Appodeal', '~> 0.5'
  pod 'AppLovin', '~> 3.1.6'
  pod 'Fabric'
  pod 'Crashlytics'
  pod 'MMWormhole', '~> 2.0.0'
  pod 'SimulatorStatusMagic', :configurations => ['Debug']
end

target 'AquazTests' do
  pod 'MMWormhole', '~> 2.0.0'
end

target 'Widget' do
  platform :ios, '8.0'
  pod 'Fabric'
  pod 'Crashlytics'
  pod 'MMWormhole', '~> 2.0.0'
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['ENABLE_BITCODE'] = 'NO'
      config.build_settings['CLANG_ENABLE_MODULES'] = 'YES'
      config.build_settings['GCC_PRECOMPILE_PREFIX_HEADER'] = 'NO'
      
      if config.name == "Debug" then
        config.build_settings['DEBUG_INFORMATION_FORMAT'] = 'dwarf'
      elsif config.name == "Release" then
        config.build_settings['DEBUG_INFORMATION_FORMAT'] = 'dwarf-with-dsym'
      end
    end
  end
end