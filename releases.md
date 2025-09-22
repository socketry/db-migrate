# Releases

## Unreleased

  - Improved database compatibility using standardized feature detection from `DB::Features`.
  - Add support for `alter_table` operations: `rename_column`, `change_column`, and `drop_column`.
  - Enhanced column type changes with database-specific syntax selection.
  - Conditional `IF EXISTS` clauses are now only used when supported by the database.
  - Improved idempotency and safety of migration operations.
