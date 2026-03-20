# Vue — Framework Knowledge

**Applies to**: JavaScript or TypeScript projects with `vue` in dependencies
**Type**: Frontend framework

## Detection Signals

- `vue` in package.json dependencies
- `*.vue` single-file components
- `vite.config.ts` with `@vitejs/plugin-vue` (Vue 3 + Vite)
- `nuxt.config.ts` indicates Nuxt.js (Vue meta-framework)

## Build / Run

| Action | Command |
|--------|---------|
| Dev | `npx vite` (Vite) or `npx vue-cli-service serve` (CLI) |
| Build | `npx vite build` or `npx vue-cli-service build` |
| Test | `npx vitest run` or `npx jest` |
| Lint | `npx eslint .` with `eslint-plugin-vue` |

## Additional Rules (extend JS/TS rules)

### Composition API (Vue 3 — preferred)
- Use `<script setup>` syntax for components (concise, better TypeScript support)
- `ref()` for primitive reactive state, `reactive()` for objects
- `computed()` for derived state — never use methods for values that can be computed
- `watch()` and `watchEffect()` for side effects
- Composables (functions starting with `use`) for reusable stateful logic

### Options API (Vue 2 / legacy)
- Only use in existing codebases that haven't migrated
- `data()`, `computed`, `methods`, `watch` in that order

### Single-File Components
- `<script setup lang="ts">` at the top
- `<template>` in the middle
- `<style scoped>` at the bottom
- Keep components under 200 lines; extract composables and child components

### Props and Events
- Define props with `defineProps<{...}>()` (type-based)
- Define emits with `defineEmits<{...}>()` (type-based)
- Use `v-model` for two-way binding with custom components

### State Management
- Small apps: `provide/inject` or shared composables
- Larger apps: Pinia (official, replaces Vuex)
- Never mutate props directly; emit events to parent

### Testing
- Component tests with `@vue/test-utils` + Vitest
- `mount()` for full component tree, `shallowMount()` for isolation
- Test user interactions and rendered output, not internal state

### Security
- Never use `v-html` with unsanitized user content
- Use `{{ }}` interpolation (auto-escaped) for all dynamic text
- API keys in `.env` files with `VITE_` prefix for client exposure
