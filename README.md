# Confluence Forge Macros (Monorepo)

Single Forge app that exposes multiple Confluence macros, plus shared packages for types, utilities, and UI
primitives.

## Layout

- `apps/forge-app`: Forge app (manifest + macro implementations)
- `packages/*`: shared packages
- `scripts/*`: repo convenience scripts
- `tests/*`: repo-level unit/e2e tests (optional)

## Getting started

1. Install dependencies:
   - `pnpm install`
2. Lint / typecheck / test / build:
   - `pnpm ci`

## Forge

The Forge `app.id` in `apps/forge-app/manifest.yml` is a placeholder. Replace it with your app ARI before
deploying.

