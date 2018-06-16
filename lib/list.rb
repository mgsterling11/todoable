require 'httparty'
require_relative 'todoable'
require_relative 'item'

class Todoable::List
  RESOURCE_LOCATION = '/lists'.freeze

  attr_accessor :name, :id, :source, :items

  def initialize(name, id, source)
    @name = name
    @id = id
    @source = source
    @items = []
  end

  def self_link
    RESOURCE_LOCATION + "/#{@id}"
  end

  def update(new_name)
    list_body = {
      "list": {
        "name": new_name
      }
    }

    body = Todoable.patch(self_link, list_body)
    @name = body

    self
  end

  def delete
    Todoable.delete(self_link)
  end

  def get_items
    @items.clear

    Todoable.get(self_link + Todoable::Item::RESOURCE_LOCATION)
  end

  def add_item(name)
    item_body = {
      "item": {
        "name": name
      }
    }

    body = Todoable.post(self_link + Todoable::Item::RESOURCE_LOCATION, item_body)

    item = Todoable::Item.new(
      self,
      body["name"],
      body["id"],
      body["src"],
      body["finished_at"]
    )
    @items << item

    item
  end

  #### CLASS METHODS
  def self.create(name)
    list_body = {
      "list": {
        "name": name
      }
    }

    body = Todoable.post(RESOURCE_LOCATION, list_body)

    list = Todoable::List.new(
      body["name"],
      body["id"],
      body["source"]
    )
    list
  end

  def self.find(list_id)
    body = Todoable.get(RESOURCE_LOCATION + "/#{list_id}")

    list = Todoable::List.new(
      body['name'],
      list_id,
      nil
    )

    body["items"].each do |item|
      list.items << Todoable::Item.new(
        list,
        item["name"],
        item["id"],
        item["src"],
        item["finished_at"]
      )
    end

    list
  end

  def self.get_all_lists
    body = Todoable.get(RESOURCE_LOCATION)

    lists = body["lists"].map do |list|
      Todoable::List.new(
        list["name"],
        list["id"],
        list["source"]
      )
    end
    lists
  end

end
