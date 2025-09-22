# Getting Started

This guide explains how to get started with `db-migrate` for managing database schema changes in Ruby applications.

## Installation

Add the gem to your project:

```bash
$ bundle add db-migrate
```

You'll also need a database adapter. For PostgreSQL:

```bash
$ bundle add db-postgres
```

For MariaDB/MySQL:

```bash
$ bundle add db-mariadb
```

## Core Concepts

`db-migrate` provides a simple and flexible way to manage database schema changes:

- {DB::Migrate::Migration} which represents a single database migration with schema changes.
- Database-agnostic migration operations that work across PostgreSQL, MariaDB, and other supported databases.
- Feature detection that automatically uses the best SQL syntax for your database.

## Usage

Create and run a migration:

```ruby
require 'db/migrate'
require 'db/postgres' # or 'db/mariadb'

# Connect to your database
client = DB::Client.new(DB::Postgres::Adapter.new(
  host: 'localhost',
  database: 'myapp_development'
))

# Define and run a migration
DB::Migrate.migrate("create_users_table", client) do
  create_table :users do
    primary_key
    column :name, "TEXT NOT NULL"
    column :email, "TEXT UNIQUE"
    timestamps
  end
end
```

### Running Multiple Operations

Migrations can include multiple operations:

```ruby
DB::Migrate.migrate("update_users_schema", client) do
  # Add new columns
  alter_table :users do
    add_column :age, "INTEGER"
    add_column :active, "BOOLEAN DEFAULT TRUE"
  end
  
  # Create indexes
  create_index :users, :email
  create_index :users, [:name, :active]
end
```

### Conditional Operations

Use conditional operations when you're not sure if tables or columns exist:

```ruby
DB::Migrate.migrate("safe_schema_update", client) do
  # Only create table if it doesn't exist
  create_table? :profiles do
    primary_key
    column :user_id, "BIGINT NOT NULL"
    column :bio, "TEXT"
  end
  
  # Only drop table if it exists
  drop_table :old_table, if_exists: true
end
```

The `db-migrate` gem automatically detects your database's capabilities and only uses conditional operations (like `IF EXISTS`) when supported.