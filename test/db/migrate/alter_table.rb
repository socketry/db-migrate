# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2021-2024, by Samuel Williams.

require "db/migrate/client_context"

describe DB::Migrate::AlterTable do
	DB::Adapters.each do |name, klass|
		describe klass, unique: name do
			include_context DB::Migrate::ClientContext, klass.new(**CREDENTIALS)
			
			it "can add a column to an existing table" do
				DB::Migrate.migrate(self, client) do
					create_table :user, drop_if_exists: true do
						primary_key
						column :name, "TEXT", null: false
					end
					
					alter_table :user do
						add_column :email, "TEXT"
					end
				end
				
				client.session do |session|
					information_schema = DB::Migrate::InformationSchema.new(session)
					
					expect(information_schema.table_exist?(:user)).to be_truthy
					
					# Check that we can insert data with the new column
					statement = session.clause("INSERT INTO")
					statement.identifier(:user)
					statement.clause("(name, email) VALUES")
					statement.clause("(").literal("John").clause(",").literal("john@example.com").clause(")")
					statement.call
					
					# Check the inserted data
					statement = session.clause("SELECT name, email FROM")
					statement.identifier(:user)
					statement.clause("WHERE name =")
					statement.literal("John")
					result = statement.call.to_a
					expect(result.length).to be == 1
					expect(result.first[0]).to be == "John"
					expect(result.first[1]).to be == "john@example.com"
				end
			end
			
			it "can add a column with constraints" do
				DB::Migrate.migrate(self, client) do
					create_table :user, drop_if_exists: true do
						primary_key
						column :name, "TEXT", null: false
					end
					
					alter_table :user do
						add_column :age, "INTEGER", null: false, default: 0
					end
				end
				
				client.session do |session|
					# Check that we can insert data without specifying the new column (default should be used)
					statement = session.clause("INSERT INTO")
					statement.identifier(:user)
					statement.clause("(name) VALUES")
					statement.clause("(").literal("Jane").clause(")")
					statement.call
					
					# Check the inserted data
					statement = session.clause("SELECT name, age FROM")
					statement.identifier(:user)
					statement.clause("WHERE name =")
					statement.literal("Jane")
					result = statement.call.to_a
					expect(result.length).to be == 1
					expect(result.first[0]).to be == "Jane"
					expect(result.first[1]).to be == 0
				end
			end
			
			it "can drop a column from an existing table" do
				DB::Migrate.migrate(self, client) do
					create_table :user, drop_if_exists: true do
						primary_key
						column :name, "TEXT", null: false
						column :email, "TEXT"
						column :age, "INTEGER"
					end
					
					alter_table :user do
						drop_column :age
					end
				end
				
				client.session do |session|
					# Should be able to insert data without the dropped column
					statement = session.clause("INSERT INTO")
					statement.identifier(:user)
					statement.clause("(name, email) VALUES")
					statement.clause("(").literal("Bob").clause(",").literal("bob@example.com").clause(")")
					statement.call
					
					# Check the inserted data
					statement = session.clause("SELECT name, email FROM")
					statement.identifier(:user)
					statement.clause("WHERE name =")
					statement.literal("Bob")
					result = statement.call.to_a
					expect(result.length).to be == 1
					expect(result.first[0]).to be == "Bob"
					expect(result.first[1]).to be == "bob@example.com"
					
					# Should not be able to select the dropped column
					expect do
						statement = session.clause("SELECT age FROM")
						statement.identifier(:user)
						statement.call.to_a
					end.to raise_exception
				end
			end
			
			it "can drop a column with if_exists option" do
				DB::Migrate.migrate(self, client) do
					create_table :user, drop_if_exists: true do
						primary_key
						column :name, "TEXT", null: false
					end
					
					alter_table :user do
						drop_column :nonexistent_column, if_exists: true
					end
				end
				
				client.session do |session|
					information_schema = DB::Migrate::InformationSchema.new(session)
					expect(information_schema.table_exist?(:user)).to be_truthy
				end
			end
			
			it "can rename a column" do
				DB::Migrate.migrate(self, client) do
					create_table :user, drop_if_exists: true do
						primary_key
						column :full_name, "TEXT", null: false
					end
					
					alter_table :user do
						rename_column :full_name, :name
					end
				end
				
				client.session do |session|
					# Should be able to use the new column name
					statement = session.clause("INSERT INTO")
					statement.identifier(:user)
					statement.clause("(name) VALUES")
					statement.clause("(").literal("Alice").clause(")")
					statement.call
					
					# Check the inserted data
					statement = session.clause("SELECT name FROM")
					statement.identifier(:user)
					statement.clause("WHERE name =")
					statement.literal("Alice")
					result = statement.call.to_a
					expect(result.length).to be == 1
					expect(result.first[0]).to be == "Alice"
					
					# Should not be able to use the old column name
					expect do
						statement = session.clause("SELECT full_name FROM")
						statement.identifier(:user)
						statement.call.to_a
					end.to raise_exception
				end
			end
			
			it "can change a column type" do
				DB::Migrate.migrate(self, client) do
					create_table :user, drop_if_exists: true do
						primary_key
						column :name, "TEXT", null: false
						column :age, "TEXT"
					end
					
					alter_table :user do
						change_column :age, "INTEGER"
					end
				end
				
				client.session do |session|
					# Should be able to insert integer values into the changed column
					statement = session.clause("INSERT INTO")
					statement.identifier(:user)
					statement.clause("(name, age) VALUES")
					statement.clause("(").literal("Charlie").clause(",").literal(25).clause(")")
					statement.call
					
					# Check the inserted data
					statement = session.clause("SELECT name, age FROM")
					statement.identifier(:user)
					statement.clause("WHERE name =")
					statement.literal("Charlie")
					result = statement.call.to_a
					expect(result.length).to be == 1
					expect(result.first[0]).to be == "Charlie"
					expect(result.first[1]).to be == 25
				end
			end
			
			it "can perform multiple operations in one alter_table block" do
				DB::Migrate.migrate(self, client) do
					create_table :user, drop_if_exists: true do
						primary_key
						column :full_name, "TEXT", null: false
						column :old_column, "TEXT"
					end
					
					alter_table :user do
						rename_column :full_name, :name
						add_column :email, "TEXT"
						drop_column :old_column
					end
				end
				
				client.session do |session|
					# Should be able to use the renamed column and new column
					statement = session.clause("INSERT INTO")
					statement.identifier(:user)
					statement.clause("(name, email) VALUES")
					statement.clause("(").literal("David").clause(",").literal("david@example.com").clause(")")
					statement.call
					
					# Check the inserted data
					statement = session.clause("SELECT name, email FROM")
					statement.identifier(:user)
					statement.clause("WHERE name =")
					statement.literal("David")
					result = statement.call.to_a
					expect(result.length).to be == 1
					expect(result.first[0]).to be == "David"
					expect(result.first[1]).to be == "david@example.com"
					
					# Should not be able to use the old column names
					expect do
						statement = session.clause("SELECT full_name FROM")
						statement.identifier(:user)
						statement.call.to_a
					end.to raise_exception
					
					expect do
						statement = session.clause("SELECT old_column FROM")
						statement.identifier(:user)
						statement.call.to_a
					end.to raise_exception
				end
			end
		end
	end
end