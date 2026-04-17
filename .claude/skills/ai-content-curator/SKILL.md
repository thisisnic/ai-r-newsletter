---
name: ai-content-curator
description: Manage sources and drafts for the AI-R weekly newsletter. Use to add/remove sources, preview what's queued for this week, edit a draft newsletter, or debug a fetch. The weekly fetch+summarise runs automatically via GitHub Actions.
---

# AI Content Curator (lean)

## Purpose

This repo auto-fetches and summarises AI + R content weekly. The pipeline is plain R scripts driven by a cron job — you don't need me to run it. Use this skill for the judgment work the pipeline can't do:

- Adding or removing sources
- Reviewing/editing the current week's draft newsletter
- Checking what's been fetched this week
- Debugging fetcher failures
- Handling sources that have no feed (manual notes)

## Layout (quick reference)

- `sources/*.csv` — one CSV per source type
- `R/fetch_<type>.R` — one fetcher per type
- `R/summarise.R` — weekly digest
- `content/<YYYY-Www>/*.md` — raw items
- `newsletters/<YYYY-Www>.md` — draft
- `seen.csv` — dedup

## Workflows

### "Add [URL] as a source"
1. Figure out the source type (Substack, blog with RSS, GitHub releases, docs page, etc.)
2. Find the feed URL if applicable (Substack = `<domain>/feed`; many blogs = `<url>/feed` or `/index.xml`; GitHub releases = `<repo>/releases.atom`)
3. Append a row to the matching `sources/*.csv`. If no CSV exists for the type yet, flag that we need a new fetcher.

### "Show me this week's drafts" / "What was fetched?"
- Compute the ISO week (`date +%G-W%V`)
- List `content/<week>/`
- Summarise titles + sources

### "Edit the newsletter"
- Open `newsletters/<week>.md`
- Make requested edits

### "Run fetch/summarise now"
- `Rscript R/fetch_substacks.R`
- `Rscript R/summarise.R` (needs `ANTHROPIC_API_KEY`)

### "A fetcher is broken"
- Re-run it locally; capture stderr
- Check if the feed URL still works (WebFetch)
- Fix the URL or patch the fetcher's column handling

## Sources without feeds

Many interesting sources (courses, live docs, some GitHub repos) don't have usable feeds. Current convention: don't auto-fetch them. During newsletter review, manually WebFetch anything worth mentioning and paste it into that week's newsletter directly.

When a new source type accumulates more than a couple of entries, it's worth promoting it to its own CSV + fetcher.

## Tone

- Direct, practical, minimal ceremony
- Don't re-explain the pipeline unless asked
- When adding sources, don't over-validate — append and move on
