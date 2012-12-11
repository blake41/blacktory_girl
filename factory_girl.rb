require 'debugger'
require 'forwardable'
module FactoryGirl
	extend Forwardable

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

class CleanRoom
	
	def factory(name, &block)
		@factory = Factory.new(name)
		block.call
		FactoryGirl.register_factory(@factory)
	end

	def method_missing(method, *args, &block)
		@factory.declare_method(method, args[0])
	end
end

class Factory

	attr_accessor :name

	def initialize(name)
		@name = name
	end

	def declare_method(attr_name, value)
		instance_variable_set("@#{attr_name}".to_sym, value)
		self.class.class_eval do
			define_method("#{attr_name}") do
				instance_variable_get("@#{attr_name}")
			end
		end
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
	end
end

user = FactoryGirl.create(:user)
debugger
puts user.first_name
puts user.last_name
