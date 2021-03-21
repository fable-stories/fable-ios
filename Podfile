ENV["COCOAPODS_DISABLE_STATS"] = "true"
$useStaticFrameworks = ENV['COCOAPODS_USE_STATIC_FRAMEWORKS'] == 'true'

platform :ios, '13.0'
install! 'cocoapods', :deterministic_uuids => false
inhibit_all_warnings!

if !$useStaticFrameworks
  use_frameworks!
  puts "Installing Pods as dynamic frameworks"
end

install! 'cocoapods', :integrate_targets => true

def alamofire
  pod 'Alamofire', '~> 5.0.4'
end

def texture
  pod 'Texture', '3.0.0'
end

def reactiveswift
  pod 'ReactiveSwift',  '~> 6.3.0'
end

def kingfisher
  pod 'Kingfisher', '~> 5.13.2'
end

def reactivecocoa
  pod 'ReactiveCocoa', '~> 10.1.0'
end

def keychainaccess
  pod 'KeychainAccess', '~> 4.2.1'
end

def firebolt 
  pod 'Firebolt', '~> 0.4.6'
end


def markdown
  pod 'Down'
end

def googlesignin
  googleutilities
  pod 'GoogleSignIn'
end

def googleutilities
  pod 'GTMSessionFetcher'
end

def core
  alamofire
  kingfisher
  reactiveswift
  reactivecocoa
  # snapkit
  firebolt
  texture
end

def firebase 
  googleutilities
  pod 'Firebase/Crashlytics'
  pod 'Firebase/Analytics'
  pod 'Firebase/Performance'
  pod 'Firebase/Messaging'
  pod 'Firebase/Core'
  pod 'Firebase/Auth'
end

def realm
  pod 'RealmSwift'
end

def papertrail
  pod "PaperTrailLumberjack/Swift"
end

def lottie
  pod 'lottie-ios'
end

def texture
  pod "Texture"
end

target 'Fable' do 
  core
  markdown
  lottie
  keychainaccess
  texture
  firebase
  googlesignin
  papertrail
end

target 'FableTests' do 
  core
end

target 'ShellApp' do 
  core
  markdown
  lottie
  keychainaccess
  texture
  firebase
  googlesignin
end

target 'AppFoundation' do 
  reactiveswift
  reactivecocoa
  texture
end

target 'AppUIFoundation' do 
  reactiveswift
  reactivecocoa
  texture
  # snapkit
end

target 'NetworkFoundation' do 
  alamofire
  reactiveswift
end

target 'ReactiveFoundation' do 
  reactiveswift
  reactivecocoa
end

target 'Interface' do 
  firebase
end

# target 'RealmManager' do 
#   core
# end

# -- Fable SDK --

target 'FableSDKResolver' do 
  firebolt
  reactiveswift
  reactivecocoa
  firebase
end

target 'FableSDKViews' do 
  kingfisher
  reactiveswift
  reactivecocoa
  lottie
  texture
end

target 'FableSDKModelObjects' do 
  reactiveswift
end

target 'FableSDKViewControllers' do 
  kingfisher
  reactiveswift
  reactivecocoa
  # snapkit
  markdown
  texture
end

target 'FableSDKViewPresenters' do 
  reactiveswift
  reactivecocoa
end

target 'FableSDKModelPresenters' do 
  reactiveswift
end

target 'FableSDKModelManagers' do 
  firebase
  reactiveswift
  kingfisher
  keychainaccess
  firebolt
  googlesignin
  papertrail
end

target 'FableSDKResourceManagers' do 
  alamofire
  reactiveswift
end

pre_install do |installer|
  installer.pod_targets.each do |target|
    target.root_spec.swift_version = '5.1.2'
    if $useStaticFrameworks 
      puts "Building #{target.name} as static framework"
      def target.build_type;
        Pod::BuildType.static_framework
      end
    end
  end
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['SWIFT_VERSION'] = '5.1.2'
      config.build_settings['ALWAYS_EMBED_SWIFT_STANDARD_LIBRARIES'] = 'NO'
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = 11.0
      # config.build_settings['BUILD_LIBRARY_FOR_DISTRIBUTION'] = 'YES'
      if config.name == 'Debug'
        config.build_settings['OTHER_SWIFT_FLAGS'] = ['$(inherited)', '-Onone']
        config.build_settings['SWIFT_OPTIMIZATION_LEVEL'] = '-Owholemodule'
      end
    end
  end
end
