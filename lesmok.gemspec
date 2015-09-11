# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'lesmok/version'

Gem::Specification.new do |spec|
  spec.name          = "lesmok"
  spec.version       = Lesmok::VERSION
  spec.authors       = ["Sixty AS", "Kent Dahl"]
  spec.email         = ["info@sixty.no", "kent@sixty.no"]
  spec.summary       = %q{Liquid ExtentionS for MOre Komfort}
  spec.description   = %q{Collection of utility classes, tags etc for use with the Liquid templating system.}
  spec.homepage      = "https://github.com/sixtyno/lesmok"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency 'liquid'
  spec.add_runtime_dependency 'activesupport'

  spec.add_development_dependency "bundler", "~> 1.5"
  spec.add_development_dependency "rake", "~>0"


  spec.add_development_dependency 'rspec', '~>3.0'

end
