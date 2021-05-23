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

require_relative 'drop_index'

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
				
				statement.call
			end
		end
	end
end
