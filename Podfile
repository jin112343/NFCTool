platform :ios, '15.0'

target 'NFC-Tools' do
  use_frameworks!

  pod 'SwiftyStoreKit', :inhibit_warnings => true
  pod 'Google-Mobile-Ads-SDK'
  pod 'EAIntroView', :inhibit_warnings => true
  pod 'FirebaseFirestore', :inhibit_warnings => true
  pod 'FirebaseCrashlytics', :inhibit_warnings => true

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

        # デバッグ情報: Debugはdwarf、Releaseはdwarf-with-dsym (Crashlytics用)
        if config.name == 'Debug'
          config.build_settings['DEBUG_INFORMATION_FORMAT'] = 'dwarf'
        else
          config.build_settings['DEBUG_INFORMATION_FORMAT'] = 'dwarf-with-dsym'
        end

        # 推奨設定: デッドコード除去
        config.build_settings['DEAD_CODE_STRIPPING'] = 'YES'

        # 重複リンカーフラグの排除 (-lc++ の重複警告対策)
        flags = config.build_settings['OTHER_LDFLAGS']
        if flags.is_a?(Array)
          config.build_settings['OTHER_LDFLAGS'] = flags.uniq
        elsif flags.is_a?(String)
          parts = flags.split(' ')
          config.build_settings['OTHER_LDFLAGS'] = parts.uniq.join(' ')
        end
      end

      # gRPC-Core の macro redefined 警告を抑制
      if ['gRPC-Core', 'gRPC-C++', 'BoringSSL-GRPC', 'abseil'].include?(target.name)
        target.build_configurations.each do |config|
          config.build_settings['GCC_WARN_INHIBIT_ALL_WARNINGS'] = 'YES'
        end
      end

      # "Create Symlinks to Header Folders" スクリプトフェーズの警告対策
      target.build_phases.each do |phase|
        if phase.is_a?(Xcodeproj::Project::Object::PBXShellScriptBuildPhase) &&
           phase.name == 'Create Symlinks to Header Folders'
          phase.always_out_of_date = '1'
        end
      end
    end

    # Pods プロジェクトレベルの推奨設定
    installer.pods_project.build_configurations.each do |config|
      config.build_settings['DEAD_CODE_STRIPPING'] = 'YES'
    end

    # リンカーの重複ライブラリ警告を抑制
    installer.aggregate_targets.each do |target|
      target.xcconfigs.each do |config_name, xcconfig|
        existing = xcconfig.attributes['OTHER_LDFLAGS'] || ''
        unless existing.include?('-Wl,-no_warn_duplicate_libraries')
          xcconfig.attributes['OTHER_LDFLAGS'] = "#{existing} -Wl,-no_warn_duplicate_libraries"
          xcconfig_path = target.xcconfig_path(config_name)
          xcconfig.save_as(xcconfig_path)
        end
      end
    end
  end
end
