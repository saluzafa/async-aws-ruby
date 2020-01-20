require 'async/aws/all'

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

  it 'should send an async request to AWS' do
    Async::Reactor.run do |reactor|
      tasks = 10.times.collect do
        s3 = Aws::S3::Client.new
        Async do
          bench = Async::Clock.measure do
            result = s3.list_buckets
            expect(result.is_a?(Seahorse::Client::Response)).to be(true)
          end
        end
      end

      tasks.each(&:wait)
    end
  end

  it 'should work with DynamoDB' do
    Async::Reactor.run do |reactor|
      task = Async do
        dynamo = Aws::DynamoDB::Client.new
        dynamo.get_item(
          table_name: 'test',
          key: { pk: 'test' }
        )
      end

      task.wait
    end
  end
end
