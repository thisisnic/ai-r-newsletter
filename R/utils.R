# Shared helpers used by all fetchers and the summariser.

suppressPackageStartupMessages({
  library(fs)
  library(readr)
  library(tibble)
})

week_key <- function(date = Sys.Date()) {
  format(date, "%G-W%V")
}

slugify <- function(x) {
  x <- tolower(as.character(x))
  x <- gsub("[^a-z0-9]+", "-", x)
  x <- gsub("^-+|-+$", "", x)
  if (!nzchar(x)) x <- "item"
  substr(x, 1, 60)
}

`%||%` <- function(a, b) {
  if (is.null(a) || length(a) == 0 || (length(a) == 1 && is.na(a))) b else a
}

seen_path <- function() "seen.csv"

read_seen <- function() {
  p <- seen_path()
  if (!file_exists(p)) return(character())
  readr::read_csv(p, show_col_types = FALSE)$url
}

mark_seen <- function(urls, source) {
  p <- seen_path()
  new <- tibble(
    url = urls,
    source = source,
    date_seen = as.character(Sys.Date())
  )
  if (file_exists(p)) {
    write_csv(new, p, append = TRUE)
  } else {
    write_csv(new, p)
  }
}

yaml_str <- function(x) {
  x <- as.character(x)
  if (length(x) == 0 || is.na(x)) return('""')
  sprintf('"%s"', gsub('"', "'", x, fixed = TRUE))
}

safe_date <- function(x) {
  tryCatch(
    as.character(as.Date(x)),
    error = function(e) as.character(Sys.Date()),
    warning = function(w) as.character(Sys.Date())
  )
}

write_item <- function(week, slug, frontmatter, body) {
  dir <- file.path("content", week)
  dir_create(dir)
  path <- file.path(dir, paste0(slug, ".md"))
  fm_lines <- paste0(names(frontmatter), ": ", unlist(frontmatter))
  out <- c("---", fm_lines, "---", "", body %||% "")
  writeLines(out, path)
  path
}

get_col <- function(df, names) {
  for (n in names) if (n %in% colnames(df)) return(df[[n]])
  rep(NA_character_, nrow(df))
}
