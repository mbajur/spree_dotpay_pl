# encoding: UTF-8
version = File.read(File.expand_path("../GEM_VERSION",__FILE__)).strip

Gem::Specification.new do |s|
  s.platform    = Gem::Platform::RUBY
  s.name        = 'spree_dotpay_pl'
  s.version     = version
  s.summary     = 'Spree extension for integration with Dotpay.pl payments'
  s.description = 'Spree extension for integration with Dotpay.pl payments'

  s.required_ruby_version     = '>= 2.1.0'
  s.required_rubygems_version = '>= 1.8.23'

  s.author            = 'Tomasz Stachewicz'
  s.email             = 'tomekrs@o2.pl'
  s.homepage          = 'http://github.com/tomash/spree_dotpay_pl'

  s.files        = Dir['CHANGELOG', 'README.md', 'LICENSE', 'lib/**/*', 'app/**/*']
  s.require_path = 'lib'
  s.requirements << 'none'

  spree_version = '~> 3.1.0.beta'

  s.add_dependency 'spree_core', spree_version

  s.add_development_dependency 'spree_backend', spree_version
  s.add_development_dependency 'spree_frontend', spree_version
  s.add_development_dependency 'sqlite3'

end
