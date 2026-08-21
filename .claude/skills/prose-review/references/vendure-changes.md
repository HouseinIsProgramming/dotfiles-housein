# Reviewing a Vendure branch or PR

Read this only when the text under review is a change to the `vendurehq/vendure` repo. Reviewing a
file or a block of text needs nothing from here.

## Extract the added prose

For a branch, diff against the base and keep only the added lines:

```bash
# Guide docs
git diff origin/minor...HEAD -- 'docs/docs/guides/**' | grep '^+' | grep -v '^+++' | sed 's/^+//'

# Comments and JSDoc
git diff origin/minor...HEAD -- 'packages/**/*.ts' | grep '^+' | grep -v '^+++' \
  | grep -E '^\+\s*(//|\*|/\*)' | sed 's/^+//'
```

Adjust the base branch: `master` for fixes, `minor` for features, `major` for breaking changes.

For a PR, select the files through the API. Do not use `gh pr diff`, which emits one combined diff
with no way to filter by path:

```bash
PR=1234

# Guide docs
gh api repos/vendurehq/vendure/pulls/$PR/files --paginate \
  --jq '.[] | select(.filename | test("^docs/docs/guides/")) | .patch' \
  | grep '^+' | grep -v '^+++' | sed 's/^+//'

# Comments and JSDoc
gh api repos/vendurehq/vendure/pulls/$PR/files --paginate \
  --jq '.[] | select(.filename | test("^packages/.*\\.ts$")) | .patch' \
  | grep '^+' | grep -v '^+++' | grep -E '^\+\s*(//|\*|/\*)' | sed 's/^+//'
```

The `--paginate` matters: the API returns a PR touching more than 30 files in pages, and without it
the later files are silently missing from the review.

Do not review files under `docs/docs/reference/` directly. They are generated from JSDoc in the
packages. Fix the source comment and regenerate.

## Regenerate the reference docs

If the change touches JSDoc which appears in the generated reference docs, regenerate them with
`bun run docs:build` from the repo root and include the regenerated files.

Running only `docs:generate-typescript-docs` is faster, but it deletes the GraphQL reference docs
as a side effect, since the two generators share an output directory and only the second writes
those files. If you take the fast path, restore them before committing:

```bash
git checkout -- docs/docs/reference/graphql-api/
```
