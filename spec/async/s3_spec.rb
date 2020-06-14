require 'async/aws/all'

Async::Aws.configure(connection_limit: 4)

RSpec.describe Async::Aws do
  it 'should execute s3:ListBuckets action' do
    Async::Reactor.run do
      s3 = Aws::S3::Client.new

      task = Async do
        result = s3.list_buckets
        expect(result.data).to be_kind_of(Aws::S3::Types::ListBucketsOutput)
      end

      task.wait
    end
  end
end
