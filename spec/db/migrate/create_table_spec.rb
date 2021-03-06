# frozen_string_literal: true

# Copyright, 2020, by Samuel G. D. Williams. <http://www.codeotaku.com>
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

require 'db/client'
require 'db/adapters'
require 'db/migrate'

RSpec.shared_examples_for DB::Migrate::CreateTable do |adapter|
	let(:client) {DB::Client.new(adapter)}
	
	it "can create a table" do
		Sync do
			DB::Migrate.migrate(self, client) do
				create_table :user, drop_if_exists: true do
					primary_key
					column :name, 'TEXT', null: false
					column :password, 'TEXT', null: false
					timestamps
				end
			end
			
			client.session do |session|
				information_schema = DB::Migrate::InformationSchema.new(session)
				
				expect(information_schema.table_exist?(:user)).to be_truthy
			end
		end
	end
end

DB::Adapters.each do |name, klass|
	RSpec.describe klass do
		include_examples DB::Migrate::CreateTable, klass.new(**CREDENTIALS)
	end
end
