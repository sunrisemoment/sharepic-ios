# Uncomment this line to define a global platform for your project
# platform :ios, '9.0'

target 'sharepic' do
  # Comment this line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

  # Pods for sharepic
  pod 'Firebase/Auth'
  pod 'IQKeyboardManagerSwift'
  pod 'Firebase/Database'
  pod 'Firebase/Storage'
  pod 'Firebase'
  pod 'Firebase/Messaging'
  pod 'Firebase/AdMob'
  pod 'GoogleSignIn'
  pod 'FMDB', '~> 2.6'
  pod 'FBSDKCoreKit', '~> 4.16'
  pod 'FBSDKShareKit', '~> 4.16'
  pod 'FBSDKLoginKit', '~> 4.16'

end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['SWIFT_VERSION'] = '3.0'
    end
  end
end
