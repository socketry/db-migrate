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
					create_table :user, drop_if_exists: true do
						primary_key
						column :name, "TEXT", null: false
						column :password, "TEXT", null: false
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
end
