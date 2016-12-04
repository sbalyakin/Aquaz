platform :ios, '8.0'
use_frameworks!

# Ignore all warnings from all pods
# inhibit_all_warnings!

source 'https://github.com/CocoaPods/Specs.git'

def shared_pods
  pod 'Fabric'
  pod 'Crashlytics'
  pod 'MMWormhole', '~> 2.0.0'
end

# Aquaz Pro
target 'Aquaz Pro' do
  shared_pods
  pod 'SimulatorStatusMagic', :configurations => ['Debug']
end

target 'Aquaz Pro Widget' do
  shared_pods
end

#Aquaz
target 'Aquaz' do
  shared_pods
end

target 'Aquaz Widget' do
  shared_pods
end

# Temporary solution to remove warnings and errors in Storyboard editor (dlopen error)
post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['LD_RUNPATH_SEARCH_PATHS'] = ['$(inherited)', '/Applications/Xcode.app/Contents/Developer/Toolchains/Swift_2.3.xctoolchain/usr/lib/swift/iphonesimulator']
    end
  end
end
