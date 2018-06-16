require_relative 'todoable'

class Todoable::Item
  RESOURCE_LOCATION = '/items'.freeze

  attr_accessor :name, :id, :source, :finished_at

  def initialize(list, name, id, source, finished_at)
    @list = list
    @name = name
    @id = id
    @source = source
    @finished_at = finished_at
  end

  def self_link
    @list.self_link + RESOURCE_LOCATION + "/#{@id}"
  end

  def finish
    Todoable.put(self_link + '/finish', {})
  end

  def delete
    Todoable.delete(self_link)
  end
end
