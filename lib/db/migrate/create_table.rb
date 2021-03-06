# frozen_string_literal: true

# Copyright, 2021, by Samuel G. D. Williams. <http://www.codeotaku.com>
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

require_relative 'create_index'
require_relative 'drop_table'

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
