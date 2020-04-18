
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "foucault_http/version"

Gem::Specification.new do |spec|
  spec.name          = "foucault_http"
  spec.version       = FoucaultHttp::VERSION
  spec.authors       = ["Col Perks"]
  spec.email         = ["wild.fauve@gmail.com"]

  spec.summary       = %q{Http Network Functions}
  spec.description   = %q{Http Network Functions.}
  spec.homepage      = "https://github.com/wildfauve/foucault_http"
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    # spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency 'stoplight'
  spec.add_dependency 'dry-monads', "~> 1.0"
  spec.add_dependency 'dry-configurable'
  spec.add_dependency 'funcify'
  spec.add_dependency 'typhoeus'
  spec.add_dependency 'faraday', '~> 1.0'
  spec.add_dependency "dry-types"
  spec.add_dependency "dry-struct"

  spec.add_development_dependency "bundler", "~> 2.0"
  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "pry"
end
