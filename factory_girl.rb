require 'debugger'

module FactoryGirl

  def self.configuration
    @configuration ||= Configuration.new
  end

  def self.define(&block)
    cr = CleanRoom.new
    cr.instance_eval(&block)
  end

  def self.register_factory(factory)
    factories[factory.name.to_sym] = factory 
  end

  def self.factories
    configuration.factories
  end

  def self.create(name)
    factories[name]
  end

end

class Factory

  attr_accessor :name

  def initialize(name)
    @name = name
  end

  def declare_method(attr_name, value, proc)
    set_value(attr_name, value, proc)
    self.class.class_eval do
      define_method("#{attr_name}") do
        instance_variable_get("@#{attr_name}").send(:call)
      end
    end
  end

  def set_value(attr_name, value, proc)
    if proc.is_a?(Proc) && value.nil?
      instance_variable_set("@#{attr_name}".to_sym, proc)
    else
      instance_variable_set("@#{attr_name}".to_sym, Proc.new {value})
    end
  end

end

class CleanRoom
  
  def factory(name, &block)
    @factory = Factory.new(name)
    block.call
    FactoryGirl.register_factory(@factory)
  end

  def method_missing(method, *args, &block)
    @factory.declare_method(method, args[0], block)
  end
end

class Configuration

  attr_accessor :factories

  def initialize
    @factories = {}
  end

end

FactoryGirl.define do 
  factory :user do
    first_name "blake"
    last_name "johnson"
    height { 5.to_i }
  end
end

user = FactoryGirl.create(:user)
puts user.first_name
puts user.last_name
puts user.height
