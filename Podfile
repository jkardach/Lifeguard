platform :ios, '13.0'

target 'Lifeguard' do
    pod 'GoogleAPIClientForREST/Sheets', '~> 1.1.1'
    pod 'GoogleAPIClientForREST/Calendar'
    pod 'Particle-SDK'
    pod 'GoogleSignIn'
end
post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['CLANG_WARN_DOCUMENTATION_COMMENTS'] = 'NO'
        end
    end
end
