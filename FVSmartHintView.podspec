Pod::Spec.new do |s|
  s.name             = 'FVSmartHintView'
  s.version          = '0.1.0'
  s.summary          = 'A easy way to add an smart hint view that display frequently-used phrase'
  s.description      = 'A smart hint table view to display frequently-used that you provide throught impletement protocal'
  s.homepage         = 'https://github.com/Upliver/FVSmartHintView'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'iforvert' => 'iforvert@gmail.com' }
  s.source           = { :git => 'https://github.com/Upliver/FVSmartHintView.git', :tag => s.version.to_s }
  s.ios.deployment_target = '8.0'
  s.source_files = 'FVSmartHintView/**/*.{h,m}'
  s.dependency 'Masonry', '~> 1.0.2'
end
