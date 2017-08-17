Pod::Spec.new do |s|
  s.name         = "FeathersSwiftSocketIO"
  # Version goes here and will be used to access the git tag later on, once we have a first release.
  s.version      = "3.1.2"
  s.summary      = "SocketIO provider for FeathersSwift"
  s.description  = <<-DESC
                   SocketIO provider for FeathersSwift for making real-time connections to a
                   FeathersJS backend.
                   DESC
  s.homepage     = "https://github.com/feathersjs/feathers-swift-socketio"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author       = "startupthekid"

  s.ios.deployment_target = "8.0"
  s.osx.deployment_target = "10.10"
  s.tvos.deployment_target = "9.0"
  s.source       = { :git => "https://github.com/feathersjs/feathers-swift-socketio.git", :tag => "#{s.version}" }

  s.default_subspec = "Core"

  s.subspec "Core" do |ss|
    ss.source_files = "FeathersSwiftSocketIO/Core/*.{swift}"
    ss.framework = "Foundation"
    ss.dependency 'Result'
    ss.dependency 'Feathers'
    ss.dependency 'Socket.IO-Client-Swift'
  end

  s.pod_target_xcconfig = {"OTHER_SWIFT_FLAGS[config=Release]" => "-suppress-warnings" }
end
