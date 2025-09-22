# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2021-2024, by Samuel Williams.

require "db"

module DB
	module Migrate
		class InformationSchema
			def initialize(session)
				@session = session
			end
			
			TABLES = DB::Identifier[:information_schema, :tables]
			
			def table_exist?(name)
				statement = @session.clause("SELECT * FROM")
				statement.identifier(TABLES)
				statement.clause("WHERE")
				statement.identifier(:table_name)
				statement.clause("=")
				statement.literal(name)
				
				return statement.call.to_a.any?
			end
		end
	end
end
