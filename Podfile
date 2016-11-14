platform :ios, '8.0'
use_frameworks!

# Ignore all warnings from all pods
inhibit_all_warnings!

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
