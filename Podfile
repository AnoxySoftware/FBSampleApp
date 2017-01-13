source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '9.0'
use_frameworks!

def shared_pods
    pod 'Bolts'
    pod 'FBSDKCoreKit'
    pod 'FBSDKShareKit'
    pod 'FBSDKLoginKit'
end

target 'FBSampleApp' do
    shared_pods
    pod 'Kingfisher', '~> 3.0'
end

target 'FBSampleAppTests' do
    shared_pods
end
