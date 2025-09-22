# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2021-2024, by Samuel Williams.

module DB
	module Migrate
		class AlterTable
			def initialize(name)
				@name = name
				@operations = []
			end
			
			attr_reader :name, :operations
			
			# Add a new column to the table
			def add_column(name, type, **options)
				@operations << [:add_column, name, type, options]
			end
			
			# Drop a column from the table
			def drop_column(name, if_exists: false)
				@operations << [:drop_column, name, {if_exists: if_exists}]
			end
			
			# Rename a column
			def rename_column(old_name, new_name)
				@operations << [:rename_column, old_name, new_name, {}]
			end
			
			# Change column type or options
			def change_column(name, type, **options)
				@operations << [:change_column, name, type, options]
			end
			
			def call(session)
				@operations.each do |operation, *args|
					case operation
					when :add_column
						add_column_statement(session, *args)
					when :drop_column
						drop_column_statement(session, *args)
					when :rename_column
						rename_column_statement(session, *args)
					when :change_column
						change_column_statement(session, *args)
					end
				end
			end
			
			private
			
			def add_column_statement(session, column_name, type, options)
				statement = session.clause("ALTER TABLE")
				statement.identifier(@name)
				statement.clause("ADD COLUMN")
				statement.identifier(column_name)
				statement.clause(type)
				
				if options.key?(:null) && !options[:null]
					statement.clause("NOT NULL")
				end
				
				if options.key?(:default)
					statement.clause("DEFAULT")
					statement.literal(options[:default])
				end
				
				if options[:unique]
					statement.clause("UNIQUE")
				end
				
				Console.logger.info(self, statement)
				statement.call
			end
			
			def drop_column_statement(session, column_name, options)
				statement = session.clause("ALTER TABLE")
				statement.identifier(@name)
				statement.clause("DROP COLUMN")
				
				# Use feature detection for IF EXISTS support
				features = session.connection.features
				if options[:if_exists] && features.conditional_operations?
					statement.clause("IF EXISTS")
				end
				
				statement.identifier(column_name)
				
				Console.logger.info(self, statement)
				statement.call
			end
			
			def rename_column_statement(session, old_name, new_name, options)
				statement = session.clause("ALTER TABLE")
				statement.identifier(@name)
				statement.clause("RENAME COLUMN")
				statement.identifier(old_name)
				statement.clause("TO")
				statement.identifier(new_name)
				
				Console.logger.info(self, statement)
				statement.call
			end
			
			def change_column_statement(session, column_name, type, options)
				# Use feature detection for database-specific syntax
				features = session.connection.features
				
				if features.modify_column?
					# MySQL/MariaDB syntax: MODIFY COLUMN
					statement = session.clause("ALTER TABLE")
					statement.identifier(@name)
					statement.clause("MODIFY COLUMN")
					statement.identifier(column_name)
					statement.clause(type)
					
					Console.logger.info(self, statement)
					statement.call
				elsif features.alter_column_type?
					# PostgreSQL syntax: ALTER COLUMN ... TYPE ... USING ...
					statement = session.clause("ALTER TABLE")
					statement.identifier(@name)
					statement.clause("ALTER COLUMN")
					statement.identifier(column_name)
					statement.clause("TYPE")
					statement.clause(type)
					
					if features.using_clause?
						# Add USING clause for safe conversion
						statement.clause("USING")
						statement.identifier(column_name)
						statement.clause("::")
						statement.clause(type)
					end
					
					Console.logger.info(self, statement)
					statement.call
				else
					# Generic syntax for unsupported databases (default to PostgreSQL-style)
					statement = session.clause("ALTER TABLE")
					statement.identifier(@name)
					statement.clause("ALTER COLUMN")
					statement.identifier(column_name)
					statement.clause("TYPE")
					statement.clause(type)
					
					Console.logger.info(self, statement)
					statement.call
				end
			end
		end
	end
end