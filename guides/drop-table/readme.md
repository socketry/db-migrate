# Drop Table

This guide explains how to remove database tables using `db-migrate`.

## Basic Table Removal

Use `drop_table` to remove a table:

```ruby
DB::Migrate.migrate("remove_old_table", client) do
  drop_table :old_users_table
end
```

## Safe Table Removal

Use `if_exists` to avoid errors if the table doesn't exist:

```ruby
DB::Migrate.migrate("safe_cleanup", client) do
  drop_table :maybe_missing_table, if_exists: true
end
```

## Feature Detection

The gem automatically detects whether your database supports `IF EXISTS` clauses:

**PostgreSQL & MariaDB:**
```sql
DROP TABLE IF EXISTS old_table;
```

**Databases without IF EXISTS support:**
```sql
DROP TABLE old_table;
```

## Multiple Table Removal

Remove multiple tables in a single migration:

```ruby
DB::Migrate.migrate("cleanup_old_tables", client) do
  drop_table :temp_users, if_exists: true
  drop_table :old_analytics, if_exists: true
  drop_table :deprecated_logs, if_exists: true
end
```

## Advanced Examples

### Conditional Removal

Check if a table exists before dropping it:

```ruby
DB::Migrate.migrate("conditional_cleanup", client) do
  if information_schema.table_exists?(:old_table)
    drop_table :old_table
  end
end
```

### Table Replacement

Replace an existing table with a new structure:

```ruby
DB::Migrate.migrate("replace_users_table", client) do
  # Drop the old table
  drop_table :users, if_exists: true
  
  # Create the new table
  create_table :users do
    primary_key
    column :name, "TEXT NOT NULL"
    column :email, "TEXT UNIQUE NOT NULL"
    timestamps
  end
end
```

### Dependent Table Cleanup

Remove tables in the correct order to handle dependencies:

```ruby
DB::Migrate.migrate("cleanup_related_tables", client) do
  # Drop dependent tables first
  drop_table :user_preferences, if_exists: true
  drop_table :user_sessions, if_exists: true
  
  # Then drop the main table
  drop_table :users, if_exists: true
end
```

## Best Practices

### Always Use if_exists for Cleanup

When removing tables during cleanup operations, always use `if_exists`:

```ruby
# Good: Safe cleanup
drop_table :temp_table, if_exists: true

# Risky: May fail if table doesn't exist
drop_table :temp_table
```

### Document Destructive Operations

Add clear comments for destructive operations:

```ruby
DB::Migrate.migrate("remove_deprecated_analytics", client) do
  # WARNING: This permanently removes all analytics data from before 2023
  # Ensure backup is completed before running this migration
  drop_table :old_analytics_2022, if_exists: true
end
```

### Consider Data Migration

Before dropping tables with important data, consider migrating it:

```ruby
DB::Migrate.migrate("migrate_user_data", client) do
  # First, migrate important data
  session.query("INSERT INTO users_new SELECT id, name, email FROM users_old")
  
  # Then drop the old table
  drop_table :users_old, if_exists: true
end
```

## Safety Considerations

### Backup Important Data

Always backup important data before dropping tables:

```bash
# PostgreSQL
pg_dump -t old_important_table mydb > backup.sql

# MariaDB/MySQL  
mysqldump mydb old_important_table > backup.sql
```

### Test Migrations

Test destructive migrations on a copy of your production data:

```ruby
# Test migration on development/staging first
DB::Migrate.migrate("test_table_removal", client) do
  drop_table :test_table, if_exists: true
end
```

### Transaction Safety

Table drops are included in the migration transaction and will be rolled back if any subsequent operation fails:

```ruby
DB::Migrate.migrate("safe_migration", client) do
  drop_table :old_table, if_exists: true
  
  create_table :new_table do
    primary_key
    column :name, "TEXT NOT NULL"
  end
  
  # If this fails, the table drop above is rolled back
  create_index :new_table, :name
end
```