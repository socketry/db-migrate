# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2021-2024, by Samuel Williams.

require_relative "create_index"
require_relative "drop_table"

module DB
	module Migrate
		class CreateTable
			def initialize(name, drop_if_exists: false, if_not_exists: false)
				@name = name
				@columns = []
				@indexes = []
				
				@drop_if_exists = drop_if_exists
				@if_not_exists = if_not_exists
			end
			
			def drop_if_exists!
				@drop_if_exists = true
			end
			
			def if_not_exists!
				@if_not_exists = true
			end
			
			def primary_key(name = :id, **options)
				options[:primary] = true
				
				@columns << [name, :key_column, options]
			end
			
			def foreign_key(name, index: true, **options)
				options[:primary] = false
				
				@columns << [name, :key_column, options]
				
				if index
					@indexes << name
				end
			end
			
			def column(name, type, index: false, **options)
				@columns << [name, type, options]
				
				if index
					@indexes << name
				end
			end
			
			def timestamps
				self.column :created_at, "TIMESTAMP"
				self.column :updated_at, "TIMESTAMP"
			end
			
			def call(session)
				if @drop_if_exists
					DropTable.new(@name, if_exists: true).call(session)
				end
				
				statement = session.clause("CREATE TABLE")
				
				if @if_not_exists
					statement.clause("IF NOT EXISTS")
				end
				
				statement.identifier(@name)
				
				statement.clause("(")
				first = true
				
				@columns.each do |name, type, options|
					if first
						first = false
					else
						statement.clause(",")
					end
					
					if type == :key_column
						statement.clause(session.connection.key_column(name, **options))
					else
						statement.identifier(name)
						statement.clause(type)
						
						if !options[:null]
							statement.clause("NOT NULL")
						end
						
						if options.key?(:default)
							statement.clause("DEFAULT").literal(options[:default])
						end
						
						if unique = options[:unique]
							statement.clause("UNIQUE")
						end
					end
				end
				
				statement.clause(")")
				
				Console.logger.info(self, statement)
				statement.call
				
				@indexes.each do |column|
					name = "index_#{@name}_on_#{column}"
					CreateIndex.new(name, @name, column, if_not_exists: @if_not_exists).call(session)
				end
			end
		end
	end
end
