# ai-r-newsletter

Weekly AI + R newsletter, auto-generated.

A GitHub Actions cron job fetches new items from configured sources, then uses Claude to draft a digest.

## Layout

- `sources/` — source CSVs split by type (each type needs its own fetcher because the fetch mechanics differ)
- `R/` — fetchers + summariser
- `content/<YYYY-Www>/` — raw fetched items for the week
- `newsletters/<YYYY-Www>.md` — AI-drafted weekly digest
- `seen.csv` — dedup state (URLs we've already fetched)
- `.github/workflows/weekly.yml` — Monday 08:00 UTC cron

## Adding a source

- **Existing type (e.g. Substack)**: append a row to `sources/substacks.csv`.
- **New type**: create a new CSV in `sources/` and a matching `R/fetch_<type>.R` that writes markdown files into `content/<week>/` and calls `mark_seen()`. Wire it into the workflow.

## Running locally

```r
Rscript R/fetch_substacks.R
Rscript R/summarise.R
```

`summarise.R` needs `ANTHROPIC_API_KEY` in the environment.

## Status

Prototype. Only Substacks/RSS feeds are wired up so far. GitHub releases and docs-page scraping are next.
