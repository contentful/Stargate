Pod::Spec.new do |s|
  s.name             = "Stargate"
  s.version          = "0.0.1"
  s.summary          = "A communication channel from your Mac to your watch."
  s.homepage         = "https://github.com/contentful-labs/Stargate/"
  s.social_media_url = 'https://twitter.com/contentful'

  s.license = {
    :type => 'MIT',
    :file => 'LICENSE'
  }

  s.authors      = { "Boris Bügling" => "boris@buegling.com" }
  s.source       = { :git => "https://github.com/contentful-labs/Stargate.git",
                     :tag => s.version.to_s }
  s.requires_arc = true

  s.ios.deployment_target = '8.0'
  s.osx.deployment_target = '10.10'

  s.source_files = 'Code/*.swift'

  s.dependency 'MMWormhole', '~> 1.1'
  s.dependency 'PeerKit', '~> 1.1'
end
