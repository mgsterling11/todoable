require 'rspec'
require 'pry'
require 'webmock/rspec'

require './lib/list'
require './lib/item'

require 'todoable'

shared_context 'authenticated' do
  before do
    ENV['TODO_USER'] = 'faketest'
    ENV['TODO_PASSWORD'] = 'fakepass'
    ENV['TODO_TOKEN'] = 'fake_token'

    stub_request(:post, "http://todoable.teachable.tech/api/authenticate").to_return(body: "fake_token")

    Todoable.authenticate!
  end
end

shared_context 'todoable apis' do
  let(:list_name) { "test list"}
  let(:list) { Todoable::List.new(list_name, list_id, "fake source") }
  let(:list_id) { 'test_list_id'}

  let(:list_body) {
    {
      "name": list_name,
      "id": list_id,
      "source": "any_old_source"
    }
  }

  let(:item_block) {
    {
      "name": "item",
      "id": "item_id",
      "src": "item_src",
      "finished_at": nil
    }
  }

  before do
    stub_request(:post, "http://todoable.teachable.tech/api/lists").with(
      body: {
        "list": {
          "name": 'test list'
        }
      }
    ).to_return(body: list_body.to_json)

    stub_request(:get, "http://todoable.teachable.tech/api/lists/test_list_id").
     to_return(status: 200, body: {
       "name": "test list",
       "id": "test_list_id",
       "items": [
         item_block
       ]
    }.to_json)
  end
end
