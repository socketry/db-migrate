# DB::Migrate

Provides convenient abstractions for creating tables, indexes and general database migrations.

[![Development Status](https://github.com/socketry/db-migrate/workflows/Test/badge.svg)](https://github.com/socketry/db-migrate/actions?workflow=Test)

## Usage

Please see the [project documentation](https://socketry.github.io/db-migrate/) for more details.

  - [Getting Started](https://socketry.github.io/db-migrate/guides/getting-started/index) - This guide explains how to get started with `db-migrate` for managing database schema changes in Ruby applications.

  - [Migrations](https://socketry.github.io/db-migrate/guides/migrations/index) - This guide explains how to create and structure database migrations using `db-migrate`.

  - [Create Table](https://socketry.github.io/db-migrate/guides/create-table/index) - This guide explains how to create database tables using `db-migrate`.

  - [Alter Table](https://socketry.github.io/db-migrate/guides/alter-table/index) - This guide explains how to modify existing database tables using `db-migrate`.

  - [Drop Table](https://socketry.github.io/db-migrate/guides/drop-table/index) - This guide explains how to remove database tables using `db-migrate`.

  - [Create Index](https://socketry.github.io/db-migrate/guides/create-index/index) - This guide explains how to create database indexes using `db-migrate`.

## Releases

Please see the [project releases](https://socketry.github.io/db-migrate/releases/index) for all releases.

### v0.3.0

  - Improved database compatibility using standardized feature detection from `DB::Features`.
  - Add support for `alter_table` operations: `rename_column`, `change_column`, and `drop_column`.
  - Enhanced column type changes with database-specific syntax selection.
  - Conditional `IF EXISTS` clauses are now only used when supported by the database.
  - Improved idempotency and safety of migration operations.

## Contributing

We welcome contributions to this project.

1.  Fork it.
2.  Create your feature branch (`git checkout -b my-new-feature`).
3.  Commit your changes (`git commit -am 'Add some feature'`).
4.  Push to the branch (`git push origin my-new-feature`).
5.  Create new Pull Request.

### Developer Certificate of Origin

In order to protect users of this project, we require all contributors to comply with the [Developer Certificate of Origin](https://developercertificate.org/). This ensures that all contributions are properly licensed and attributed.

### Community Guidelines

This project is best served by a collaborative and respectful environment. Treat each other professionally, respect differing viewpoints, and engage constructively. Harassment, discrimination, or harmful behavior is not tolerated. Communicate clearly, listen actively, and support one another. If any issues arise, please inform the project maintainers.
