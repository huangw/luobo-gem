$LOAD_PATH.unshift File.expand_path('../lib', __FILE__)
require 'luobo/version'

Gem::Specification.new 'luobo', Luobo::VERSION do |s|
  s.description       = "Luobo is a simple, easy to extend code generator."
  s.summary           = "Easy to extend code generator"
  s.authors           = ["Huang Wei"]
  s.email             = "huangw@pe-po.com"
  s.homepage          = "https://github.com/huangw/luobo-gem"
  s.executables       << "tuzi"
  s.files             = `git ls-files`.split("\n") - %w[.gitignore]
  s.test_files        = Dir.glob("{spec,test}/**/*.rb")
  s.rdoc_options      = %w[--line-numbers --inline-source --title Luobo --main README.rdoc --encoding=UTF-8]

  s.add_development_dependency 'rspec', '~> 2.5'
  s.add_dependency 'erubis'
end

