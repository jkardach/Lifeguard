platform :ios, '8.0'

target 'Lifeguard' do
    pod 'GoogleAPIClientForREST/Sheets', '~> 1.1.1'
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
