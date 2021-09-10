Pod::Spec.new do |s|
s.name         = 'KryAppOrderFiles'
s.version      = '1.0.0'
s.summary      = 'Generating order files for Mach-O using Clang SanitizerCoverages.'
s.description  = <<-DESC
The easiest way to generate order files for Mach-O using Clang SanitizerCoverage. Improving App Performance.
DESC
s.homepage     = 'https://github.com/yulingtianxia/AppOrderFiles'

s.license = { :type => 'MIT', :file => 'LICENSE' }
s.author       = { 'krystal' => 'q491964334@icloud.com' }
s.source       = { :git => 'https://github.com/krystal1110/KryAppOrderFiles.git', :tag => s.version.to_s }

s.source_files = 'KryAppOrderFiles/KryAppOrderFiles/*.{h,m}'
s.public_header_files = 'KryAppOrderFiles/KryAppOrderFiles/*.h'

s.ios.deployment_target = '9.0'
s.osx.deployment_target = '10.8'
s.tvos.deployment_target = '9.0'
s.watchos.deployment_target = '2.0'
s.requires_arc = true
end

