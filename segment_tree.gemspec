# -*- encoding: utf-8 -*-
require File.expand_path('../lib/segment_tree/version', __FILE__)

Gem::Specification.new do |gem|
  gem.author        = "Alexei Mikhailov"
  gem.email         = "amikhailov83@gmail.com"
  gem.description   = %q{Tree data structure for storing segments. It allows querying which of the stored segments contain a given point.}
  gem.summary       = %q{Tree data structure for storing segments. It allows querying which of the stored segments contain a given point.}
  gem.homepage      = "https://github.com/take-five/segment_tree"

  gem.files         = `git ls-files`.split($\).grep(/lib|spec/)
  gem.test_files    = gem.files.grep(/spec/)
  gem.name          = "segment_tree"
  gem.require_paths = %W(lib)
  gem.version       = SegmentTree::VERSION

  gem.add_development_dependency "bundler", ">= 1.0"
  gem.add_development_dependency "rspec", ">= 2.11"
end
