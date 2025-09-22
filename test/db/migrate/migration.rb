# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2024, by Samuel Williams.

require "db/migrate/client_context"

describe DB::Migrate::Migration do
	DB::Adapters.each do |name, klass|
		describe klass, unique: name do
			include_context DB::Migrate::ClientContext, klass.new(**CREDENTIALS)
			
			it "does not run the same migration twice" do
				migration_name = "test_idempotent_migration"
				
				# Clean up any existing migration record and table
				client.session do |session|
					begin
						statement = session.clause("DELETE FROM")
						statement.identifier(:migration)
						statement.clause("WHERE")
						statement.identifier(:name)
						statement.clause("=")
						statement.literal(migration_name)
						statement.call
					rescue
						# Ignore errors if migration table doesn't exist yet
					end
					
					begin
						statement = session.clause("DROP TABLE IF EXISTS")
						statement.identifier(:test_idempotent_table)
						statement.call
					rescue
						# Ignore errors
					end
				end
				
				# Track how many times the migration runs
				execution_count = 0
				
				# Define a migration that tracks executions
				migration_block = proc do
					execution_count += 1
					create_table :test_idempotent_table, drop_if_exists: true do
						primary_key
						column :name, "TEXT NOT NULL"
					end
				end
				
				# Run the migration twice
				DB::Migrate.migrate(migration_name, client, &migration_block)
				DB::Migrate.migrate(migration_name, client, &migration_block)
				
				# Should only have executed once
				expect(execution_count).to be == 1
				
				# Verify the migration was recorded
				client.session do |session|
					statement = session.clause("SELECT COUNT(*) FROM")
					statement.identifier(:migration)
					statement.clause("WHERE")
					statement.identifier(:name)
					statement.clause("=")
					statement.literal(migration_name)
					
					result = statement.call
					count = result.to_a.first.first
					expect(count).to be == 1
				end
				
				# Verify the table was created (proof that migration executed)
				client.session do |session|
					statement = session.clause("SELECT COUNT(*) FROM")
					statement.identifier(:test_idempotent_table)
					
					result = statement.call
					# Should succeed without error, proving table exists
					expect(result).to be_a(Object)
				end
			end
			
			it "runs different migrations independently" do
				# Clean up any existing migration records and tables
				client.session do |session|
					["first_migration", "second_migration"].each do |migration_name|
						begin
							statement = session.clause("DELETE FROM")
							statement.identifier(:migration)
							statement.clause("WHERE")
							statement.identifier(:name)
							statement.clause("=")
							statement.literal(migration_name)
							statement.call
						rescue
							# Ignore errors if migration table doesn't exist yet
						end
					end
					
					[:first_table, :second_table].each do |table_name|
						begin
							statement = session.clause("DROP TABLE IF EXISTS")
							statement.identifier(table_name)
							statement.call
						rescue
							# Ignore errors
						end
					end
				end
				
				# Track executions for each migration
				first_execution_count = 0
				second_execution_count = 0
				
				# First migration
				DB::Migrate.migrate("first_migration", client) do
					first_execution_count += 1
					create_table :first_table, drop_if_exists: true do
						primary_key
						column :data, "TEXT"
					end
				end
				
				# Second migration
				DB::Migrate.migrate("second_migration", client) do
					second_execution_count += 1
					create_table :second_table, drop_if_exists: true do
						primary_key
						column :info, "TEXT"
					end
				end
				
				# Run first migration again - should not execute
				DB::Migrate.migrate("first_migration", client) do
					first_execution_count += 1
					create_table :first_table, drop_if_exists: true do
						primary_key
						column :data, "TEXT"
					end
				end
				
				# Both should have executed exactly once
				expect(first_execution_count).to be == 1
				expect(second_execution_count).to be == 1
				
				# Verify both migrations were recorded
				client.session do |session|
					statement = session.clause("SELECT COUNT(*) FROM")
					statement.identifier(:migration)
					statement.clause("WHERE")
					statement.identifier(:name)
					statement.clause("IN")
					statement.clause("(")
					statement.literal("first_migration")
					statement.clause(",")
					statement.literal("second_migration")
					statement.clause(")")
					
					result = statement.call
					our_migrations = result.to_a.first.first
					expect(our_migrations).to be == 2  # Exactly our two migrations
				end
			end
		end
	end
end