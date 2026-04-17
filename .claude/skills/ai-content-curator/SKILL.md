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

## Layout (quick reference)

- `sources/*.csv` — one CSV per source type
- `R/fetch_<type>.R` — one fetcher per type
- `R/summarise.R` — weekly digest
- `content/<YYYY-Www>/*.md` — raw items
- `newsletters/<YYYY-Www>.md` — draft
- `seen.csv` — dedup

## Source types wired up

- `sources/feeds.csv` — RSS/Atom feeds (Substacks, Quarto blogs, etc.). Fetched by `R/fetch_feeds.R`.
- `sources/github.csv` — R packages; parsed from each repo's `NEWS.md`. Fetched by `R/fetch_github.R`.

## Workflows

### "Add [URL] as a source"
1. Figure out the source type. R package? → `sources/github.csv` with `repo` like `tidyverse/ellmer`. Blog/Substack with RSS? → `sources/feeds.csv` with a feed URL.
2. Find the feed URL if applicable. Common patterns: Substack = `<domain>/feed`; Quarto blogs = `<url>/index.xml`; Hugo = `<url>/index.xml` or `/feed`.
3. Append a row. If no existing CSV matches the source type, flag that we need a new fetcher.

### "Show me this week's drafts" / "What was fetched?"
- Compute the ISO week (`date +%G-W%V`)
- List `content/<week>/`
- Summarise titles + sources

### "Edit the newsletter"
- Open `newsletters/<week>.md`
- Make requested edits

### "Run fetch/summarise now"
- `Rscript R/fetch_feeds.R`
- `Rscript R/fetch_github.R`
- `Rscript R/summarise.R` (needs `ANTHROPIC_API_KEY`)

### "A fetcher is broken"
- Re-run it locally; capture stderr
- Check if the feed URL still works (WebFetch)
- Fix the URL or patch the fetcher's column handling

## Sources we've explicitly skipped

Pages without feeds (courses, docs sites, live reference material) and one-off news articles (Economist, HBR, Guardian) are out of scope for the automated pipeline. If something from those catches your eye, paste it into that week's newsletter manually.

## Tone

- Direct, practical, minimal ceremony
- Don't re-explain the pipeline unless asked
- When adding sources, don't over-validate — append and move on
