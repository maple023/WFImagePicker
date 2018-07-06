@version = '0.0.3'
Pod::Spec.new do |s|
s.name = 'WFImagePicker'
s.version = @version
s.summary = "第一个版本"
s.description = "可以用到项目中 稳定版本"
s.homepage = 'https://github.com/maple023/WFImagePicker'
s.license = { :type => 'MIT', :file => 'LICENSE' }
s.author = { 'maple023' => 'xuwenfeng023@163.com' }
s.ios.deployment_target = '9.0'
s.source = { :git => 'https://github.com/maple023/WFImagePicker.git', :tag => "v#{s.version}" }

s.requires_arc = true
s.framework = "Foundation","UIKit","Photos"
s.dependency 'MLeaksFinder'

s.source_files = 'WFImagePicker/WFImagePicker/**/*.swift'
s.resource_bundles = {
   'WFImagePicker' => ['WFImagePicker/WFImagePicker/**/*.png']
}

end
