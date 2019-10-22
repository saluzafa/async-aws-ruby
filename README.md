# Async::Aws

[![Gem Version](https://badge.fury.io/rb/async-aws.svg)](https://badge.fury.io/rb/async-aws)

An experimental HTTP handler for AWS SDK Ruby powered by `socketry/async-http`.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'async-aws'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install async-aws

## Usage

### Method 1
Simply require `async/aws/all` after requiring all your `aws-sdk-*` gem. It will automatically add `Async::Aws::HttpPlugin` to all `aws-sdk-*` clients.

### Method 2
Add `Async::Aws::HttpPlugin` to your `Aws::*::Client` classes.
Example:
```ruby
Aws::S3::Client.add_plugin(Async::Aws::HttpPlugin)
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/runslash/async-aws-ruby. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Async::Aws project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/runslash/async-aws-ruby/blob/master/CODE_OF_CONDUCT.md).
