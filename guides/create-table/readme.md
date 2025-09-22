# Create Table

This guide explains how to create database tables using `db-migrate`.

## Basic Table Creation

Use `create_table` to define a new table:

```ruby
DB::Migrate.migrate("create_users", client) do
  create_table :users do
    primary_key
    column :name, "TEXT NOT NULL"
    column :email, "TEXT UNIQUE"
    timestamps
  end
end
```

## Conditional Table Creation

Use `create_table?` to create a table only if it doesn't already exist:

```ruby
DB::Migrate.migrate("safe_create_users", client) do
  create_table? :users do
    primary_key
    column :name, "TEXT NOT NULL"
  end
end
```

## Column Definitions

### Basic Columns

Define columns with their SQL type:

```ruby
create_table :products do
  column :name, "TEXT NOT NULL"
  column :price, "DECIMAL(10,2)"
  column :description, "TEXT"
  column :active, "BOOLEAN DEFAULT TRUE"
end
```

### Primary Keys

Add an auto-incrementing primary key:

```ruby
create_table :users do
  primary_key # Creates 'id' column
  # Other columns...
end

# Custom primary key name
create_table :users do
  primary_key :user_id
  # Other columns...
end
```

The primary key uses database-appropriate types:
- PostgreSQL: `BIGSERIAL PRIMARY KEY`
- MariaDB/MySQL: `BIGINT AUTO_INCREMENT PRIMARY KEY`

### Timestamps

Add created_at and updated_at columns:

```ruby
create_table :posts do
  primary_key
  column :title, "TEXT NOT NULL"
  timestamps # Adds created_at and updated_at
end
```

## Column Options

### Constraints

```ruby
create_table :users do
  primary_key
  column :email, "TEXT NOT NULL", unique: true
  column :age, "INTEGER", null: false
  column :status, "TEXT", default: "'active'"
end
```

### Indexes

Create indexes on columns:

```ruby
create_table :users do
  primary_key
  column :email, "TEXT NOT NULL", unique: true, index: true
  column :name, "TEXT", index: true
end
```

## Advanced Examples

### Composite Indexes

```ruby
create_table :user_preferences do
  primary_key
  column :user_id, "BIGINT NOT NULL"
  column :preference_key, "TEXT NOT NULL"
  column :preference_value, "TEXT"
  
  # Create composite index
  index [:user_id, :preference_key], unique: true
end
```

### Foreign Key References

```ruby
create_table :posts do
  primary_key
  column :user_id, "BIGINT NOT NULL"
  column :title, "TEXT NOT NULL"
  column :content, "TEXT"
  timestamps
  
  # Note: Foreign key constraints are defined separately
  # This just creates the reference column
end
```

### Database-Specific Types

```ruby
create_table :analytics do
  primary_key
  column :event_data, "JSONB"  # PostgreSQL
  column :tags, "JSON"         # MariaDB/MySQL
  column :metadata, "TEXT"     # Universal fallback
end
```

## Options

### Drop Existing Table

Replace an existing table:

```ruby
create_table :users, drop_if_exists: true do
  primary_key
  column :name, "TEXT NOT NULL"
end
```

### Temporary Tables

```ruby
create_table :temp_data, temporary: true do
  column :id, "BIGINT"
  column :data, "TEXT"
end
```

Note: Temporary table support depends on your database adapter implementation.