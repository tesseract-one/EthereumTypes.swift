Pod::Spec.new do |s|
  s.name             = 'TesseractEthereumBase'
  s.version          = '0.0.1'
  s.summary          = 'Tesseract Ethereum base definitions for Swift'

  s.description      = <<-DESC
Base classes and protocols for Ethereum support in Tesseract.
                       DESC

  s.homepage         = 'https://github.com/tesseract-one/swift-ethereum-base'

  s.license          = { :type => 'Apache 2.0', :file => 'LICENSE' }
  s.author           = { 'Tesseract Systems, Inc.' => 'info@tesseract.one' }
  s.source           = { :git => 'https://github.com/tesseract-one/swift-ethereum-base.git', :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/tesseract_one'

  s.ios.deployment_target = '8.0'

  s.module_name = 'EthereumBase'

  s.subspec 'Core' do |ss|
    ss.source_files = 'Sources/EthereumBase/**/*.swift'

    ss.dependency 'BigInt', '~> 3.1'
    ss.dependency 'CryptoSwift', '~> 0.15'
    ss.dependency 'SerializableValue', '~> 0.0.1'
  end

  s.subspec 'PromiseKit' do |ss|
    ss.source_files = 'Sources/PromiseKit/**/*.swift'

    ss.dependency 'TesseractEthereumBase/Core'
    ss.dependency 'PromiseKit/CorePromise', '~> 6.8.0'
  end

  s.default_subspecs = 'Core'
end
