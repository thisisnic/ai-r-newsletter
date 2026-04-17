# ai-r-newsletter

Weekly AI + R newsletter, auto-generated.

A GitHub Actions cron job fetches new items from configured sources, then uses Claude to draft a digest.

## Layout

- `sources/` — source CSVs split by type (each type needs its own fetcher because the fetch mechanics differ)
- `R/` — fetchers + summariser
- `content/<YYYY-Www>/` — raw fetched items for the week
- `newsletters/<YYYY-Www>.md` — AI-drafted weekly digest
- `seen.csv` — dedup state (URLs we've already fetched)
- `.github/workflows/weekly.yml` — Sunday 01:00 UTC cron

## Source types wired up

- **`sources/feeds.csv`** — RSS/Atom feeds (Substacks, Quarto blogs, Hugo sites). Fetched by `R/fetch_feeds.R`.
- **`sources/github.csv`** — R packages; we parse each repo's `NEWS.md` for new version entries. Fetched by `R/fetch_github.R`.

## Adding a source

- **Existing type**: append a row to the relevant `sources/*.csv`.
- **New type**: create a new CSV in `sources/` and a matching `R/fetch_<type>.R` that writes markdown files into `content/<week>/` and calls `mark_seen()`. Wire it into the workflow.

## Running locally

```r
Rscript R/fetch_feeds.R
Rscript R/fetch_github.R
Rscript R/summarise.R
```

`summarise.R` needs `ANTHROPIC_API_KEY` in the environment.
