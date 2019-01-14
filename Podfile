source 'https://github.com/appodeal/CocoaPods.git'
source 'https://github.com/CocoaPods/Specs.git'

# Ignore all warnings from all pods
# inhibit_all_warnings!

platform :ios, '9.0'
use_frameworks!

def shared_pods
  pod 'Fabric'
  pod 'Crashlytics'
  pod 'MMWormhole', '~> 2.0.0'
end

# AquazPro
target 'AquazPro' do
  shared_pods
  pod 'SimulatorStatusMagic', :configurations => ['Debug']
end

target 'AquazPro Widget' do
  shared_pods
end

# Aquaz
target 'Aquaz' do
  shared_pods
  pod 'Appodeal/Video', '2.4.10'
end

target 'Aquaz Widget' do
  shared_pods
end
