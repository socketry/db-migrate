# Alter Table

This guide explains how to modify existing database tables using `db-migrate`.

## Basic Table Alterations

Use `alter_table` to modify an existing table:

```ruby
DB::Migrate.migrate("update_users_table", client) do
	alter_table :users do
		add_column :age, "INTEGER"
		add_column :active, "BOOLEAN DEFAULT TRUE"
	end
end
```

## Adding Columns

### Basic Column Addition

```ruby
alter_table :users do
	add_column :email, "TEXT"
	add_column :phone, "TEXT"
end
```

### Columns with Constraints

```ruby
alter_table :users do
	add_column :email, "TEXT NOT NULL"
	add_column :age, "INTEGER", default: 0
	add_column :status, "TEXT", unique: true
end
```

## Dropping Columns

### Basic Column Removal

```ruby
alter_table :users do
	drop_column :old_field
	drop_column :deprecated_column
end
```

### Safe Column Removal

Use `if_exists` to avoid errors if the column doesn't exist:

```ruby
alter_table :users do
	drop_column :maybe_missing_column, if_exists: true
end
```

## Renaming Columns

```ruby
alter_table :users do
	rename_column :full_name, :name
	rename_column :email_address, :email
end
```

## Changing Column Types

Use `change_column` to modify a column's data type:

```ruby
alter_table :users do
	change_column :age, "INTEGER"
	change_column :balance, "DECIMAL(10,2)"
end
```

### Database-Specific Behavior

The gem automatically uses the appropriate syntax for your database:

**PostgreSQL:**
```sql
ALTER TABLE users ALTER COLUMN age TYPE INTEGER USING age::INTEGER;
```

**MariaDB/MySQL:**
```sql
ALTER TABLE users MODIFY COLUMN age INTEGER;
```

## Multiple Operations

Combine multiple alterations in a single migration:

```ruby
alter_table :users do
	add_column :middle_name, "TEXT"
	drop_column :old_field, if_exists: true
	rename_column :full_name, :name
	change_column :age, "INTEGER"
end
```

## Advanced Examples

### Data Type Conversions

```ruby
# Convert text to integer with explicit casting
alter_table :products do
	change_column :price_text, "DECIMAL(10,2)"
end
```

For PostgreSQL, this automatically includes a `USING` clause for safe conversion.

### Adding Columns with Complex Defaults

```ruby
alter_table :orders do
	add_column :order_number, "TEXT NOT NULL", 
				default: "'ORD-' || EXTRACT(epoch FROM NOW())::TEXT"
end
```

### Conditional Schema Changes

```ruby
alter_table :users do
		# Only add column if it doesn't exist
	unless information_schema.column_exists?(:users, :created_at)
		add_column :created_at, "TIMESTAMP DEFAULT NOW()"
	end
end
```

## Feature Detection

The gem uses feature detection to ensure compatibility:

- **Conditional Operations**: `IF EXISTS` clauses are only used when supported
- **Column Modification**: Uses `MODIFY COLUMN` (MariaDB) vs `ALTER COLUMN TYPE` (PostgreSQL)
- **Using Clauses**: PostgreSQL's `USING` clause for safe type conversions

## Best Practices

### Safe Alterations

Always use conditional operations when uncertain:

```ruby
alter_table :users do
	drop_column :deprecated_field, if_exists: true
	add_column :new_field, "TEXT"
end
```

### Incremental Changes

Make small, focused changes rather than large alterations:

```ruby
# Good: Focused change
alter_table :users do
	add_column :email_verified, "BOOLEAN DEFAULT FALSE"
end

# Better than: Large, complex change
alter_table :users do
	add_column :email_verified, "BOOLEAN DEFAULT FALSE"
	add_column :phone_verified, "BOOLEAN DEFAULT FALSE"
	add_column :two_factor_enabled, "BOOLEAN DEFAULT FALSE"
	drop_column :old_verification_method, if_exists: true
	rename_column :verification_code, :email_verification_code
end
```

### Performance Considerations

For large tables, consider the performance impact of schema changes, especially when adding `NOT NULL` columns without defaults.