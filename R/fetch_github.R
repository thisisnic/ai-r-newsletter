# Fetch NEWS.md for each R package listed in sources/github.csv, parse out
# per-version entries, and write any new ones into content/<week>/*.md.
#
# Date strategy:
# - if the version header contains an inline (YYYY-MM-DD), use that
# - else use the most recent commit date touching the NEWS file (GitHub API)
# - else today
#
# Dedup key is a synthetic URL per (repo, version), so each version is reported
# at most once ever.

source("R/utils.R")
suppressPackageStartupMessages({
  library(readr)
  library(httr2)
})

sources <- read_csv("sources/github.csv", show_col_types = FALSE)
week <- week_key()
seen <- read_seen()

fetch_news <- function(repo) {
  for (path in c("NEWS.md", "NEWS")) {
    url <- sprintf("https://raw.githubusercontent.com/%s/HEAD/%s", repo, path)
    resp <- tryCatch(
      req_perform(req_error(request(url), is_error = function(r) FALSE)),
      error = function(e) NULL
    )
    if (!is.null(resp) && resp_status(resp) == 200) {
      return(list(text = resp_body_string(resp), path = path))
    }
  }
  NULL
}

last_commit_date <- function(repo, path) {
  url <- sprintf(
    "https://api.github.com/repos/%s/commits?path=%s&per_page=1",
    repo, path
  )
  req <- request(url) |> req_headers(Accept = "application/vnd.github+json")
  token <- Sys.getenv("GITHUB_TOKEN")
  if (nzchar(token)) req <- req_auth_bearer_token(req, token)
  resp <- tryCatch(req_perform(req), error = function(e) NULL)
  if (is.null(resp) || resp_status(resp) != 200) return(NA_character_)
  body <- resp_body_json(resp)
  if (length(body) == 0) return(NA_character_)
  as.character(as.Date(body[[1]]$commit$committer$date))
}

parse_news <- function(text, pkg) {
  lines <- strsplit(text, "\n", fixed = TRUE)[[1]]
  pkg_esc <- gsub(".", "\\.", pkg, fixed = TRUE)
  hdr_re <- sprintf(
    "(?i)^#\\s+%s\\s+(\\S.*?)\\s*(?:\\((\\d{4}-\\d{2}-\\d{2})\\))?\\s*$",
    pkg_esc
  )
  hdr_idx <- grep(hdr_re, lines, perl = TRUE)
  if (length(hdr_idx) == 0) return(list())

  entries <- list()
  for (k in seq_along(hdr_idx)) {
    start <- hdr_idx[k]
    end <- if (k < length(hdr_idx)) hdr_idx[k + 1] - 1 else length(lines)
    hdr <- lines[start]
    m <- regmatches(hdr, regexec(hdr_re, hdr, perl = TRUE))[[1]]
    version <- trimws(m[2])
    inline_date <- m[3]
    # Skip development/unreleased markers
    if (grepl("development|dev|unreleased", version, ignore.case = TRUE)) next
    body <- paste(lines[(start + 1):end], collapse = "\n")
    entries[[length(entries) + 1]] <- list(
      version = version,
      inline_date = if (nzchar(inline_date)) inline_date else NA_character_,
      body = body
    )
  }
  entries
}

total <- 0

for (i in seq_len(nrow(sources))) {
  name <- sources$name[i]
  repo <- sources$repo[i]
  message("Fetching ", name, " (", repo, ")")

  news <- fetch_news(repo)
  if (is.null(news)) {
    message("  no NEWS file found at HEAD")
    next
  }

  entries <- parse_news(news$text, name)
  if (length(entries) == 0) {
    message("  no '# ", name, " <version>' headers matched")
    next
  }

  make_url <- function(version) {
    sprintf(
      "https://github.com/%s/blob/HEAD/%s#%s",
      repo, news$path, slugify(paste(name, version))
    )
  }

  new_entries <- Filter(function(e) !(make_url(e$version) %in% seen), entries)
  if (length(new_entries) == 0) {
    message("  no new versions")
    next
  }

  needs_fallback <- any(vapply(new_entries, function(e) is.na(e$inline_date), logical(1)))
  fallback_date <- if (needs_fallback) last_commit_date(repo, news$path) else NA_character_

  new_urls <- character()
  for (e in new_entries) {
    item_date <- e$inline_date %||% fallback_date %||% as.character(Sys.Date())
    u <- make_url(e$version)
    slug <- paste0(slugify(name), "-", slugify(e$version))
    fm <- list(
      title = yaml_str(paste(name, e$version)),
      url = u,
      source = name,
      date = item_date
    )
    write_item(week, slug, fm, e$body)
    new_urls <- c(new_urls, u)
  }
  mark_seen(new_urls, name)
  total <- total + length(new_urls)
  message("  wrote ", length(new_urls), " new versions")
}

message("Total new GitHub items this run: ", total)
