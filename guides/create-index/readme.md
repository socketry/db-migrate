# Create Index

This guide explains how to create database indexes using `db-migrate`.

## Basic Index Creation

Use `create_index` to add indexes for better query performance:

```ruby
DB::Migrate.migrate("add_user_indexes", client) do
  create_index :users, :email
  create_index :users, :name
end
```

## Composite Indexes

Create indexes on multiple columns:

```ruby
DB::Migrate.migrate("add_composite_indexes", client) do
  create_index :orders, [:user_id, :created_at]
  create_index :user_preferences, [:user_id, :preference_key]
end
```

## Index Options

### Unique Indexes

Enforce uniqueness at the database level:

```ruby
create_index :users, :email, unique: true
create_index :user_preferences, [:user_id, :preference_key], unique: true
```

### Named Indexes

Specify custom index names:

```ruby
create_index :users, :email, name: "idx_users_email_unique", unique: true
create_index :orders, [:user_id, :status], name: "idx_orders_user_status"
```

### Conditional Indexes (PostgreSQL)

Create partial indexes with conditions:

```ruby
# PostgreSQL-specific conditional index
create_index :users, :email, 
  name: "idx_active_users_email",
  condition: "active = true"
```

## Index Types

### Standard B-tree Indexes

Default index type, good for equality and range queries:

```ruby
create_index :users, :created_at  # Range queries
create_index :users, :status      # Equality queries
```

### Database-Specific Index Types

```ruby
# PostgreSQL GIN index for JSONB
create_index :documents, :metadata, type: "GIN"

# PostgreSQL GiST index for geometric data
create_index :locations, :coordinates, type: "GiST"

# Text search indexes
create_index :articles, :content, type: "GIN", 
  expression: "to_tsvector('english', content)"
```

## Advanced Examples

### Functional Indexes

Create indexes on expressions:

```ruby
# Index on lowercase email for case-insensitive searches
create_index :users, nil,
  name: "idx_users_email_lower",
  expression: "LOWER(email)"

# Index on extracted JSON field
create_index :documents, nil,
  name: "idx_documents_title", 
  expression: "metadata->>'title'"
```

### Concurrent Index Creation (PostgreSQL)

For large tables, create indexes without blocking writes:

```ruby
# Note: This requires special handling and may not be supported
# in all migration contexts due to transaction requirements
create_index :large_table, :important_column, 
  algorithm: "CONCURRENTLY"
```

## Performance Considerations

### Index Strategy

Choose indexes based on your query patterns:

```ruby
# Good: Index frequently queried columns
create_index :orders, :user_id      # For user's orders
create_index :orders, :created_at   # For recent orders
create_index :orders, :status       # For order filtering

# Composite index for common query combinations
create_index :orders, [:user_id, :status]  # For user's pending orders
```

### Avoid Over-Indexing

Don't create unnecessary indexes:

```ruby
# Avoid: Too many single-column indexes
create_index :users, :first_name
create_index :users, :last_name  
create_index :users, [:first_name, :last_name]  # This composite covers both

# Better: Strategic composite index
create_index :users, [:last_name, :first_name]  # Covers both queries
```

## Creating Indexes in Table Definitions

You can also create indexes when defining tables:

```ruby
create_table :users do
  primary_key
  column :email, "TEXT NOT NULL", unique: true, index: true
  column :name, "TEXT", index: true
  timestamps
  
  # Composite indexes
  index [:email, :created_at]
  index [:name, :active], name: "idx_active_users_by_name"
end
```

## Dropping Indexes

Remove indexes when they're no longer needed:

```ruby
DB::Migrate.migrate("cleanup_unused_indexes", client) do
  drop_index :idx_old_user_lookup, if_exists: true
  drop_index :idx_deprecated_search, if_exists: true
end
```

## Feature Detection

The gem automatically handles database-specific index features:

- **Conditional Indexes**: Only used when supported (PostgreSQL)
- **Index Types**: Database-specific types like GIN, GiST
- **IF EXISTS**: Safe index creation/removal when supported

## Best Practices

### Index Naming Convention

Use consistent naming patterns:

```ruby
# Good: Descriptive names
create_index :users, :email, name: "idx_users_email"
create_index :orders, [:user_id, :status], name: "idx_orders_user_status"

# Pattern: idx_{table}_{columns}_{suffix}
create_index :users, :email, name: "idx_users_email_unique", unique: true
```

### Monitor Index Usage

Regularly review index effectiveness:

```sql
-- PostgreSQL: Check index usage
SELECT schemaname, tablename, indexname, idx_scan 
FROM pg_stat_user_indexes 
WHERE idx_scan = 0;

-- MariaDB: Check index cardinality
SHOW INDEX FROM users;
```

### Index Maintenance

Consider index maintenance in high-traffic applications:

```ruby
# For very large tables, create indexes during low-traffic periods
DB::Migrate.migrate("add_large_table_index", client) do
  # Consider creating this during maintenance windows
  create_index :large_transaction_table, :created_at
end
```