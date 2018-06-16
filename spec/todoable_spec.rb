require 'spec_helper'

describe Todoable do

  before do
    ENV['TODO_USER'] = nil
    ENV['TODO_PASSWORD'] = nil
    ENV['TODO_TOKEN'] = nil

    @authenticate_stub = stub_request(:post, "http://todoable.teachable.tech/api/authenticate").to_return(body: "fake_token")
  end

  it "should fail if nothing is set" do
    expect { Todoable.authenticate! }.to raise_error(RuntimeError)
  end


  it "should authenticate if PASSWORD and USER is set" do
    ENV['TODO_USER'] = 'faketest'
    ENV['TODO_PASSWORD'] = 'fakepass'

    Todoable.authenticate!

    WebMock::RequestRegistry.instance.times_executed(@authenticate_stub).should == 1
  end

  it "should not authenticate if TOKEN is set" do
    ENV['TODO_TOKEN'] = 'faketest'

    Todoable.authenticate!

    WebMock::RequestRegistry.instance.times_executed(@authenticate_stub).should == 0
  end
end
