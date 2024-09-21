# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2021-2024, by Samuel Williams.

require "db/migrate/client_context"

describe DB::Migrate::InformationSchema do
	DB::Adapters.each do |name, klass|
		describe klass, unique: name do
			include_context DB::Migrate::ClientContext, klass.new(**CREDENTIALS)
			
			with "table_exist?" do
				it "can confirm table does not exist" do
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
end
