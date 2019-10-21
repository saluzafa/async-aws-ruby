require 'async/aws'

client_klasses = ObjectSpace.each_object(Class).select do |klass|
  klass < ::Seahorse::Client::Base
end
client_klasses.each do |klass|
  klass.add_plugin(Async::Aws::HttpPlugin)
end
