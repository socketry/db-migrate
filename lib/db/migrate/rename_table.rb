# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2021-2024, by Samuel Williams.

require_relative "drop_index"

module DB
	module Migrate
		class RenameTable
			def initialize(name, new_name)
				@name = name
				@new_name = new_name
			end
			
			def call(session)
				statement = session.clause("ALTER TABLE")
				statement.identifier(@name)
				statement.clause("RENAME TO")
				statement.identifier(@new_name)
				
				Console.logger.info(self, statement)
				statement.call
			end
		end
	end
end
