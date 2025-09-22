# Migrations

This guide explains how to create and structure database migrations using `db-migrate`.

## Overview

Migrations in `db-migrate` are Ruby blocks that define schema changes. Each migration runs inside a database transaction, ensuring consistency and allowing rollback on errors.

## Basic Migration Structure

```ruby
DB::Migrate.migrate("migration_name", client) do
  # Schema operations go here
end
```

## Migration Naming

Use descriptive names that indicate what the migration does:

```ruby
# Good examples
DB::Migrate.migrate("create_users_table", client) do
  # ...
end

DB::Migrate.migrate("add_email_index_to_users", client) do
  # ...
end

DB::Migrate.migrate("remove_deprecated_columns", client) do
  # ...
end
```

## Transaction Safety

All migration operations run inside a database transaction. If any operation fails, the entire migration is rolled back:

```ruby
DB::Migrate.migrate("complex_migration", client) do
  create_table :users do
    primary_key
    column :name, "TEXT NOT NULL"
  end
  
  # If this fails, the table creation above is rolled back
  create_index :users, :name
end
```

## Database Compatibility

`db-migrate` automatically detects your database's capabilities and generates appropriate SQL:

### PostgreSQL
- Uses `BIGSERIAL` for auto-increment columns
- Supports `IF EXISTS` clauses
- Uses `ALTER COLUMN ... TYPE ... USING ...` for column type changes

### MariaDB/MySQL  
- Uses `BIGINT AUTO_INCREMENT` for auto-increment columns
- Supports `IF EXISTS` clauses
- Uses `MODIFY COLUMN` for column type changes

## Available Operations

### Table Operations
- `create_table(name)` - Create a new table
- `create_table?(name)` - Create table only if it doesn't exist
- `drop_table(name, if_exists: true)` - Drop a table
- `rename_table(old_name, new_name)` - Rename a table

### Column Operations
- `add_column(name, type)` - Add a new column
- `drop_column(name, if_exists: true)` - Remove a column
- `rename_column(old_name, new_name)` - Rename a column
- `change_column(name, new_type)` - Change column type

### Index Operations
- `create_index(table, columns)` - Create an index
- `drop_index(name, if_exists: true)` - Drop an index

## Information Schema Access

Query database metadata within migrations:

```ruby
DB::Migrate.migrate("conditional_migration", client) do
  # Check if table exists before creating
  unless information_schema.table_exists?(:users)
    create_table :users do
      primary_key
      column :name, "TEXT NOT NULL"
    end
  end
end
```