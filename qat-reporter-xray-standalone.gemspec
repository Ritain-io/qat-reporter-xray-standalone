#encoding: utf-8
# require File.expand_path(File.join(File.dirname(__FILE__), 'lib', 'qat', 'version.rb'))
require "qat/reporter/xray/version"

Gem::Specification.new do |gem|
  gem.name        = 'qat-reporter-xray-standalone'
  gem.version     = QAT::Reporter::Xray::VERSION
  gem.summary     = %q{Utility for Test Reports in Jira Xray.}
  gem.description = <<-DESC
  QAT Report Xray Standalone belongs to QAT Report collection but stand alone version, so no dependencies from other
  QAT gems are required.
  DESC
  gem.email    = 'qatoolkit@readinessit.com'
  gem.homepage = 'https://www.ritain.io'
  gem.metadata    = {
      'source_code_uri'   => 'https://github.com/Ritain-io/qat-reporter-xray-standalone'
  }
  gem.authors = ['QAT']
  gem.license = 'GPL-3.0'

  extra_files = %w[LICENSE]
  gem.files   = Dir.glob('{lib}/**/*') + extra_files

  gem.required_ruby_version = '~> 3.1'

  # Development dependencies
  gem.add_development_dependency 'vcr', '~> 5.0', '>= 5.0.0'
  gem.add_development_dependency 'webmock', '~> 3.6', '>= 3.6.0'
  gem.add_development_dependency 'aruba', '~> 0.14', '>= 0.14.9'

  # GEM dependencies
  gem.add_dependency 'rest-client'
  gem.add_dependency 'rubyzip'

end
