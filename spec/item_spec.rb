require 'spec_helper'

require './lib/item'

describe Todoable::Item do
  include_context "authenticated"
  include_context "todoable apis"

  before do
    @add_item_stub = stub_request(:post, "http://todoable.teachable.tech/api/lists/#{list_id}/items").
      with(
        body: {
          "item": {
            "name": item_block["name"]
          }
        }
      ).to_return(body: item_block.to_json)
  end

  it "should be able to add multiple items" do
    list.add_item(item_block["name"])
    list.add_item(item_block["name"])

    list.items.size.should == 2

    WebMock::RequestRegistry.instance.times_executed(@add_item_stub.request_pattern).should == 2
  end

  it "should be able to finish an item" do
    finish_stub = stub_request(:put, "http://todoable.teachable.tech/api/lists/#{list_id}/items/#{item_block[:id]}/finish").
    to_return(status: 200, body: "", headers: {})

    item = list.add_item(item_block["name"])

    item.finish

    WebMock::RequestRegistry.instance.times_executed(finish_stub.request_pattern).should == 1
  end

  it "should be able delete an item" do
    delete_stub = stub_request(:delete, "http://todoable.teachable.tech/api/lists/#{list_id}/items/#{item_block[:id]}").
    to_return(status: 200, body: "", headers: {})

    item = list.add_item(item_block["name"])

    item.delete

    WebMock::RequestRegistry.instance.times_executed(delete_stub.request_pattern).should == 1
  end
end
