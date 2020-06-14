require 'async/aws/all'

Async::Aws.configure(connection_limit: 4)

RSpec.describe Async::Aws do
  it "has a version number" do
    expect(Async::Aws::VERSION).not_to be nil
  end

  it "should list Async::Aws::HttpPlugin" do
    s3 = Aws::S3::Client.new
    handler_klass = s3.handlers.find do |handler|
      handler == Async::Aws::HttpHandler
    end
    expect(handler_klass).not_to be_nil
  end
end
