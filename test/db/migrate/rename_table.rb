# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2021-2024, by Samuel Williams.

require "db/migrate/client_context"

describe DB::Migrate::CreateTable do
	DB::Adapters.each do |name, klass|
		describe klass, unique: name do
			include_context DB::Migrate::ClientContext, klass.new(**CREDENTIALS)
			
			it "can create a table" do
				DB::Migrate.migrate(self, client) do
					drop_table :account, if_exists: true
					
					create_table :user, drop_if_exists: true do
						primary_key
					end
					
					rename_table :user, :account
				end
				
				client.session do |session|
					information_schema = DB::Migrate::InformationSchema.new(session)
					
					expect(information_schema.table_exist?(:account)).to be_truthy
				end
			end
		end
	end
end
