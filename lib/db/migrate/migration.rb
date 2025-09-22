# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2021-2024, by Samuel Williams.

require "async"
require "console"

require_relative "create_table"
require_relative "rename_table"
require_relative "create_index"
require_relative "alter_table"

module DB
	module Migrate
		class Migration
			def initialize(name, session)
				@name = name
				@session = session
			end
			
			attr_reader :name, :session
			
			def call(&block)
				create_table?(:migration) do
					primary_key
					column :name, "TEXT NOT NULL", unique: true, index: true
					timestamps
				end
				
				# Check if migration has already been executed
				if migration_exists?
					Console.logger.info(self, "Migration '#{@name}' already executed, skipping...")
					return
				end
				
				# Execute the migration
				Console.logger.info(self, "Running migration '#{@name}'...")
				self.instance_eval(&block)
				
				# Record successful migration
				record_migration
				Console.logger.info(self, "Migration '#{@name}' completed successfully.")
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
			
			def alter_table(name, &block)
				alter_table = AlterTable.new(name)
				alter_table.instance_eval(&block)
				alter_table.call(@session)
			end
			
			private
			
			# Check if this migration has already been executed
			def migration_exists?
				statement = @session.clause("SELECT COUNT(*) FROM")
				statement.identifier(:migration)
				statement.clause("WHERE")
				statement.identifier(:name)
				statement.clause("=")
				statement.literal(@name)
				
				result = statement.call
				count = result.to_a.first.first
				count > 0
			end
			
			# Record that this migration has been executed
			def record_migration
				statement = @session.clause("INSERT INTO")
				statement.identifier(:migration)
				statement.clause("(")
				statement.identifier(:name)
				statement.clause(",")
				statement.identifier(:created_at)
				statement.clause(",")
				statement.identifier(:updated_at)
				statement.clause(") VALUES (")
				statement.literal(@name)
				statement.clause(", NOW(), NOW())")
				
				statement.call
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
