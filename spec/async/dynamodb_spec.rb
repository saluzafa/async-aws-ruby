require 'async/aws/all'

Async::Aws.configure(connection_limit: 4)

RSpec.describe Async::Aws do
  it 'should execute dynamodb:GetItem action' do
    Async::Reactor.run do |reactor|
      task = Async do
        dynamo = Aws::DynamoDB::Client.new
        result = dynamo.get_item(
          table_name: 'async-aws-rspec',
          key: { pk: 'test' }
        )
        expect(result.data).to be_kind_of(Aws::DynamoDB::Types::GetItemOutput)
      end

      task.wait
    end
  end
end
