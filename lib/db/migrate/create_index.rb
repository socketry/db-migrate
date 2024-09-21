# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2021-2024, by Samuel Williams.

require_relative "drop_index"

module DB
	module Migrate
		class CreateIndex
			def initialize(name, table, columns = [], unique: false, drop_if_exists: false, if_not_exists: false, method: nil)
				@name = name
				@table = table
				@columns = Array(columns)
				
				@unique = unique
				@drop_if_exists = drop_if_exists
				@if_not_exists = if_not_exists
				@method = method
			end
			
			def call(session)
				if @drop_if_exists
					DropIndex.new(@name, if_exists: true).call(session)
				end
				
				if @unique
					statement = session.clause("CREATE UNIQUE INDEX")
				else
					statement = session.clause("CREATE INDEX")
				end
				
				if @if_not_exists
					statement.clause("IF NOT EXISTS")
				end
				
				statement.identifier(@name)
				
				statement.clause("ON")
				statement.identifier(@table)
				
				if @method
					statement.clause("USING")
					statement.identifier(@method)
				end
				
				statement.clause("(")
				first = true
				indexes = []
				
				@columns.each do |name|
					if first
						first = false
					else
						statement.clause(",")
					end
					
					statement.identifier(name)
				end
				
				statement.clause(")")
				
				Console.logger.info(self, statement)
				statement.call
			end
		end
	end
end
