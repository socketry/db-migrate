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

require_relative 'create_table'
require_relative 'create_index'

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
					column :name, 'TEXT NOT NULL', unique: true, index: true
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
		end
		
		def self.migrate(name, client, &block)
			client.transaction do |session|
				Migration.new(name, session).call(&block)
			end
		end
	end
end
