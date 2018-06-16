require 'httparty'

module Todoable
  class ValidationError < StandardError; end;
  class NotAuthenticatedError < StandardError; end;
  class NotFoundError < StandardError; end;

  BASE_URL = 'http://todoable.teachable.tech/api'.freeze

  AUTH_RESOURCE = '/authenticate'.freeze

  def self.authenticate!
    if (!ENV['TODO_USER'] || !ENV['TODO_PASSWORD']) && !ENV['TODO_TOKEN']
      raise "Environmental variables TODO_USER and TODO_PASSWORD or just TODO_TOKEN must be set"
    end

    if ENV['TODO_TOKEN']
      return @token = ENV['TODO_TOKEN']
    end

    result = HTTParty.post(
      BASE_URL + AUTH_RESOURCE,
      :basic_auth => {
        :username => ENV['TODO_USER'],
        :password => ENV['TODO_PASSWORD']
      },
      :headers => {
        'Content-Type' => 'application/json',
        'Accept' => 'application/json'
      }
    )

    handle_response(result)

    puts "Got new token with credentials, please set to TODO_TOKEN: #{result["token"]}"

    @token = result["token"]
  end

  def self.common_headers
    if !@token
      raise "Not authenticated, please authenticate!"
    end

    return {
      'Content-Type' => 'application/json',
      'Accept' => 'application/json',
      'Authorization' => "Token token=#{@token}"
    }
  end

  # necessary to define static methods on module
  def self.create_method(name, &block)
    self.class.send(:define_method, name, &block)
  end

  ['get', 'delete'].each do |method|
    self.create_method(method) do |resource|
      result = HTTParty.method(method).call(
        BASE_URL + resource,
        :headers => common_headers
      )

      handle_response(result)

      begin
        JSON.load(result.body)
      rescue JSON::ParserError
        result.body
      end
    end
  end

  ['post', 'patch', 'put'].each do |method|
    self.create_method(method) do |resource, body|
      result = HTTParty.method(method).call(
        BASE_URL + resource,
        :headers => common_headers,
        :body => body.to_json
      )

      handle_response(result)

      begin
        JSON.load(result.body)
      rescue JSON::ParserError
        result.body
      end
    end
  end


  def self.handle_response(response)
    if response.code == 422
      raise ValidationError.new("Validation error with error response #{response.body}")
    elsif response.code == 401
      raise NotAuthenticatedError.new("Authentication failed, please re-authenticate!")
    elsif response.code == 404
      raise NotFoundError.new("Object not found")
    end
  end
end
