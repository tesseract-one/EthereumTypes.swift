Pod::Spec.new do |s|
  s.name             = 'TesseractEthereumBase'
  s.version          = '0.0.1'
  s.summary          = 'Tesseract Ethereum base definitions for Swift'

  s.description      = <<-DESC
Base classes and protocols for Ethereum support in Tesseract.
                       DESC

  s.homepage         = 'https://github.com/tesseract.1/swift-ethereum-base'

  s.license          = { :type => 'Apache 2.0', :file => 'LICENSE' }
  s.author           = { 'Tesseract Systems, Inc.' => 'info@tesseract.one' }
  s.source           = { :git => 'https://github.com/tesseract.1/swift-ethereum-base.git', :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/tesseract_io'

  s.ios.deployment_target = '10.0'

  s.module_name = 'EthereumBase'

  s.source_files = 'Sources/EthereumBase/**/*.swift'

  s.dependency 'BigInt', '~> 3.1'
  s.dependency 'CryptoSwift', '~> 0.15'
end
