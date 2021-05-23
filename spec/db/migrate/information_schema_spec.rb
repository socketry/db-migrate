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
require 'db/migrate/information_schema'

RSpec.shared_examples_for DB::Migrate::InformationSchema do |adapter|
	let(:client) {DB::Client.new(adapter)}
	
	describe 'table_exist?' do
		it "can confirm table does not exist" do
			Sync do
				client.session do |session|
					information_schema = DB::Migrate::InformationSchema.new(session)
					
					expect(
						information_schema.table_exist?("does_not_exist_ever")
					).to be_falsey
				end
			end
		end
	end
end

DB::Adapters.each do |name, klass|
	RSpec.describe klass do
		include_examples DB::Migrate::InformationSchema, klass.new(**CREDENTIALS)
	end
end
