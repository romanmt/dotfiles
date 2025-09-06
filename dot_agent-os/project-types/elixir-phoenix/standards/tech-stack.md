# Tech Stack

## Context

Global tech stack defaults for Agent OS projects, overridable in project-specific `.agent-os/product/tech-stack.md`.

  - App Framework: Phoenix LiveView 1.7+
  - Language: Elixir 1.14+
  - Primary Database: PostgreSQL
  - ORM: Ecto
  - JavaScript Framework: Vanilla JS with Phoenix LiveView
  - Build Tool: esbuild
  - Import Strategy: ES6 modules
  - Package Manager: npm
  - Node Version: Not specified (using npm for assets)
  - CSS Framework: TailwindCSS
  - UI Components: ag-grid-community for tables
  - UI Installation: Via npm in assets directory
  - Font Provider: Default system fonts
  - Font Loading: Browser default
  - Icons: Hero Icons (Phoenix default)
  - Application Hosting: fly.io
  - Hosting Region: Auto-selected by fly.io
  - Database Hosting: fly.io PostgreSQL
  - Database Backups: fly.io managed
  - Asset Storage: Local file system
  - CDN: None (served directly)
  - Asset Access: Public via Phoenix static
  - CI/CD Platform: GitHub Actions
  - CI/CD Trigger: Push to main branch
  - Tests: Run before deployment (mix test)
  - Production Environment: main branch
  - Staging Environment: Not configured
  - Runtime Management: asdf