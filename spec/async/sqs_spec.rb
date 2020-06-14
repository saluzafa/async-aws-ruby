require 'async/aws/all'

Async::Aws.configure(connection_limit: 4)

RSpec.describe Async::Aws do
  it 'should execute sqs:ListQueues action' do
    Async::Reactor.run do
      task = Async do
        sqs = Aws::SQS::Client.new
        result = sqs.list_queues
        expect(result.data).to be_kind_of(Aws::SQS::Types::ListQueuesResult)
      end

      task.wait
    end
  end
end
