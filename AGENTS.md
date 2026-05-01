# Repository Guidelines

## Project Structure & Module Organization

This repository is an Astro 4 static site based on the Bigspring theme. Source files live in `src/`: route pages are in `src/pages`, layouts and components in `src/layouts`, utilities in `src/lib`, global styles in `src/styles`, and content collections in `src/content`. Site configuration is in `src/config/*.json`. Static assets, including images and `robots.txt`, live in `public/`. Build output is generated in `dist/` and should not be edited by hand.

## Build, Test, and Development Commands

Use the package manager that matches the lockfile when possible:

- `pnpm install` installs dependencies from `pnpm-lock.yaml`.
- `pnpm dev` starts the Astro dev server with host binding for local preview.
- `pnpm build` creates the production build in `dist/`.
- `pnpm format` runs Prettier across the repository.

Equivalent `npm run ...` commands are also supported by `package.json`, but avoid mixing package managers in committed lockfiles.

## Coding Style & Naming Conventions

Follow `.editorconfig`: UTF-8, LF line endings, two-space indentation, trimmed trailing whitespace, and final newlines. Prettier is the formatter, with Astro and Tailwind plugins configured; run `pnpm format` before larger commits. Use PascalCase for Astro/React components such as `Logo.astro` and `Search.tsx`, camelCase for TypeScript utilities such as `dateFormat.ts`, and kebab-case for content slugs such as `otree-launcher.md`.

## Content & Assets

Blog posts belong in `src/content/blog` and should include frontmatter matching `src/content/config.ts`: `title` is required; `description`, `date`, `image`, `authors`, `categories`, `tags`, and `draft` are available. Put referenced images under `public/images`.

## Testing Guidelines

There is no dedicated automated test script. Treat `pnpm build` as the required verification step for structural, content schema, and TypeScript/Astro errors. For UI or content changes, also run `pnpm dev` and check affected pages in a browser.

## Commit & Pull Request Guidelines

Recent history uses short conventional-style messages, mostly `feat: ...` such as `feat: add blog for otree launcher`. Keep commits focused and use a lower-case type prefix when practical, for example `feat: add pricing copy` or `fix: correct blog metadata`. Pull requests should include a brief summary, verification steps, linked issues when applicable, and screenshots for visible changes.

## Agent-Specific Instructions

Do not edit generated files in `dist/` or dependency files in `node_modules/`. Keep changes scoped to source, content, configuration, or public assets needed for the requested update.
