# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2024, by Samuel Williams.

require "db/migrate"

describe DB::Migrate do
	it "has a version number" do
		expect(DB::Migrate::VERSION).to be =~ /\d+\.\d+\.\d+/
	end
end
