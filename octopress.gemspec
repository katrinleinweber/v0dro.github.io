# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'octopress/version'

Gem::Specification.new do |spec|
  spec.name          = "octopress"
  spec.version       = Octopress::VERSION
  spec.authors       = ["Brandon Mathis", "Parker Moore"]
  spec.email         = ["brandon@imathis.com", "parkrmoore@gmail.com"]
  spec.summary       = %q{Octopress is an obsessively designed framework for Jekyll blogging. It’s easy to configure and easy to deploy. Sweet huh?}
  spec.homepage      = "http://octopress.org"
  spec.license       = "MIT"

  # using ruby grep here in order to not have a depedency on grep cli tool. (mostly for windows machines)
  spec.files         = `git ls-files`.split("\n").grep(%r{^(bin\/|lib\/|assets\/|scaffold\/|site\/|local\/|changelog|readme|license)}i)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }

  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "mercenary", "~> 0.3.2"
  spec.add_runtime_dependency "sass-globbing"
  spec.add_runtime_dependency "jekyll-paginate"
  spec.add_runtime_dependency "compass"
  spec.add_runtime_dependency "jekyll", ">= 2.0"
  spec.add_runtime_dependency "titlecase"
  spec.add_runtime_dependency "octopress-deploy"
  spec.add_runtime_dependency "octopress-image-tag"
  spec.add_runtime_dependency "octopress-escape-code", "~> 2.0"
  spec.add_runtime_dependency "rack"
  spec.add_runtime_dependency "sinatra"
  spec.add_runtime_dependency "pygments.rb"
  spec.add_runtime_dependency "jekyll-sitemap"
  spec.add_runtime_dependency "stringex"  
  spec.add_runtime_dependency "haml"
  spec.add_runtime_dependency "kramdown"
  spec.add_runtime_dependency "coderay"
  spec.add_runtime_dependency "therubyracer"


  spec.add_development_dependency "octopress-ink"
  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "clash"

  if RUBY_VERSION >= "2"
    spec.add_development_dependency "pry-byebug"
  end
end

