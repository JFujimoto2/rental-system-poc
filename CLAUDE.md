# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Rental System POC — a Rails 8.1.2 monolith using Ruby 3.3.2, PostgreSQL, and Hotwire (Turbo + Stimulus). Currently a scaffolded POC with no domain models or routes yet.

## Common Commands

### Development
```bash
bin/setup                    # Bootstrap environment (installs deps, prepares DB, starts server)
bin/setup --skip-server      # Setup without starting server
bin/rails server             # Start Puma on port 3000
bin/dev                      # Alias for bin/rails server
```

### Testing
```bash
bin/rails test                          # Run all tests (parallel, workers = CPU count)
bin/rails test test/models/foo_test.rb  # Run a single test file
bin/rails test test/models/foo_test.rb:42  # Run a specific test by line number
bin/rails test:system                   # Run system tests (Capybara + Selenium)
```

### Code Quality
```bash
bin/rubocop                  # Lint (rubocop-rails-omakase style)
bin/rubocop -a               # Auto-fix lint issues
bin/brakeman --no-pager      # Security scan
bin/bundler-audit             # Gem vulnerability audit
bin/importmap audit          # JS dependency audit
```

### Full CI Pipeline (locally)
```bash
bin/ci                       # Runs: rubocop, bundler-audit, importmap audit, brakeman, tests, seed check
```

### Database
```bash
bin/rails db:prepare         # Create + migrate (idempotent)
bin/rails db:migrate         # Run pending migrations
bin/rails db:seed            # Load seed data
```

## Architecture

- **Framework:** Rails 8.1 with `load_defaults 8.1`
- **Frontend:** Hotwire (Turbo + Stimulus) via ImportMap — no JS build step
- **Asset pipeline:** Propshaft
- **Database:** PostgreSQL (single DB in dev/test; multi-DB in production for primary, cache, queue, cable)
- **Background jobs:** Solid Queue (database-backed, runs in Puma process via `SOLID_QUEUE_IN_PUMA`)
- **Cache:** Solid Cache (database-backed in production, memory store in dev)
- **Action Cable:** Solid Cable (database-backed)
- **Testing:** Minitest with parallel execution, fixtures auto-loaded
- **Deployment:** Docker + Kamal; Dockerfile uses multi-stage build with jemalloc and Thruster

## Key Configuration

- **Locale:** デフォルトは日本語 (`config.i18n.default_locale = :ja`)、タイムゾーンは `Asia/Tokyo`
- `lib/` is autoloaded (except `lib/assets` and `lib/tasks`)
- Production enforces modern browsers (webp, import maps, CSS nesting support)
- CI sets `ENV['CI']` which enables eager loading in test environment
- RuboCop uses `rubocop-rails-omakase` (Rails community conventions)
- GitHub Actions CI runs: brakeman, importmap audit, rubocop, tests, and system tests (separate jobs)
