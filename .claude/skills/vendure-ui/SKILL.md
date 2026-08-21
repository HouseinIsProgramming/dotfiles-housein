---
name: vendure-ui
description: Build and review frontend interfaces in consumers of @vendure/dashboard or @vendure-io/ui. Use when creating or changing Vendure Dashboard extensions, pages, forms, lists, detail views, settings, component compositions, actions, async states, illustrations, or when reviewing existing UI against Vendure composition rules.
---

# Vendure UI

Apply Vendure's component decisions and strong-default screen recipes while keeping domain data and application state in the consumer.

## Classify the host

Inspect the task and repository before choosing imports.

1. Treat code as a Dashboard extension when it imports or calls `defineDashboardExtension` from `@vendure/dashboard`, or when a `VendurePlugin` declares a `dashboard` entry.
2. In a Dashboard extension, import design-system UI and dashboard layout/form APIs from `@vendure/dashboard`. Do not mix in direct `@vendure-io/ui` imports unless the repository documents an exception.
3. In a standalone consumer, import each component from its exact `@vendure-io/ui/components/atoms/*` or `components/molecules/*` subpath. Do not create barrel imports.
4. Inspect the installed package source and types before assuming an export or prop. The source is the API authority.

Complete classification when the host and import surface are explicit.

## Choose the composition

Follow this order:

1. Search for an existing molecule that already expresses the behavior.
2. Use that molecule instead of rebuilding it from atoms.
3. If no molecule fits, compose existing atoms in the consumer without copying or modifying design-system source.
4. Keep domain meaning, fetching, routing, authorization, persistence, and application state consumer-owned unless a component explicitly owns that behavior.
5. When a second consumer needs the same local composition, flag it as a candidate to graduate into `@vendure-io/ui`.

For a whole page, read the matching section of [screen-recipes.md](references/screen-recipes.md). Treat recipe hierarchy, action placement, responsive anatomy, and state handling as strong defaults. In a standalone consumer, begin from the owned standalone skeleton. In a Dashboard extension, follow the integration intent, inspect the installed `@vendure/dashboard` source and types for the current APIs, and do not recreate the standalone page shell or invent Dashboard imports. Deviate only for a concrete product requirement and report the reason.

For component decisions, search [component-decisions.md](references/component-decisions.md) by component or decision name and read every relevant section before implementing. Do not load unrelated sections merely to inventory the catalog.

## Apply cross-cutting rules

- Compose one primary Button per view. Step supporting actions down to secondary, outline, ghost, or overflow according to weight.
- Use the state dictionary and `StatusBadge` for domain states. Do not choose status color at the call site.
- Render waiting, successful emptiness, and failure with `LoadingState`, `EmptyState`, and `ErrorState` respectively.
- For empty or error media, read [illustrations.md](references/illustrations.md). Use one scenario-matched illustration for the whole region, never repeated inside populated rows or cards.
- Compose forms with visible labels, stable descriptions, actionable errors, matching accessible invalid state, and one clear submit hierarchy.
- In Dashboard extensions, use the form APIs exported by `@vendure/dashboard`. In standalone consumers, preserve the app's existing form-state library.
- Keep destructive actions outside the routine save path and confirm only irreversible, bulk, or outward-facing consequences.
- Use the `vendure-tokens` skill for custom styling, theme setup, color, typography, surfaces, or motion. Do not duplicate token decisions here.

## Handle conflicting local code

For new or substantially changed UI, follow this skill even when neighboring consumer code is inconsistent. Do not copy an existing violation as precedent. Do not opportunistically refactor unrelated screens; identify the inconsistency as migration debt in the handoff.

## Review UI

When the user asks for a review, remain read-only unless they also request changes. Audit:

- host-appropriate imports;
- molecule selection and atom composition;
- screen-recipe hierarchy;
- action emphasis and placement;
- form anatomy and validation;
- loading, empty, error, not-found, and permission states;
- illustration selection and repetition;
- state-dictionary use;
- accessibility semantics;
- local compositions that should graduate.

Report concrete findings with file and line evidence, impact, and the applicable rule. Do not report stylistic preference as a violation.

## Completion criteria

Before finishing an implementation:

1. Verify every import against the active host package.
2. Confirm an existing molecule was not reimplemented.
3. Confirm the closest screen recipe was applied or the deviation was explained.
4. Confirm action, form, state, and illustration decisions follow the referenced rules.
5. Run the consumer's relevant type, lint, and test commands.
6. Report intentional deviations, migration debt encountered, and graduation candidates.
