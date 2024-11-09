platform :ios, '15.0'

target 'NFC-Tools' do
  use_frameworks!
  
  pod 'SwiftyStoreKit'
  pod 'Google-Mobile-Ads-SDK'
  pod 'EAIntroView'

  post_install do |installer|
    installer.pods_project.targets.each do |target|
      target.build_configurations.each do |config|
        # アーキテクチャ設定
        config.build_settings['ARCHS'] = '${ARCHS_STANDARD}'
        config.build_settings['VALID_ARCHS'] = 'arm64'
        config.build_settings['EXCLUDED_ARCHS[sdk=iphonesimulator*]'] = ''
        
        # ビルド設定
        config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '15.0'
        config.build_settings['ENABLE_BITCODE'] = 'NO'
        config.build_settings['BUILD_LIBRARY_FOR_DISTRIBUTION'] = 'YES'
        
        # コード署名設定
        config.build_settings['CODE_SIGN_IDENTITY'] = ''
        config.build_settings['CODE_SIGNING_REQUIRED'] = 'NO'
        config.build_settings['CODE_SIGNING_ALLOWED'] = 'NO'
        
        # Swift設定
        config.build_settings['SWIFT_VERSION'] = '5.0'
        
        # 追加の設定
        config.build_settings['ONLY_ACTIVE_ARCH'] = 'YES'
        config.build_settings['DEBUG_INFORMATION_FORMAT'] = 'dwarf'
      end
    end
  end
end