require 'spec_helper'

require './lib/list'

describe Todoable::List do
  include_context "authenticated"
  include_context "todoable apis"

  it "should create a list" do
    list = Todoable::List.create(list_name)
    list.should_not be_nil

    list.name.should == list_name
  end

  describe "with a list already present" do
    it "should retrieve a list" do
      list.should_not be_nil
    end

    it "should update the list" do
      new_name = "new list name"

      request_body = {
        "list": {
          "name": new_name
        }
      }

      update_stub = stub_request(:patch, "http://todoable.teachable.tech/api/lists/#{list_id}").
      with(body: request_body.to_json).
      to_return(status: 200, body: "", headers: {})

      list.update(new_name)
    end

    it "should delete a list" do
      delete_stub = stub_request(:delete, "http://todoable.teachable.tech/api/lists/#{list_id}")

      list.delete

      WebMock::RequestRegistry.instance.times_executed(delete_stub.request_pattern).should == 1
    end

    it "should allow items to be posted to the list" do
      add_item_stub = stub_request(:post, "http://todoable.teachable.tech/api/lists/#{list_id}/items").
        with(
          body: {
            "item": {
              "name": item_block["name"]
            }
          }
        ).to_return(body: item_block.to_json)

      item = list.add_item(item_block["name"])

      item.should_not be_nil
      list.items.should include(item)

      WebMock::RequestRegistry.instance.times_executed(add_item_stub.request_pattern).should == 1
    end

  end

  it "should retrieve all lists" do
    all_lists_stub = stub_request(:get, "http://todoable.teachable.tech/api/lists").
    to_return(status: 200, body: {"lists": [list_body, list_body]}.to_json, headers: {})

    lists = Todoable::List.get_all_lists

    lists.size.should == 2

    WebMock::RequestRegistry.instance.times_executed(all_lists_stub.request_pattern).should == 1
  end

end
