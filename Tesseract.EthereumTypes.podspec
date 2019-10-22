Pod::Spec.new do |s|
  s.name             = 'Tesseract.EthereumTypes'
  s.version          = '0.1.11'
  s.summary          = 'Tesseract Platform Ethereum types and definitions for Swift'

  s.description      = <<-DESC
Base types, definitions and protocols for Ethereum support in Tesseract Platform Swift SDK.
                      DESC

  s.homepage         = 'https://github.com/tesseract-one/EthereumTypes.swift'

  s.license          = { :type => 'Apache 2.0', :file => 'LICENSE' }
  s.author           = { 'Tesseract Systems, Inc.' => 'info@tesseract.one' }
  s.source           = { :git => 'https://github.com/tesseract-one/EthereumTypes.swift.git', :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/tesseract_one'

  s.ios.deployment_target = '8.0'
  s.osx.deployment_target = '10.10'
  s.tvos.deployment_target = '9.0'
  s.watchos.deployment_target = '2.0'

  s.module_name = 'Ethereum'

  s.source_files = 'Sources/Ethereum/**/*.swift'

  s.swift_versions = ['5.0']

  s.dependency 'BigInt', '~> 5.0.0'
  s.dependency 'CryptoSwift', '~> 1.0.0'
  s.dependency 'Serializable.swift', '~> 0.1.0'
end
