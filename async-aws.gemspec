lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "async/aws/version"

Gem::Specification.new do |spec|
  spec.name          = "async-aws"
  spec.version       = Async::Aws::VERSION
  spec.authors       = ["Julien D."]
  spec.email         = ["julien@unitylab.io"]

  spec.summary       = %q{Async AWS SDK adapter for `socketry/async` framework}
  spec.description   = %q{An Async AWS SDK adapter for `socketry/async` framework}
  spec.homepage      = 'https://github.com/runslash/async-aws-ruby'
  spec.license       = 'MIT'

  spec.metadata["allowed_push_host"] = 'https://rubygems.org'

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = 'https://github.com/runslash/async-aws-ruby'
  spec.metadata["changelog_uri"] = 'https://github.com/runslash/async-aws-ruby'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency 'async-http', '> 0.48'

  spec.add_development_dependency "bundler", "~> 2.0"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "aws-sdk-s3"
  spec.add_development_dependency "aws-sdk-dynamodb"
  spec.add_development_dependency "async"
end
