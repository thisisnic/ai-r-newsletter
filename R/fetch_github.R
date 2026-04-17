# Fetch GitHub release atom feeds listed in sources/github.csv and write any new
# releases into content/<week>/*.md.
#
# Pattern: https://github.com/<owner>/<repo>/releases.atom

source("R/utils.R")
suppressPackageStartupMessages({
  library(tidyRSS)
  library(readr)
})

sources <- read_csv("sources/github.csv", show_col_types = FALSE)
week <- week_key()
seen <- read_seen()

total <- 0

for (i in seq_len(nrow(sources))) {
  name <- sources$name[i]
  feed_url <- sources$feed_url[i]
  message("Fetching ", name)

  feed <- tryCatch(
    tidyfeed(feed_url),
    error = function(e) {
      message("  failed: ", conditionMessage(e))
      NULL
    }
  )
  if (is.null(feed) || nrow(feed) == 0) next

  links <- get_col(feed, c("item_link", "entry_link"))
  titles <- get_col(feed, c("item_title", "entry_title"))
  dates <- get_col(feed, c("item_date_published", "item_pub_date", "entry_updated"))
  bodies <- get_col(feed, c("item_content_html", "item_description", "entry_content"))

  keep <- !is.na(links) & !links %in% seen
  if (!any(keep)) {
    message("  no new items")
    next
  }

  idx <- which(keep)
  for (j in idx) {
    # Release titles are often just version strings (e.g. 'v0.4.0') which
    # collide across repos, so prefix the slug with the repo name.
    slug <- paste0(slugify(name), "-", slugify(titles[j]))
    fm <- list(
      title = yaml_str(paste(name, titles[j])),
      url = links[j],
      source = name,
      date = safe_date(dates[j])
    )
    write_item(week, slug, fm, bodies[j] %||% "")
  }
  mark_seen(links[idx], name)
  total <- total + length(idx)
  message("  wrote ", length(idx), " new items")
}

message("Total new GitHub items this run: ", total)
