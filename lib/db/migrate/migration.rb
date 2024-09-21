# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2021-2024, by Samuel Williams.

require "async"

require_relative "create_table"
require_relative "rename_table"
require_relative "create_index"

module DB
	module Migrate
		class Migration
			def initialize(name, session)
				@name = name
				@session = session
			end
			
			def call(&block)
				create_table?(:migration) do
					primary_key
					column :name, "TEXT NOT NULL", unique: true, index: true
					timestamps
				end
				
				self.instance_eval(&block)
			end
			
			def information_schema
				@information_schema ||= InformationSchema.new(@session)
			end
			
			def create_table(name, **options, &block)
				create_table = CreateTable.new(name, **options)
				create_table.instance_eval(&block)
				create_table.call(@session)
			end
			
			def create_table?(name, **options, &block)
				options[:if_not_exists] = true
				
				create_table = CreateTable.new(name, **options)
				create_table.instance_eval(&block)
				create_table.call(@session)
			end
			
			def rename_table(name, new_name)
				rename_table = RenameTable.new(name, new_name)
				rename_table.call(@session)
			end
			
			def create_index(...)
				create_index = CreateIndex.new(...)
				create_index.call(@session)
			end
			
			def drop_table(name, if_exists: false)
				drop_table = DropTable.new(name, if_exists: if_exists)
				drop_table.call(@session)
			end
		end
		
		def self.migrate(name, client, &block)
			Sync do
				client.transaction do |session|
					Migration.new(name, session).call(&block)
				end
			end
		end
	end
end
