# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2021-2024, by Samuel Williams.

module DB
	module Migrate
		class DropIndex
			def initialize(name, if_exists: false)
				@name = name
				@if_exists = if_exists
			end
			
			def if_exists!
				@if_exists = true
			end
			
			def call(session)
				statement = session.clause("DROP INDEX")
				
				if @if_exists
					statement.clause("IF EXISTS")
				end
				
				statement.identifier(@name)
				
				Console.logger.info(self, statement)
				statement.call
			end
		end
	end
end
